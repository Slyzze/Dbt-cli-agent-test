with customers as (
    select * from {{ ref('stg_customers') }}
)

, orders as (
    select * from {{ ref('stg_orders') }}
)

, customer_orders as (
    select
        customer_nk_id
        , max(created_at) as last_order_at
    from orders
    group by 1
)

, prep as (
    select
        {{ dbt_utils.generate_surrogate_key(['customers.customer_nk_id']) }} as customer_sk_id
        , customers.customer_nk_id
        , customers.email_address
        , customers.country_code
        , customers.subscription_plan
        , customers.created_at
        , customer_orders.last_order_at
        -- Business Rule 4: Active customer logic
        , case 
            when customer_orders.last_order_at >= timestamp_sub(current_timestamp(), interval 90 day) then true 
            else false 
          end as is_active_customer
    from customers
    left join customer_orders on customers.customer_nk_id = customer_orders.customer_nk_id
)

select * from prep
