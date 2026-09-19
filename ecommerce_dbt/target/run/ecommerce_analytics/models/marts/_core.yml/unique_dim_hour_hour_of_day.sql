
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    hour_of_day as unique_field,
    count(*) as n_records

from "warehouse"."marts"."dim_hour"
where hour_of_day is not null
group by hour_of_day
having count(*) > 1



  
  
      
    ) dbt_internal_test