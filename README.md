# northstyle

Lean local EL stack for a Postgres OLTP source and Airbyte CDC into Snowflake raw.

## What is in this repo

- A custom Postgres Docker image pinned to `postgres:18.4`, which is the current `latest` stable tag on the Docker official image page as verified on June 27, 2026.
- A self-managed Airbyte stack pinned to `v2.0.0`, which GitHub lists as the latest Airbyte release on the releases page opened on June 27, 2026.
- Snowflake SQL templates for the warehouse, database, schemas, role, and Airbyte service user.

There is no dbt, Airflow, or anything else in this repo.

## Start the stack

1. Review `.env` and change the default passwords before using this outside a throwaway local setup.
2. Run `docker compose up --build -d`.
3. Open Airbyte at `http://localhost:8000`.

## Local connection details

### Postgres source

- Host from your laptop: `localhost`
- Port from your laptop: `5433`
- Database: `northstyle`
- App user: `northstyle`
- CDC user for Airbyte: `airbyte_cdc`

### Postgres source settings inside Airbyte

Use these values when creating the Postgres source connector in Airbyte:

- Host: `postgres-oltp`
- Port: `5432`
- Database: `northstyle`
- Username: `airbyte_cdc`
- Password: the value of `AIRBYTE_CDC_PASSWORD` in `.env`
- SSL mode: `disable`
- Replication method: `CDC`
- Publication: `airbyte_publication`

The Postgres container starts with logical replication enabled and pre-creates the publication Airbyte needs for CDC.

## Snowflake setup

Run the SQL files in `snowflake/` in this order:

1. `01_create_infra.sql`
2. `02_create_airbyte_user_password.sql` or `03_create_airbyte_user_keypair.sql`

Recommended Airbyte Snowflake destination values:

- Warehouse: `NORTHSTYLE_ELT_WH`
- Database: `NORTHSTYLE_RAW`
- Schema: `RAW`
- Airbyte internal table dataset: `AIRBYTE_INTERNAL`
- Username: `AIRBYTE_NORTHSTYLE`

If you choose key-pair auth, generate a PKCS#8 private key for Airbyte and set the public key on the Snowflake user before saving the destination.

## Notes

- The sample OLTP tables live in the `oltp` schema.
- This repo uses Docker named volumes for both Postgres and Airbyte state.
- Airbyte basic auth defaults to `airbyte` / `airbyte` in `.env`.
