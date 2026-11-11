{{
    config(
        materialized='incremental',
        incremental_strategy='microbatch',
        event_time='event_at_utc',
        batch_size='month',
        begin='2020-01-01',
        lookback=1
    )
}}

-- =============================================================================
-- fct_events  ·  incremental microbatch (día 5)
-- =============================================================================
-- Hechos de eventos de navegación. Grano: una fila por evento.
-- Con microbatch no escribimos is_incremental() ni el filtro de fechas: dbt
-- parte la carga en lotes (batch_size) según event_time y, como el modelo
-- padre (slv_sql_server_dbo__events) también declara event_time, filtra
-- automáticamente cada lote al leer de él.
--   - begin: desde cuándo se construye en la primera carga o --full-refresh.
--   - lookback=1: reprocesa también el lote anterior al actual.
--   - Reprocesar un periodo concreto:
--       dbt run --select fct_events --event-time-start 2024-01-01 --event-time-end 2024-02-01
-- Cada lote es una query independiente: si falla uno, se puede reintentar
-- solo ese con dbt retry.
-- =============================================================================

with events as (
    select * from {{ ref('slv_sql_server_dbo__events') }}
),

final as (
    select
          event_id
        , session_id
        , user_id
        , product_id
        , order_id
        , event_type
        , page_url
        , created_at_utc                            as event_at_utc
        , date_load
    from events
)

select * from final
