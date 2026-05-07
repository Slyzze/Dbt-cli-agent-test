with orders as (
    select * from {{ ref('stg_orders') }}
)

, prep as (
    select
        {{ dbt_utils.generate_surrogate_key(['order_nk_id']) }} as order_sk_id
        , {{ dbt_utils.generate_surrogate_key(['customer_nk_id']) }} as customer_sk_id
        , {{ dbt_utils.generate_surrogate_key(['product_nk_id']) }} as product_sk_id
        , order_nk_id
        , customer_nk_id
        , product_nk_id
        , order_status
        , acquisition_channel
        , amount_cents
        , discount_cents
        -- Business Rule 1 & 2: Revenue conversion and exclusion of cancelled orders
        , case 
            when order_status = 'cancelled' then 0 
            else (amount_cents - discount_cents) / 100.0 
          end as revenue_usd
        , created_at
        , updated_at
    from orders
)

select * from prep
