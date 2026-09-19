
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        fx_rate_source as value_field,
        count(*) as n_records

    from "warehouse"."intermediate"."int_fx_rates_to_usd"
    group by fx_rate_source

)

select *
from all_values
where value_field not in (
    'identity','direct','inverse'
)



  
  
      
    ) dbt_internal_test