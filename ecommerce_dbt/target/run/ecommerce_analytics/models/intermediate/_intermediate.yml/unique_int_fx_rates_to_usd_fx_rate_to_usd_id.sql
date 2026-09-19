
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    fx_rate_to_usd_id as unique_field,
    count(*) as n_records

from "warehouse"."intermediate"."int_fx_rates_to_usd"
where fx_rate_to_usd_id is not null
group by fx_rate_to_usd_id
having count(*) > 1



  
  
      
    ) dbt_internal_test