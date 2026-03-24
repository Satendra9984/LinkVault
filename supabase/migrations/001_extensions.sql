-- 001_extensions.sql
-- Required extensions for UUID generation.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Optional (only if your tooling requires it):
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

