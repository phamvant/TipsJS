CREATE DATABASE "dev" WITH OWNER "thuan";
GRANT ALL PRIVILEGES ON DATABASE "dev" TO "thuan";
-- \ connect "dev";
CREATE SCHEMA app_schema AUTHORIZATION "thuan";
GRANT CREATE,
  USAGE ON SCHEMA app_schema TO "thuan";
GRANT USAGE,
  SELECT ON ALL SEQUENCES IN SCHEMA app_schema to "thuan";
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA app_schema to "thuan";