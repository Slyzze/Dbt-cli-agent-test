with source as (
    select *
    from {{ source('raw', 'orders') }}
)

, renamed as (
    select
        order_id as order_nk_id
        , customer_id as customer_nk_id
        , product_id as product_nk_id
        , lower(status) as order_status
        , cast(amount_cents as numeric) as amount_cents
        , cast(coalesce(discount_cents, 0) as numeric) as discount_cents
        , lower(channel) as acquisition_channel
        , cast(created_at as timestamp) as created_at
        , cast(updated_at as timestamp) as updated_at
    from source
    where order_id is not null
)

select * from renamed
