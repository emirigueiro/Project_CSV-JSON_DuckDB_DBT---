
    
    

with child as (
    select order_date as from_field
    from "warehouse"."marts"."fct_orders"
    where order_date is not null
),

parent as (
    select date_day as to_field
    from "warehouse"."marts"."dim_date"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


