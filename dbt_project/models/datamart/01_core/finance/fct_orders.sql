{{ config(
    materialized      = 'incremental',
    incremental_strategy = 'merge',
    unique_key        = 'order_sk_id',
    partition_by      = {'field': 'order_date', 'data_type': 'date'},
    cluster_by        = ['customer_sk_id'],
    schema            = 'datamart_01_core',
    tags              = ['finance']
) }}

with orders as (
    select * from {{ ref('int_orders_enriched') }}
),

customers as (
    select customer_sk_id, customer_nk from {{ ref('dim_customers') }}
),

products as (
    select product_sk_id, product_nk from {{ ref('dim_products') }}
),

joined as (
    select
        {{ dbt_utils.generate_surrogate_key(['o.order_id']) }} as order_sk_id,
        o.order_id                                            as order_nk,
        c.customer_sk_id,
        p.product_sk_id,
        date(o.created_at)                                    as order_date,
        o.status,
        o.amount_usd,
        o.channel,
        o.created_at,
        o.updated_at
    from orders o
    left join customers c on o.customer_id = c.customer_nk
    left join products p  on o.product_id = p.product_nk
    {% if is_incremental() %}
      where o.created_at > (select max(created_at) from {{ this }})
    {% endif %}
)

select * from joined
