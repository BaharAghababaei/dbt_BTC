WITH WHALES AS(
select
    address,
    sum(output_value) as total_sent,
    count(*) as total_count
from {{ref('stg_btc_transactions')}}

where output_value>10

group by address
order by total_sent desc
)
select 
    w.address,
    w.total_sent,
    w.total_count
from WHALES w
