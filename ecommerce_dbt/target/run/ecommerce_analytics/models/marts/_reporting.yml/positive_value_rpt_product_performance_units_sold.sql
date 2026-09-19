
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  

select *
from "warehouse"."marts"."rpt_product_performance"
where units_sold <= 0


  
  
      
    ) dbt_internal_test