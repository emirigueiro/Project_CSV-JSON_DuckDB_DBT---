
  
  create view "warehouse"."intermediate"."int_fx_rates_to_usd__dbt_tmp" as (
    -- Grano: un registro por moneda + fecha de tasa.
-- Tasa a USD tomada directamente de la API (respuestas con rates.USD),
-- con rango de vigencia [valid_from, valid_to).

with direct_rates as (

    select
        currency_from                    as currency_code,
        rate_date,
        cast(rate as decimal(18, 6))        as rate_to_usd
    from "warehouse"."staging"."stg_fx_rates"
    where currency_to = 'USD'

),

with_validity as (

    select
        *,
        lead(rate_date) over (partition by currency_code order by rate_date)      as next_rate_date,
        row_number()   over (partition by currency_code order by rate_date) = 1   as is_first_rate
    from direct_rates

)

select
    currency_code || '_' || strftime(rate_date, '%Y-%m-%d')         as fx_rate_to_usd_id,
    currency_code,
    rate_date,
    rate_to_usd,
    case when is_first_rate then date '1900-01-01' else rate_date end   as valid_from,
    coalesce(next_rate_date, date '9999-12-31')              as valid_to
from with_validity
  );
