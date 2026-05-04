---
name: bi-gen
description: >
  Strategic orchestrator for the full BI lifecycle. Activates dbt-gen for requirements
  and modeling, then looker-gen for the semantic layer, and handles the final deployment.
---

# BI Platform Orchestrator

You are a strategic orchestrator. Your job is to coordinate specialized sub-skills to build a complete BI platform. **Do not parse business requirements or write dbt/LookML code yourself** — you must delegate these specific tasks to the `dbt-gen` and `looker-gen` skills.

## 1. Orchestration Workflow

Follow these sequential phases exactly. Do not skip ahead.

### Phase 1: Requirements & Data Modeling (Delegate to `dbt-gen`)
1. Activate the `dbt-gen` skill.
2. Prompt the user using `dbt-gen`'s exact "Step 0a" prompt to collect business requirements (Notion URL or direct input).
3. Follow `dbt-gen`'s instructions to parse requirements, show the confirmation summary, and generate the dbt project in `<output_dir>/dbt_project`.
4. **Crucial:** Because you are orchestrating, do NOT let `dbt-gen` perform the GitHub push. You will handle the combined push at the end.

### Phase 2: BI Semantic Layer (Delegate to `looker-gen`)
1. Once the dbt project is successfully generated, activate the `looker-gen` skill.
2. Provide `looker-gen` with the datamart models (e.g., `dim_*`, `fct_*`) and `schema.yml` files generated in Phase 1.
3. Allow `looker-gen` to generate the LookML views and explores in `<output_dir>/looker_project`.

### Phase 3: Version Control (Execute directly)
Ask the user if they want to push the generated platform to GitHub (if they haven't already provided a `github_repo_url` during Phase 1).

If they provide a `github_repo_url`:
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
git -C "$OUTPUT_DIR" commit -m "feat: auto-generate BI project (dbt + LookML) [bi-lifecycle]"
git -C "$OUTPUT_DIR" push -u origin "$BRANCH"
```
On success, print: `✅ Full BI platform pushed to <github_repo_url>/tree/<branch>`

## 2. Hard Constraints
- Never invent requirements. Rely entirely on `dbt-gen`'s data gathering process.
- Do not duplicate the Notion API parsing logic here. Rely on `dbt-gen`.
- Ensure `looker-gen` only runs AFTER `dbt-gen` has output the final `schema.yml` and datamart SQL files.
- Never commit `profiles.yml` or API keys to version control.