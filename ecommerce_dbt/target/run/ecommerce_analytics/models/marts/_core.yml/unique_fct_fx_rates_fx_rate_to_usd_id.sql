
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    fx_rate_to_usd_id as unique_field,
    count(*) as n_records

from "warehouse"."marts"."fct_fx_rates"
where fx_rate_to_usd_id is not null
group by fx_rate_to_usd_id
having count(*) > 1



  
  
      
    ) dbt_internal_test