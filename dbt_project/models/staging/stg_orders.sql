with source as (
    select * from {{ source('raw', 'orders') }}
),

renamed as (
    select
        cast(order_id as string)        as order_id,
        cast(customer_id as string)     as customer_id,
        cast(product_id as string)      as product_id,
        lower(status)                   as status,
        cast(amount_cents as numeric)   as amount_cents,
        cast(discount_cents as numeric) as discount_cents,
        lower(channel)                  as channel,
        cast(created_at as timestamp)   as created_at,
        cast(updated_at as timestamp)   as updated_at
    from source
    where order_id is not null
)

select * from renamed
