{{ config(
    materialized = 'table',
    schema       = 'datamart_03_consumption',
    tags         = ['finance']
) }}

with orders as (
    select * from {{ ref('fct_orders') }}
),

customers as (
    select * from {{ ref('dim_customers') }}
),

customer_orders as (
    select
        customer_sk_id,
        sum(case when status != 'cancelled' then amount_usd else 0 end) as total_spend_usd,
        count(case when status != 'cancelled' then order_sk_id else null end) as total_orders,
        max(order_date) as last_order_date
    from orders
    group by 1
),

final as (
    select
        c.customer_nk as customer_id,
        c.country,
        c.plan,
        co.total_spend_usd,
        co.total_orders,
        case 
            when co.total_orders > 0 then co.total_spend_usd / co.total_orders
            else null 
        end as avg_order_value_usd,
        date_diff(current_date(), co.last_order_date, day) as days_since_last_order,
        case 
            when date_diff(current_date(), co.last_order_date, day) <= 90 then true
            else false
        end as is_active
    from customers c
    left join customer_orders co on c.customer_sk_id = co.customer_sk_id
)

select * from final
