-- migrate:up
CREATE TABLE users (
  id text PRIMARY KEY,
  name text NOT NULL,
  role text NOT NULL CHECK (role IN ('shopper', 'admin')),
  login text UNIQUE,
  password_hash text
);

CREATE TABLE products (
  id text PRIMARY KEY,
  name text NOT NULL,
  packaging text NOT NULL
);

CREATE TABLE stores (
  id text PRIMARY KEY,
  name text NOT NULL,
  latitude double precision NOT NULL,
  longitude double precision NOT NULL
);

-- Novac je ceo broj dinara, isto kao u domenu i na mrezi.
CREATE TABLE prices (
  id text PRIMARY KEY,
  product_id text NOT NULL REFERENCES products (id),
  store_id text NOT NULL REFERENCES stores (id),
  price int NOT NULL CHECK (price BETWEEN 1 AND 100000),
  status text NOT NULL CHECK (status IN ('pending', 'approved', 'rejected')),
  updated_at timestamptz NOT NULL,
  reported_by text REFERENCES users (id)
);

CREATE INDEX prices_by_update ON prices (updated_at DESC, id);

CREATE TABLE shopping_lists (
  id text PRIMARY KEY,
  name text NOT NULL CHECK (char_length(name) BETWEEN 1 AND 40),
  status text NOT NULL CHECK (status IN ('preparing', 'ready', 'shopping', 'completed')),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE list_members (
  list_id text NOT NULL REFERENCES shopping_lists (id) ON DELETE CASCADE,
  user_id text NOT NULL REFERENCES users (id),
  seq bigint GENERATED ALWAYS AS IDENTITY,
  PRIMARY KEY (list_id, user_id)
);

CREATE INDEX list_members_by_user ON list_members (user_id);

-- Jedan red po proizvodu (pakovanju) na listi: dva clana ne mogu da naprave duplikat.
-- Granica kolicine je i ovde, kao poslednja zastita iza pravila na serveru.
CREATE TABLE list_items (
  list_id text NOT NULL REFERENCES shopping_lists (id) ON DELETE CASCADE,
  product_id text NOT NULL REFERENCES products (id),
  quantity int NOT NULL CHECK (quantity BETWEEN 1 AND 99),
  bought boolean NOT NULL DEFAULT false,
  seq bigint GENERATED ALWAYS AS IDENTITY,
  PRIMARY KEY (list_id, product_id)
);

-- migrate:down
DROP TABLE list_items;
DROP TABLE list_members;
DROP TABLE shopping_lists;
DROP TABLE prices;
DROP TABLE stores;
DROP TABLE products;
DROP TABLE users;
