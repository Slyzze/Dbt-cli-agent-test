---
name: bi-data-engineering-lifecycle
description: >
  Orchestrates the full BI data engineering lifecycle. Always starts by asking the user to
  pick between two equal options for providing business requirements: (1) a Notion page URL,
  or (2) typing the requirements directly into the chat. Then generates a complete dbt
  project, generates LookML, and optionally pushes the result to a GitHub repository.
  Chains specs-reading → dbt-gen → LookML generation end-to-end. Use for project
  initialization, major feature additions, or full platform rebuilds.
---

# BI Data Engineering Lifecycle Orchestrator

This skill manages the end-to-end flow of building an analytics platform — from a business
requirements document to a deployed, test-passing dbt + LookML codebase.

> ⚠️ **AGENT INSTRUCTION — READ FIRST**
> The very first thing this skill must do is present the **two-option prompt** in step 0a
> and **wait for the user to pick one**. The two options are equal — neither is a fallback,
> neither is a default, neither may be skipped. The user MUST reply with either:
>   • Option 1: a Notion page URL, OR
>   • Option 2: the business requirements typed/pasted directly into the chat.
> Do not invent requirements, do not infer them from existing files in the workspace,
> and do not begin any other phase until the user has explicitly chosen one of the two
> options and the parsed requirements have been confirmed.

---

## 0. Inputs — collect before orchestrating

### Step 0a — Business requirements (required, ask first)

Ask exactly this question first and wait for the user's answer before doing anything else.
**Both options are equally valid — never tell the user one is preferred or a fallback.**

```
📎 How would you like to provide the business requirements for this BI project?
   Please pick one of the two options below:

   Option 1 — Paste a Notion page URL
              The page should describe the source tables, marts, and business rules.
              e.g. https://www.notion.so/My-Project-Specs-abc123def456

   Option 2 — Type or paste the business requirements directly here in the chat
              Free-form is fine: bullet lists, prose, Markdown tables, or a mix.

👉 Reply with either the Notion URL (Option 1) or the requirements text (Option 2).
```

If the user replies with anything that is not a Notion URL and is not a clear set of
business requirements, ask the question again. Do not proceed without an explicit choice.

---

### Step 0b — Optional project settings

Ask for these only **after** requirements are confirmed (section 2). Present them together
as a single follow-up:

| Setting | Default | Description |
|---|---|---|
| `github_repo_url` | *(none)* | Full HTTPS URL of the target GitHub repo. If provided, all generated files are committed and pushed automatically. |
| `github_branch` | `main` | Branch to push to |
| `output_dir` | `./output` | Local root for generated files |
| `bigquery_project` | `my_project` | GCP project ID used by dbt |
| `bigquery_dataset` | `raw` | Raw dataset / schema name used in `sources.yml` |
| `looker_connection` | `bigquery` | Looker connection name used in LookML |

---

## 1. Workflow — 4 sequential phases

```
[ User picks Option 1 (Notion URL) OR Option 2 (direct input in chat) ]
        │
        ▼
Phase 1 ── Read & Parse Requirements
        │   • Option 1 → fetch Notion page via API
        │   • Option 2 → parse the text the user pasted in the chat
        │   • Normalise to specs.json
        │   • Echo summary → await user confirmation
        │
        ▼
Phase 2 ── dbt Generation  (invoke dbt-gen skill — Kimball / dimensional)
        │   • raw_ / stg_ / stg_*_scd2 (snapshots)
        │   • int_ (joins, denorm, dedup)
        │   • datamart/01_core   → dim_ / dim_*_scd2 / fct_ / brg_  (with group tags)
        │   • datamart/02_enriched → agg_ / wide_
        │   • datamart/03_consumption → rpt_ / retl_ / ai_ / comp_ / rec_
        │   • schema.yml (incl. meta.relationships) + sources.yml + dbt_project.yml
        │
        ▼
Phase 3 ── LookML Generation  (invoke looker-gen skill)
        │   • One Looker view per dim_ / fct_ / agg_ / wide_ exposed to BI
        │   • Explores with joins driven by config.meta.relationships
        │   • lookml_project.yaml
        │
        ▼
Phase 4 ── GitHub Push  (if github_repo_url provided)
            • git init / clone
            • git add + commit
            • git push → github_repo_url / github_branch
```

---

## 2. Phase 1 — Read & Parse Requirements

The branch taken in this phase depends on which option the user chose in step 0a.
Both branches end with the same confirmation summary in section 2e.

### Option 1 — Notion URL

#### 2a. Extract the page ID

```
https://www.notion.so/Workspace/Page-Title-{PAGE_ID}
                                            ^^^^^^^^
32 hex chars at the end, with or without hyphens.
Normalise to: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

#### 2b. Fetch page content

```http
GET https://api.notion.com/v1/blocks/{page_id}/children?page_size=100
Authorization: Bearer {NOTION_API_KEY}
Notion-Version: 2022-06-28
```

Paginate using `next_cursor` until `has_more` is `false`.
Recurse into `child_page` blocks to follow linked sub-pages.

#### 2c. If `NOTION_API_KEY` is not set

Stop and print these instructions verbatim:

```
🔑 Notion API key required

1. Go to https://www.notion.so/my-integrations
2. Click "New integration" → name it → copy the Internal Integration Secret
3. Open your Notion page → "..." menu (top right) → "Add connections" → select your integration
4. Set the environment variable:
     export NOTION_API_KEY=secret_xxxxxxxxxxxx
5. Re-run this skill.
```

#### 2d. Parse blocks into specs

| Block type | Interpretation |
|---|---|
| `heading_1` / `heading_2` | Entity name or mart domain |
| `table` | Source table — columns and data types |
| `bulleted_list_item` | Business rules, accepted values, FK relationships |
| `paragraph` containing "PK" or "FK" | Key constraints |
| `callout` | Critical business rules or grain definition |
| `child_page` | Sub-entity — recurse and fetch |

Type inference when not explicitly stated:

| Column name pattern | Inferred type |
|---|---|
| `*_id` | `STRING` |
| `*_at`, `*_date` | `TIMESTAMP` |
| `amount`, `price`, `revenue`, `count`, `qty` | `NUMERIC` |
| everything else | `STRING` |

---

### Option 2 — Direct input in the chat

Used when the user picked Option 2 in step 0a. Accept whatever free-form text the user
pasted directly in the chat:
- Bullet lists of tables and fields
- Prose descriptions
- Markdown tables
- A mix of the above

Extract: entities, columns, types, PKs, FKs, accepted values, mart grain, measures.
Ask follow-up questions only for critical gaps; never more than 2 at a time. Never
invent missing information — always ask the user.

---

### 2e. Confirmation summary (mandatory)

After reading from either source, output the following block and **wait for the user to type
"ok"** (or describe corrections) before invoking any sub-skill:

```
📋 Requirements Summary
────────────────────────────────────────
Source        : Option 1 – Notion page "<title>"   |   Option 2 – direct chat input
Project name  : <name>
Parsed at     : <ISO 8601 timestamp>

Source tables
  • <table_name>  [PK: <col>]  — <N> columns
  • ...

Mart domains
  • <mart_name>  grain: <grain>  measures: <list>

Relationships
  • <fk_col> → <parent_table>.<col>
  • ...

Business rules
  • <rule extracted from requirements>
  • ...

────────────────────────────────────────
✅ Type "ok" to proceed to dbt + LookML generation, or describe corrections.
```

---

## 3. Phase 2 — dbt Generation

Delegate entirely to the **`dbt-gen`** skill, which applies Kimball / dimensional best
practices on BigQuery. Pass:
- The normalised `specs.json` (from Phase 1)
- `output_dir` → `<output_dir>/dbt_project`
- `bigquery_project`, `bigquery_dataset_raw`, `bigquery_dataset_staging`,
  `bigquery_dataset_datamart`

Expected outputs (enforced):
```
<output_dir>/dbt_project/
  ├── dbt_project.yml
  ├── packages.yml
  ├── sources/sources.yml
  ├── snapshots/                       stg_<entity>_scd2.sql (one per SCD2 entity)
  └── models/
      ├── raw/                         raw_*.sql + schema.yml (optional)
      ├── staging/                     stg_*.sql + schema.yml
      ├── intermediate/                int_*.sql + schema.yml
      └── datamart/
          ├── 01_core/<group>/         dim_*.sql, fct_*.sql, brg_*.sql + schema.yml
          │                            (group ∈ google_workspace, finance,
          │                             human_resources, project_management,
          │                             utils, dimension)
          ├── 02_enriched/<group>/     agg_*.sql, wide_*.sql + schema.yml
          └── 03_consumption/<group>/  rpt_*.sql, retl_*.sql, ai_*.sql,
                                       comp_*.sql, rec_*.sql + schema.yml
```

Every 01_core model must declare:
- exactly one group tag under `config.tags`, AND
- foreign-key arrows under `config.meta.relationships` (used by the ERD generator).

See `dbt-gen` sections 3, 7, and 11 for the full layer rules.

---

## 4. Phase 3 — LookML Generation

Delegate to the **`looker-gen`** skill, passing:
- All BI-exposed datamart models from Phase 2 — typically the `dim_*`, `fct_*`,
  `agg_*`, `wide_*`, and `rpt_*` files (looker-gen will not consume `int_*` or `stg_*`).
- Their `schema.yml` for column descriptions, tests, and `config.meta.relationships`
  (used to drive Looker explore joins).
- `looker_connection`
- `output_dir` → `<output_dir>/looker_project`

Expected outputs:
```
<output_dir>/looker_project/
  ├── lookml_project.yaml
  ├── views/      <entity>.view.lkml         (one per dim_/fct_/agg_/wide_/rpt_)
  └── explores/   <domain>.explore.lkml      (joins mirror meta.relationships)
```

---

## 5. Phase 4 — GitHub Push

Triggered only when `github_repo_url` is provided.

```bash
OUTPUT_DIR="<output_dir>"
REPO_URL="<github_repo_url>"
BRANCH="${github_branch:-main}"

cat >> "$OUTPUT_DIR/.gitignore" <<'EOF'
target/
dbt_packages/
logs/
profiles.yml
.env
*.env
EOF

if [ -d "$OUTPUT_DIR/.git" ]; then
  git -C "$OUTPUT_DIR" fetch origin
else
  git clone "$REPO_URL" "$OUTPUT_DIR" 2>/dev/null || \
    (git -C "$OUTPUT_DIR" init && \
     git -C "$OUTPUT_DIR" remote add origin "$REPO_URL")
fi

git -C "$OUTPUT_DIR" add -A
git -C "$OUTPUT_DIR" commit -m \
  "feat: auto-generate BI project from Notion requirements [bi-lifecycle]

Source   : Notion page <page_title>
dbt layer: staging + intermediate + marts
LookML   : views + explores
Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"

git -C "$OUTPUT_DIR" push -u origin "$BRANCH"
```

On success, print:
```
✅ Project pushed to <github_repo_url>/tree/<branch>
```

On failure (no write access, repo not found, auth error), print the exact git error and suggest:
1. Creating the repo first: `gh repo create <org>/<name> --private`
2. Checking SSH key or personal access token scope (`repo` scope required)

---

## 6. Environment variables reference

| Variable | Used by | Purpose |
|---|---|---|
| `NOTION_API_KEY` | Phase 1 | Authenticate Notion API calls |
| `GITHUB_TOKEN` | Phase 4 | GitHub push authentication (used via git credential helper) |
| `DP_AGENT_OUTPUT_ROOT` | All | Override default output directory |

---

## 7. Acceptance criteria

- [ ] User was presented with the two-option prompt (step 0a) **before** any other action.
- [ ] User explicitly picked Option 1 (Notion URL) or Option 2 (direct chat input).
- [ ] Requirements from the chosen option were successfully parsed and confirmed by the user.
- [ ] All dbt models follow the Kimball layer rules from `dbt-gen` section 3
      (no `source()` from `int_*` or datamart, no cross-layer leaks).
- [ ] Every `schema.yml` includes `not_null` + `unique` on surrogate keys (`*_sk_id`),
      `relationships` on every FK, and `accepted_values` on every enum-like column.
- [ ] Every 01_core model has exactly one group tag and FK arrows in `meta.relationships`.
- [ ] Every fact has `partition_by` (and `cluster_by` where appropriate).
- [ ] dbt project builds and tests pass: `uv run dbt build` exits 0.
- [ ] All LookML files are syntactically valid (`lookml-lint` passes).
- [ ] Lineage preserved end-to-end: raw → staging → intermediate → datamart (01/02/03)
      → Looker view.
- [ ] If `github_repo_url` provided: commit pushed, branch updated, no secrets committed.

---

## 8. Error handling

| Error | Recovery |
|---|---|
| User did not pick Option 1 or Option 2 (e.g. asked something unrelated, or said "go") | Re-display the step 0a prompt verbatim and ask them to choose. Never proceed without an explicit choice. |
| User picked Option 1 but the URL is not a valid Notion link | Ask for a valid Notion URL, or invite them to switch to Option 2. |
| Notion API auth failure | Print the `NOTION_API_KEY` setup instructions from section 2c. |
| Notion page returns 404 / not shared with integration | Tell the user to invite the integration via "Add connections" on the page. |
| Missing field in requirements | Ask the user interactively; never invent data. |
| GitHub push rejected | Print the git error; suggest `gh repo create` or token fix. |
| `dbt-gen` or `looker-gen` failure | Surface the sub-skill error verbatim; do not silently continue. |

---

## 9. Hard constraints

- The first user-facing message of this skill **must** be the two-option prompt from step 0a.
- Both options are equal — never label one as default, preferred, or fallback in any user-facing message.
- The user MUST explicitly choose Option 1 (Notion URL) or Option 2 (direct chat input)
  before the skill does anything else. If they don't, repeat the step 0a prompt.
- Never invent business requirements. They come exclusively from the user's chosen option —
  the Notion page (Option 1) or the text typed in the chat (Option 2).
- Never re-use `specs.json`, existing dbt models, or any other file already in the workspace
  as a substitute for asking the user. Always ask first.
- Never proceed past Phase 1 without an explicit "ok" on the confirmation summary.
- Never commit `profiles.yml`, `.env`, or any file containing credentials.
