#!/bin/bash
set -euo pipefail

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  CREATE SCHEMA IF NOT EXISTS oltp;

  CREATE TABLE IF NOT EXISTS oltp.customers (
    customer_id SERIAL PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    country TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

  CREATE TABLE IF NOT EXISTS oltp.products (
    product_id SERIAL PRIMARY KEY,
    sku TEXT NOT NULL UNIQUE,
    product_name TEXT NOT NULL,
    category TEXT NOT NULL,
    price NUMERIC(12,2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

  CREATE TABLE IF NOT EXISTS oltp.orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES oltp.customers(customer_id),
    order_status TEXT NOT NULL,
    order_total NUMERIC(12,2) NOT NULL,
    ordered_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

  CREATE TABLE IF NOT EXISTS oltp.order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES oltp.orders(order_id),
    product_id INTEGER NOT NULL REFERENCES oltp.products(product_id),
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(12,2) NOT NULL
  );

  INSERT INTO oltp.customers (first_name, last_name, email, country)
  VALUES
    ('Ava', 'Turner', 'ava.turner@northstyle.local', 'UK'),
    ('Noah', 'Reed', 'noah.reed@northstyle.local', 'US'),
    ('Mia', 'Patel', 'mia.patel@northstyle.local', 'CA'),
    ('Leo', 'Evans', 'leo.evans@northstyle.local', 'DE')
  ON CONFLICT (email) DO NOTHING;

  INSERT INTO oltp.products (sku, product_name, category, price)
  VALUES
    ('NS-JKT-001', 'Northstyle Quilted Jacket', 'Outerwear', 149.00),
    ('NS-KNT-002', 'Northstyle Merino Knit', 'Knitwear', 89.00),
    ('NS-BTS-003', 'Northstyle Leather Boots', 'Footwear', 179.00),
    ('NS-BAG-004', 'Northstyle Canvas Tote', 'Accessories', 45.00)
  ON CONFLICT (sku) DO NOTHING;

  INSERT INTO oltp.orders (customer_id, order_status, order_total, ordered_at)
  VALUES
    (1, 'paid', 238.00, NOW() - INTERVAL '3 days'),
    (2, 'paid', 149.00, NOW() - INTERVAL '2 days'),
    (3, 'shipped', 224.00, NOW() - INTERVAL '1 day'),
    (4, 'processing', 45.00, NOW())
  ON CONFLICT DO NOTHING;

  INSERT INTO oltp.order_items (order_id, product_id, quantity, unit_price)
  VALUES
    (1, 2, 1, 89.00),
    (1, 4, 1, 45.00),
    (1, 1, 1, 104.00),
    (2, 1, 1, 149.00),
    (3, 3, 1, 179.00),
    (3, 4, 1, 45.00),
    (4, 4, 1, 45.00)
  ON CONFLICT DO NOTHING;

  DO $$
  BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '${AIRBYTE_CDC_USER}') THEN
      EXECUTE format('CREATE ROLE %I WITH LOGIN PASSWORD %L REPLICATION', '${AIRBYTE_CDC_USER}', '${AIRBYTE_CDC_PASSWORD}');
    END IF;
  END
  $$;

  GRANT CONNECT ON DATABASE ${POSTGRES_DB} TO ${AIRBYTE_CDC_USER};
  GRANT USAGE ON SCHEMA oltp TO ${AIRBYTE_CDC_USER};
  GRANT SELECT ON ALL TABLES IN SCHEMA oltp TO ${AIRBYTE_CDC_USER};
  ALTER DEFAULT PRIVILEGES IN SCHEMA oltp GRANT SELECT ON TABLES TO ${AIRBYTE_CDC_USER};

  DROP PUBLICATION IF EXISTS airbyte_publication;
  CREATE PUBLICATION airbyte_publication FOR TABLE
    oltp.customers,
    oltp.products,
    oltp.orders,
    oltp.order_items;
EOSQL
