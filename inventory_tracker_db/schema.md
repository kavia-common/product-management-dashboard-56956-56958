# Inventory Tracker DB Schema (PostgreSQL)

This container stores product inventory data.

## Design goals

- Simple CRUD for products
- Strong constraints to prevent invalid inventory/price data
- Indexes for typical list/sort/search behavior
- Timestamps for auditing and live update payloads

## Entity: `products`

Fields (recommended):

- `id` (UUID, primary key)
- `name` (text, required)
- `description` (text, optional)
- `sku` (text, optional, unique when present)
- `quantity` (integer, required, >= 0)
- `unit_price_cents` (integer, required, >= 0) — store money as integer cents to avoid float issues
- `created_at` / `updated_at` (timestamptz)

## Create schema (execute statements one at a time)

> IMPORTANT: Per project rules, execute SQL statements one at a time using:
>
> `psql "postgresql://..." -c "SQL_STATEMENT"`

Connect using `db_connection.txt`, then run:

1) Enable uuid generation
```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;
```

2) Create products table
```sql
CREATE TABLE IF NOT EXISTS products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  sku TEXT,
  quantity INTEGER NOT NULL DEFAULT 0,
  unit_price_cents INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT products_name_not_blank CHECK (length(btrim(name)) > 0),
  CONSTRAINT products_quantity_non_negative CHECK (quantity >= 0),
  CONSTRAINT products_unit_price_non_negative CHECK (unit_price_cents >= 0)
);
```

3) SKU unique when present (allow multiple NULLs)
```sql
CREATE UNIQUE INDEX IF NOT EXISTS ux_products_sku_not_null
ON products (sku)
WHERE sku IS NOT NULL;
```

4) Support sorting by updated time
```sql
CREATE INDEX IF NOT EXISTS ix_products_updated_at
ON products (updated_at DESC);
```

5) Optional lightweight search on name
```sql
CREATE INDEX IF NOT EXISTS ix_products_name
ON products (name);
```

## Optional: keep `updated_at` current via trigger

If you want automatic updated_at management:

1) Create function
```sql
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

2) Create trigger
```sql
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'trg_products_set_updated_at'
  ) THEN
    CREATE TRIGGER trg_products_set_updated_at
    BEFORE UPDATE ON products
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();
  END IF;
END $$;
```
