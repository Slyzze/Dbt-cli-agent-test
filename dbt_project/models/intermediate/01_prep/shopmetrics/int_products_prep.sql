with products as (
    select * from {{ ref('stg_products') }}
)

, prep as (
    select
        {{ dbt_utils.generate_surrogate_key(['product_nk_id']) }} as product_sk_id
        , product_nk_id
        , product_name
        , product_category
        , unit_price_cents
        , is_active
    from products
)

select * from prep
