{# =============================================================================
   log_run_summary(results)  ·  se invoca desde on-run-end (dbt_project.yml)
   =============================================================================
   on-run-end recibe la variable `results` con el resultado de cada nodo.
   Esta macro solo escribe un resumen en el log y devuelve SQL vacío, de modo
   que no lanza ninguna query contra Snowflake.
   ============================================================================= #}
{% macro log_run_summary(results) %}
    {% if execute %}
        {% set ok = results | selectattr('status', 'in', ['success', 'pass']) | list | length %}
        {% set warn = results | selectattr('status', 'equalto', 'warn') | list | length %}
        {% set ko = results | selectattr('status', 'in', ['error', 'fail']) | list | length %}
        {{ log('Resumen [' ~ target.name ~ ']: ' ~ ok ~ ' OK, ' ~ warn ~ ' WARN, ' ~ ko ~ ' ERROR/FAIL', info=True) }}
    {% endif %}
{% endmacro %}
