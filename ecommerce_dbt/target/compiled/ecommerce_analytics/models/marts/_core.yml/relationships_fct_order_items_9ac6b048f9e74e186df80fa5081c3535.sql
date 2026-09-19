
    
    

with child as (
    select currency_code as from_field
    from "warehouse"."marts"."fct_order_items"
    where currency_code is not null
),

parent as (
    select currency_code as to_field
    from "warehouse"."marts"."dim_currencies"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


