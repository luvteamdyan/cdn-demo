-- Script to create demo user and stream key for testing
-- Run this after starting the application

-- Create demo user
INSERT INTO users (username, email, password_hash, role) 
VALUES (
  'demo', 
  'demo@example.com', 
  '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- password: demo123
  'user'
) ON CONFLICT (username) DO NOTHING;

-- Create demo stream key
INSERT INTO stream_keys (key, user_id, name, description, is_active)
VALUES (
  'demo-stream-key-123',
  (SELECT id FROM users WHERE username = 'demo'),
  'Demo Football Match',
  'Demo stream for testing the livestream system',
  true
) ON CONFLICT (key) DO NOTHING;

-- Show created data
SELECT 
  u.username,
  u.email,
  sk.key as stream_key,
  sk.name as stream_name,
  sk.description,
  sk.is_active,
  'rtmp://localhost:1935/live/' || sk.key as rtmp_url,
  'http://localhost:8000/live/' || sk.key || '.m3u8' as hls_url
FROM users u
JOIN stream_keys sk ON u.id = sk.user_id
WHERE u.username = 'demo';
