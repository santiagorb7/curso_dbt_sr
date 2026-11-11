{# =============================================================================
   grant_select_on_gold(role, dry_run=true)  ·  macro para dbt run-operation
   =============================================================================
   Concede lectura sobre los schemas de consumo de Gold a un rol:
     dbt run-operation grant_select_on_gold --args '{role: REPORTING_ROLE}'
   Por defecto (dry_run=true) solo muestra las sentencias en el log. Para
   ejecutarlas de verdad:
     dbt run-operation grant_select_on_gold --args '{role: REPORTING_ROLE, dry_run: false}'
   El nombre de cada schema se resuelve con generate_schema_name, así que en
   desarrollo apunta a tus schemas personales y en PRO a los definitivos.
   Día 8: compara este enfoque imperativo con la config declarativa +grants.
   ============================================================================= #}
{% macro grant_select_on_gold(role, dry_run=true) %}

    {% set database = env_var('DBT_GOLD_DB') %}

    {% for custom_schema in ['core', 'marketing', 'product'] %}
        {% set schema = generate_schema_name(custom_schema, none) | trim %}
        {% set statements = [
            'grant usage on database ' ~ database ~ ' to role ' ~ role,
            'grant usage on schema ' ~ database ~ '.' ~ schema ~ ' to role ' ~ role,
            'grant select on all tables in schema ' ~ database ~ '.' ~ schema ~ ' to role ' ~ role,
            'grant select on all views in schema ' ~ database ~ '.' ~ schema ~ ' to role ' ~ role
        ] %}
        {% for sql in statements %}
            {% if dry_run %}
                {{ log('[dry_run] ' ~ sql, info=True) }}
            {% else %}
                {% do run_query(sql) %}
                {{ log('Ejecutado: ' ~ sql, info=True) }}
            {% endif %}
        {% endfor %}
    {% endfor %}

{% endmacro %}
