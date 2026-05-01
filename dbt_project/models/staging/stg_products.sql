with source as (
    select * from {{ source('raw', 'products') }}
),

renamed as (
    select
        cast(product_id as string)       as product_id,
        name                             as name,
        lower(category)                  as category,
        cast(unit_price_cents as numeric) as unit_price_cents,
        cast(is_active as string)        as is_active
    from source
    where product_id is not null
)

select * from renamed
