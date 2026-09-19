
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select orders
from "warehouse"."marts"."rpt_sales_by_hour"
where orders is null



  
  
      
    ) dbt_internal_test