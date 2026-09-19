-- Dimensión de hora del día. Grano: un registro por hora (0-23).
-- Agrupa las horas en franjas para un análisis más robusto con muestras chicas.
-- La zona horaria de los timestamps no está documentada en el origen.

select
    hour_of_day,
    lpad(cast(hour_of_day as varchar), 2, '0') || ':00'     as hour_label,
    case
        when hour_of_day between 0  and 5  then '1. Early morning (00-05)'
        when hour_of_day between 6  and 11 then '2. Morning (06-11)'
        when hour_of_day between 12 and 17 then '3. Afternoon (12-17)'
        else                                    '4. Evening (18-23)'
    end                                                     as daypart

from generate_series(0, 23) as t(hour_of_day)