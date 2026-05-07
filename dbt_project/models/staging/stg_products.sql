with source as (
    select *
    from {{ source('raw', 'products') }}
)

, renamed as (
    select
        product_id as product_nk_id
        , name as product_name
        , lower(category) as product_category
        , cast(unit_price_cents as numeric) as unit_price_cents
        , cast(is_active as boolean) as is_active
    from source
    where product_id is not null
)

select * from renamed
