-- Initial database setup script
-- This script runs when the PostgreSQL container starts for the first time

-- Create database if not exists
CREATE DATABASE livestream_db;

-- Connect to the database
\c livestream_db;

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create stream_keys table
CREATE TABLE IF NOT EXISTS stream_keys (
    id SERIAL PRIMARY KEY,
    key VARCHAR(255) UNIQUE NOT NULL,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create streams table
CREATE TABLE IF NOT EXISTS streams (
    id SERIAL PRIMARY KEY,
    stream_key_id INTEGER REFERENCES stream_keys(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'offline',
    viewer_count INTEGER DEFAULT 0,
    started_at TIMESTAMP,
    ended_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_stream_keys_key ON stream_keys(key);
CREATE INDEX IF NOT EXISTS idx_stream_keys_user_id ON stream_keys(user_id);
CREATE INDEX IF NOT EXISTS idx_streams_stream_key_id ON streams(stream_key_id);
CREATE INDEX IF NOT EXISTS idx_streams_status ON streams(status);

-- Insert demo user
INSERT INTO users (username, email, password_hash, role) 
VALUES (
    'demo', 
    'demo@example.com', 
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- password: demo123
    'user'
) ON CONFLICT (username) DO NOTHING;

-- Insert demo stream key
INSERT INTO stream_keys (key, user_id, name, description, is_active)
VALUES (
    'demo-stream-key-123',
    (SELECT id FROM users WHERE username = 'demo'),
    'Demo Football Match',
    'Demo stream for testing the livestream system',
    true
) ON CONFLICT (key) DO NOTHING;

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_stream_keys_updated_at BEFORE UPDATE ON stream_keys
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_streams_updated_at BEFORE UPDATE ON streams
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Grant permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO postgres;
