-- un registro por currency_code.
-- Incluye toda moneda:   órdenes, líneas o tasas, también los
-- códigos inválidos del origen (XYZ, ABC, QWE) 

with codes as (

    select currency_code from {{ ref('stg_orders') }}
    union
    select currency_code from {{ ref('stg_order_items') }}
    union
    select currency_code from {{ ref('int_fx_rates_to_usd') }}

),

with_rates as (

    select distinct currency_code
    from {{ ref('int_fx_rates_to_usd') }}

)

select
    codes.currency_code,
    with_rates.currency_code is not null     AS has_fx_rate,
    with_rates.currency_code is not null   AS is_valid_currency,
    codes.currency_code = 'USD'             AS is_reporting_currency

from codes
left join with_rates
    on with_rates.currency_code = codes.currency_code
