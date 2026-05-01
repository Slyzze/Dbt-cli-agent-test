{{ config(
    materialized = 'table',
    schema       = 'datamart_02_enriched',
    tags         = ['finance']
) }}

with orders as (
    select * from {{ ref('fct_orders') }}
),

customers as (
    select customer_sk_id, country from {{ ref('dim_customers') }}
),

joined as (
    select
        o.order_date as date_day,
        o.channel,
        c.country,
        o.amount_usd,
        o.status
    from orders o
    left join customers c on o.customer_sk_id = c.customer_sk_id
    where o.status != 'cancelled'
),

aggregated as (
    select
        date_day,
        channel,
        country,
        sum(amount_usd) as total_revenue_usd,
        count(*) as order_count,
        case 
            when count(*) > 0 then sum(amount_usd) / count(*)
            else null 
        end as avg_order_value_usd
    from joined
    group by 1, 2, 3
)

select * from aggregated
