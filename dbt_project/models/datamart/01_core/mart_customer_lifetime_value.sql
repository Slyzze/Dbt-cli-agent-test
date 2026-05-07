{{
    config(
        materialized='table',
        tags=["dimension"]
    )
}}

with orders_enriched as (
    select * from {{ ref('int_orders_enriched') }}
)

, customers as (
    select * from {{ ref('int_customers_prep') }}
)

, customer_metrics as (
    select
        customer_sk_id
        , count(distinct case when order_status != 'cancelled' then order_nk_id end) as total_orders
        , sum(revenue_usd) as total_spend_usd
        , sum(revenue_usd) / nullif(count(distinct case when order_status != 'cancelled' then order_nk_id end), 0) as avg_order_value_usd
        , date_diff(current_date(), cast(max(created_at) as date), day) as days_since_last_order
    from orders_enriched
    group by 1
)

, final as (
    select
        customers.customer_sk_id
        , customers.customer_nk_id as customer_id
        , customers.country_code as country
        , customers.subscription_plan as plan
        , coalesce(customer_metrics.total_orders, 0) as total_orders
        , coalesce(customer_metrics.total_spend_usd, 0) as total_spend_usd
        , customer_metrics.avg_order_value_usd
        , customer_metrics.days_since_last_order
    from customers
    left join customer_metrics on customers.customer_sk_id = customer_metrics.customer_sk_id
)

select * from final
