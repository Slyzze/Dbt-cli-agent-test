{{
    config(
        materialized='table',
        partition_by={
          "field": "date_day",
          "data_type": "date",
          "granularity": "day"
        },
        cluster_by=["channel", "country"],
        tags=["finance"]
    )
}}

with orders_enriched as (
    select * from {{ ref('int_orders_enriched') }}
)

, daily_revenue as (
    select
        cast(created_at as date) as date_day
        , acquisition_channel as channel
        , country_code as country
        , count(distinct case when order_status in ('confirmed', 'delivered') then order_nk_id end) as order_count
        , sum(revenue_usd) as total_revenue_usd
        -- Business Rule 5: avg_order_value_usd should be NULL when order_count is 0
        , sum(revenue_usd) / nullif(count(distinct case when order_status in ('confirmed', 'delivered') then order_nk_id end), 0) as avg_order_value_usd
    from orders_enriched
    where order_status != 'cancelled'
    group by 1, 2, 3
)

select * from daily_revenue
