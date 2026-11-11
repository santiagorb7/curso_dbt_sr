# curso_data_engineering

Proyecto dbt completo del Curso de Data Engineering (dbt + Snowflake) de Cívica.
Es el estado final del proyecto: incluye el material de todos los días y los
ficheros que los alumnos escriben en clase.

La arquitectura (Bronze → Silver → Gold) y el linaje se explican en
[docs/architecture.md](docs/architecture.md).

## Puesta en marcha

1. Variables de entorno (en dbt Platform: credenciales de desarrollo de cada
   alumno y variables de cada entorno):

   | Variable        | Uso                                            |
   |-----------------|------------------------------------------------|
   | `DBT_BRONZE_DB` | Database de Bronze (solo lectura, `source()`)  |
   | `DBT_SILVER_DB` | Database de Staging, Silver, seeds y snapshots |
   | `DBT_GOLD_DB`   | Database de Gold                               |

2. Instalar paquetes y construir todo:

   ```bash
   dbt deps
   dbt build
   ```

En local hace falta un `profiles.yml` con un perfil llamado `default`.

## Qué se ve cada día

| Día | Contenido | Dónde está en el proyecto |
|-----|-----------|---------------------------|
| 2 | Estructura Medallion, sources, staging, silver, gold, ephemeral, primer incremental | `models/`, `dbt_project.yml`, `int_order_items__priced`, `slv_sql_server_dbo__events` |
| 3 | Sources con freshness, data tests, paquetes (dbt_utils), docs blocks, seeds, tests singulares, unit tests, analyses | `_*__sources.yml`, `_*__models.yml`, `packages.yml`, `docs/`, `seeds/`, `tests/`, `analyses/` |
| 4 | Jinja y macros, pivot dinámico con `run_query`, tests genéricos propios | `macros/obtener_valores.sql`, `macros/seconds_to_minutes.sql`, `int_events__pivoted_by_session`, `tests/generic/positive_values.sql` |
| 5 | Snapshots (YAML y clásico), incremental con lookback y `on_schema_change`, microbatch | `snapshots/`, `slv_sql_server_dbo__events`, `fct_events` |
| 6 | Hooks (`pre_hook`, `post_hook`, `on-run-end`), variables, `generate_schema_name`, selectores | `dim_dates`, `macros/hooks/`, `vars` en `dbt_project.yml`, `macros/generate_schema_name.sql`, `selectors.yml` |
| 7 | `dbt run-operation` | `macros/operations/grant_select_on_gold.sql` |
| 8 | Contratos, versiones de modelo, groups y access, exposures | `dim_users_v1`/`dim_users_v2`, `_core__models.yml`, `models/_groups.yml`, `_marketing__exposures.yml` |

## Comandos útiles

```bash
dbt build --selector gold_marketing             # mart de Marketing y sus padres
dbt build --select tag:silver                   # solo Silver
dbt test --select test_type:unit                # solo unit tests
dbt source freshness                            # frescura de Bronze
dbt snapshot                                    # historial SCD2 del presupuesto
dbt run-operation grant_select_on_gold --args '{role: REPORTING_ROLE}'
dbt build --vars '{budget_start_date: 2025-01-01, low_stock_threshold: 20}'
```
