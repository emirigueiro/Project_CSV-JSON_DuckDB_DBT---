-- un registro por moneda + fecha de tasa.


select
    fx_rate_to_usd_id,
    currency_code,
    rate_date,
    rate_to_usd,
    fx_rate_source,
    valid_from,
    valid_to

from {{ ref('int_fx_rates_to_usd') }}
