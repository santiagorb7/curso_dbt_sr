{{
    config(
        materialized='incremental',
        incremental_strategy='delete+insert',
        unique_key='event_id',
        on_schema_change='append_new_columns',
        event_time='created_at_utc'
    )
}}

-- =============================================================================
-- slv_sql_server_dbo__events
-- =============================================================================
-- Versión del día 5. Cambios respecto al día 2:
--   - lookback de 1 hora: se vuelven a leer las filas de la última hora ya
--     cargada para recoger datos que llegaron tarde. El merge por event_id
--     evita duplicados al reprocesarlas.
--   - on_schema_change='append_new_columns': si stg añade columnas, se añaden
--     a la tabla. El valor por defecto es 'ignore' (las ignora en silencio).
--   - event_time: declara la columna temporal para que los modelos microbatch
--     que lean de aquí (fct_events) filtren cada lote automáticamente.
-- =============================================================================

with events as (
    select * from {{ ref('stg_sql_server_dbo__events') }}
    where not is_deleted
    {% if is_incremental() %}
      and date_load >= (select dateadd('hour', -1, max(date_load)) from {{ this }})
    {% endif %}
),

deduplicated as (
    select
          event_id
        , session_id
        , user_id
        , page_url
        , event_type
        , order_id
        , product_id
        , created_at_utc
        , date_load
    from events
    qualify row_number() over (partition by event_id order by date_load desc) = 1
)

select * from deduplicated
