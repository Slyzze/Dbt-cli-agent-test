with source as (
    select * from {{ source('raw', 'customers') }}
),

renamed as (
    select
        cast(customer_id as string)   as customer_id,
        lower(email)                  as email,
        upper(country)                as country,
        lower(plan)                   as plan,
        cast(created_at as timestamp) as created_at
    from source
    where customer_id is not null
)

select * from renamed
