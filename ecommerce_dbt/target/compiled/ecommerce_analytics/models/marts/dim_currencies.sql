-- Dimensión de monedas. Grano: un registro por currency_code.
-- Incluye toda moneda que aparece en órdenes, líneas o tasas, también los
-- códigos inválidos del origen (XYZ, ABC, QWE) como miembros marcados, para
-- mantener la integridad referencial de los hechos.

with codes as (

    select currency_code from "warehouse"."staging"."stg_orders"
    union
    select currency_code from "warehouse"."staging"."stg_order_items"
    union
    select currency_code from "warehouse"."intermediate"."int_fx_rates_to_usd"

),

with_rates as (

    select distinct currency_code
    from "warehouse"."intermediate"."int_fx_rates_to_usd"

)

select
    codes.currency_code,
    with_rates.currency_code is not null        as has_fx_rate,
    with_rates.currency_code is not null        as is_valid_currency,
    codes.currency_code = 'USD'                 as is_reporting_currency

from codes
left join with_rates
    on with_rates.currency_code = codes.currency_code