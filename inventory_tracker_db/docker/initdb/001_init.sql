CREATE EXTENSION IF NOT EXISTS pgcrypto;

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

CREATE UNIQUE INDEX IF NOT EXISTS ux_products_sku_not_null
ON products (sku)
WHERE sku IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_products_updated_at
ON products (updated_at DESC);

CREATE INDEX IF NOT EXISTS ix_products_name
ON products (name);
