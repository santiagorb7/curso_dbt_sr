{# =============================================================================
   generate_schema_name(custom_schema_name, node)  ·  día 6
   =============================================================================
   Sobrescribe la macro de dbt que decide el schema de cada objeto.
   - Entornos de despliegue (target dev, pre, pro): se usa el schema de la
     carpeta tal cual (core, marketing...), porque cada entorno ya tiene su
     propia database.
   - Desarrollo (IDE): <tu_schema>_<schema>, para que cada alumno trabaje en
     sus propios schemas sin pisar a los demás.
   - Sin schema personalizado: el schema del target.
   ============================================================================= #}
{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}

    {%- if custom_schema_name is none -%}
        {{ default_schema }}
    {%- elif target.name | lower in ['dev', 'pre', 'pro'] -%}
        {{ custom_schema_name | trim }}
    {%- else -%}
        {{ default_schema }}_{{ custom_schema_name | trim }}
    {%- endif -%}

{%- endmacro %}
