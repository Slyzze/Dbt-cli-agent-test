with orders as (
    select * from {{ ref('stg_orders') }}
),

enriched as (
    select
        *,
        (amount_cents - coalesce(discount_cents, 0)) / 100.0 as amount_usd
    from orders
)

select * from enriched
