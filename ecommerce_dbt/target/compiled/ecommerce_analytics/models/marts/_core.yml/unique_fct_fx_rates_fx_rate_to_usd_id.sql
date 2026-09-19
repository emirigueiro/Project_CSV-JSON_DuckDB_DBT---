
    
    

select
    fx_rate_to_usd_id as unique_field,
    count(*) as n_records

from "warehouse"."marts"."fct_fx_rates"
where fx_rate_to_usd_id is not null
group by fx_rate_to_usd_id
having count(*) > 1


