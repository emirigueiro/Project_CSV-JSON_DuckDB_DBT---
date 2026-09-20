{#
  Test genérico propio: falla si la columna tiene valores <= 0.
  Uso en YAML:  data_tests: [positive_value]
#}
{% test positive_value(model, column_name) %}

select *
from {{ model }}
where {{ column_name }} <= 0

{% endtest %}
