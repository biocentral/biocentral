-- init-db.sql
CREATE DATABASE IF NOT EXISTS embeddings_db;

GRANT ALL PRIVILEGES ON DATABASE embeddings_db TO embeddingsuser;
GRANT ALL ON SCHEMA public TO embeddingsuser;