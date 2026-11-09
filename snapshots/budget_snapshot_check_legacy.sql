{# =============================================================================
   Snapshot en formato clásico (bloque {% snapshot %}), para comparar con YAML
   =============================================================================
   Estrategia check: no hay columna de "última modificación" fiable, así que
   dbt compara los valores de check_cols y crea una versión nueva si cambian.
   En el formato clásico, target_schema/target_database se escriben aquí y NO
   pasan por generate_schema_name: el mismo schema en todos los entornos.
   ============================================================================= #}
{% snapshot budget_snapshot_check_legacy %}

{{
    config(
        target_database='DEV_SILVER_DB',
        target_schema='snapshots_legacy',
        unique_key='_row',
        strategy='check',
        check_cols=['product_id', 'quantity', 'month']
    )
}}

select * from {{ source('google_sheets', 'budget') }}

{% endsnapshot %}
