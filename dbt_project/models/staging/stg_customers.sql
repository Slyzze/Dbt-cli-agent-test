with source as (
    select *
    from {{ source('raw', 'customers') }}
)

, renamed as (
    select
        customer_id as customer_nk_id
        , lower(email) as email_address
        , upper(country) as country_code
        , lower(plan) as subscription_plan
        , cast(created_at as timestamp) as created_at
    from source
    where customer_id is not null
)

select * from renamed
