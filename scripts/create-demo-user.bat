@echo off
echo 👤 Creating Demo User and Stream Key
echo ====================================

REM Wait for database to be ready
echo ⏳ Waiting for database to be ready...
timeout /t 5 /nobreak >nul

REM Create demo user
echo 📝 Creating demo user...
docker-compose exec -T postgres psql -U postgres -d livestream_db -c "INSERT INTO users (username, email, password_hash, role) VALUES ('demo', 'demo@example.com', '\$2a\$10\$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user') ON CONFLICT (username) DO NOTHING;"

REM Create demo stream key
echo 🎬 Creating demo stream key...
docker-compose exec -T postgres psql -U postgres -d livestream_db -c "INSERT INTO stream_keys (key, user_id, name, description, is_active) VALUES ('demo-stream-key-123', (SELECT id FROM users WHERE username = 'demo'), 'Demo Football Match', 'Demo stream for testing the livestream system', true) ON CONFLICT (key) DO NOTHING;"

echo ✅ Demo data created successfully!
echo.
echo 📋 Demo Information:
echo ===================
docker-compose exec -T postgres psql -U postgres -d livestream_db -c "SELECT u.username, u.email, sk.key as stream_key, sk.name as stream_name, sk.description, sk.is_active, 'rtmp://localhost:1935/live/' || sk.key as rtmp_url, 'http://localhost:8000/live/' || sk.key || '.m3u8' as hls_url FROM users u JOIN stream_keys sk ON u.id = sk.user_id WHERE u.username = 'demo';"

echo.
echo 🎯 You can now:
echo 1. Login at http://localhost:3001 with username: demo, password: demo123
echo 2. Use stream key 'demo-stream-key-123' in OBS Studio
echo 3. Stream to rtmp://localhost:1935/live
echo 4. Watch at http://localhost:3001/stream/demo-stream-key-123
pause
