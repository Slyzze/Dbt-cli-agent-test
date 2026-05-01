{{ config(
    materialized = 'table',
    schema       = 'datamart_01_core',
    tags         = ['dimension']
) }}

with src as (
    select * from {{ ref('stg_customers') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['customer_id']) }} as customer_sk_id,
    customer_id                                              as customer_nk,
    email,
    country,
    plan,
    created_at,
    current_timestamp()                                      as dbt_loaded_at
from src
