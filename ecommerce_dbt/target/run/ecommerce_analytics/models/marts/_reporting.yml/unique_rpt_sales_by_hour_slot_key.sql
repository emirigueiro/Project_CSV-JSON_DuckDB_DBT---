
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    slot_key as unique_field,
    count(*) as n_records

from "warehouse"."marts"."rpt_sales_by_hour"
where slot_key is not null
group by slot_key
having count(*) > 1



  
  
      
    ) dbt_internal_test