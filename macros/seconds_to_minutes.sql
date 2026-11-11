{# =============================================================================
   seconds_to_minutes(column_name, decimals=2)  ·  día 4
   =============================================================================
   Convierte una columna en segundos a minutos, redondeando a `decimals`.
   Una macro devuelve TEXTO (SQL): dbt la sustituye al compilar.
     {{ seconds_to_minutes('s.session_duration_seconds') }}
   compila a
     round(s.session_duration_seconds / 60, 2)
   ============================================================================= #}
{% macro seconds_to_minutes(column_name, decimals=2) -%}
    round({{ column_name }} / 60, {{ decimals }})
{%- endmacro %}
