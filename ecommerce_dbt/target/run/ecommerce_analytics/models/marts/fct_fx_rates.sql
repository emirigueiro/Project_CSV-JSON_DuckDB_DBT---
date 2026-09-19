
    

    create  table
      "warehouse"."marts"."fct_fx_rates__dbt_tmp"
  
    
    as (
      -- Hecho de tasas de cambio. Grano: un registro por moneda + fecha de tasa.
-- Permite analizar la evolución de las tasas y cruzarla con el revenue
-- a través de las dimensiones conformadas dim_currencies y dim_date.

select
    fx_rate_to_usd_id,
    currency_code,
    rate_date,
    rate_to_usd,
    fx_rate_source,
    valid_from,
    valid_to

from "warehouse"."intermediate"."int_fx_rates_to_usd"
    );
    
  