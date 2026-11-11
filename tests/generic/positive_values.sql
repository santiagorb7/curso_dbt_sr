{# =============================================================================
   Test genérico: positive_values  ·  día 4
   =============================================================================
   Falla con las filas en las que la columna es <= 0. Se usa en YAML igual
   que los tests de dbt:
     data_tests:
       - positive_values
   ============================================================================= #}
{% test positive_values(model, column_name) %}

select {{ column_name }}
from {{ model }}
where {{ column_name }} <= 0

{% endtest %}
