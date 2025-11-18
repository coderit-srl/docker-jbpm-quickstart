-- Initialize jBPM database
-- This file is executed automatically when the PostgreSQL container starts

-- The database 'jbpm' is already created by the POSTGRES_DB environment variable
-- Additional initialization can be added here if needed

-- Grant all privileges to jbpm user (already done by default, but explicit)
GRANT ALL PRIVILEGES ON DATABASE jbpm TO jbpm;

-- Set default schema permissions
\c jbpm;
GRANT ALL ON SCHEMA public TO jbpm;
