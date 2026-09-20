-- un registro por fecha + moneda origen + moneda destino.
-- Aplana las respuestas de la API: cada respuesta trae una moneda base y un


-- JSON {moneda_destino: tasa}. Se genera una fila por cada par de monedas.
-- `rate` = cuántas unidades de currency_to equivalen a 1 unidad de currency_from o eso creo .

with source as (  select * from {{ source('raw', 'fx_rates') }}

),

flattened as ( select
        upper(trim(source.base_currency))        as currency_from,
        upper(trim(t.currency_key))               as currency_to,
        cast(source.rate_date as date)           as rate_date,
        cast(source.rates ->> t.currency_key as decimal(18, 6)) as rate,
        source._loaded_at

    from source,
        unnest(json_keys(source.rates)) as t(currency_key)
),

final as (select
        currency_from || '_' || currency_to || '_' || strftime(rate_date, '%Y-%m-%d')
                                                    as fx_rate_id,
        *
 from flattened
)
select * from final
