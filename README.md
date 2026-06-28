# northstyle dbt project

This repository now contains a dbt project for Snowflake with a simple three-layer model structure for the `northstyle.public.customers` source table.

## Structure

- `models/staging`: raw source definitions and light renaming/standardization
- `models/intermediate`: business-ready transformations
- `models/marts`: final analytics-facing models

## dbt Cloud connection

Configure your dbt Cloud environment to use Snowflake with:

- Database: `NORTHSTYLE`
- Warehouse: `COMPUTE_WH`
- Schema: `public`

This project assumes your raw Snowflake objects were created as quoted lowercase names, so dbt is configured to preserve the schema casing and to quote the `customers` source table identifier.

The `profile` name in [dbt_project.yml](./dbt_project.yml) is `northstyle`, which dbt Cloud will use when generating the runtime profile.

## Key models

- `stg_customers`
- `int_customers`
- `dim_customers`

## Suggested first run

```bash
dbt build --select dim_customers
```
