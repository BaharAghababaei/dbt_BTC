{{config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='HASH_KEY',
)}}
select *
from {{source('btc','btc')}}


{% if is_incremental() %}
WHERE BLOCK_TIMESTAMP >= (SELECT max(BLOCK_TIMESTAMP)FROM {{ this }})
{% endif %}


/*
    Uncomment the line below to remove records with null `id` values
*/

-- where id is not null
