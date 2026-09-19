-- Dimensión de clientes. Grano: un registro por cliente.

select
    customer_id,
    customer_name,
    email,
    country,
    registered_at

from "warehouse"."staging"."stg_customers"