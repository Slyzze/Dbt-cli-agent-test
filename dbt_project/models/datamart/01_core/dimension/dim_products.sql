{{ config(
    materialized = 'table',
    schema       = 'datamart_01_core',
    tags         = ['dimension']
) }}

with src as (
    select * from {{ ref('stg_products') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['product_id']) }} as product_sk_id,
    product_id                                              as product_nk,
    name,
    category,
    unit_price_cents / 100.0                                as unit_price_usd,
    is_active,
    current_timestamp()                                     as dbt_loaded_at
from src
