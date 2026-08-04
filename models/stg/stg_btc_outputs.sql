
{{config(
    materialized='incremental',
    incremental_strategy='append'
   
)}}

WITH flattened_outputs AS (
select
    t.HASH_KEY,
    t.block_number,
    t.BLOCK_TIMESTAMP,
    t.is_coinbase,
    f.value:address::string as address,
    f.value:value::float as output_value
from {{ref('stg_btc')}} t,
lateral flatten(input => outputs) f

where f.value:address is not null
  {% if is_incremental() %}
    AND t.BLOCK_TIMESTAMP >= (SELECT max(t.BLOCK_TIMESTAMP) FROM {{ this }} t)
  {% endif %}
)
select 
    hash_key,
    block_number,
    BLOCK_TIMESTAMP,
    is_coinbase,
    address,
    output_value
from flattened_outputs