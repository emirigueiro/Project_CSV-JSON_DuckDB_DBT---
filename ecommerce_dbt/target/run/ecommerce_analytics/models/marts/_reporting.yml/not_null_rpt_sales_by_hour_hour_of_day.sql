
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select hour_of_day
from "warehouse"."marts"."rpt_sales_by_hour"
where hour_of_day is null



  
  
      
    ) dbt_internal_test