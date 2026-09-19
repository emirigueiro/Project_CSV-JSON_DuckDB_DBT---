
    
    

select
    currency_code as unique_field,
    count(*) as n_records

from "warehouse"."marts"."dim_currencies"
where currency_code is not null
group by currency_code
having count(*) > 1


