with orders as (
    select * from {{ ref('int_orders_prep') }}
)

, customers as (
    select * from {{ ref('int_customers_prep') }}
)

, products as (
    select * from {{ ref('int_products_prep') }}
)

, joined as (
    select
        orders.order_sk_id
        , orders.customer_sk_id
        , orders.product_sk_id
        , orders.order_nk_id
        , orders.order_status
        , orders.acquisition_channel
        , orders.revenue_usd
        , orders.created_at
        , customers.country_code
        , customers.subscription_plan
        , products.product_category
    from orders
    left join customers on orders.customer_sk_id = customers.customer_sk_id
    left join products on orders.product_sk_id = products.product_sk_id
)

select * from joined
