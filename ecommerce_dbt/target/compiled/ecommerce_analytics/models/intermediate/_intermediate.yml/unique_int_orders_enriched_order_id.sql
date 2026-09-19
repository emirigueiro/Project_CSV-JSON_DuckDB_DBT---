
    
    

select
    order_id as unique_field,
    count(*) as n_records

from "warehouse"."intermediate"."int_orders_enriched"
where order_id is not null
group by order_id
having count(*) > 1


