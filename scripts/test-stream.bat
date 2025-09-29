@echo off
echo 🧪 Testing Livestream Functionality
echo ====================================

set STREAM_KEY=demo-stream-key-123

echo 📡 Testing Components:
echo.

REM Test Backend API
echo 1. Testing Backend API...
curl -s http://localhost:3000/health | findstr "OK" >nul
if errorlevel 1 (
    echo    ❌ Backend API is not responding
) else (
    echo    ✅ Backend API is healthy
)

REM Test SRS Server
echo 2. Testing SRS Server...
curl -s http://localhost:8080/api/v1/versions | findstr "major" >nul
if errorlevel 1 (
    echo    ❌ SRS Server is not responding
) else (
    echo    ✅ SRS Server is running
)

REM Test Database
echo 3. Testing Database...
docker-compose exec -T postgres psql -U postgres -d livestream_db -c "SELECT COUNT(*) FROM users;" >nul 2>&1
if errorlevel 1 (
    echo    ❌ Database connection failed
) else (
    echo    ✅ Database is connected
)

REM Test Frontend
echo 4. Testing Frontend...
curl -s http://localhost:3001 | findstr "root" >nul
if errorlevel 1 (
    echo    ❌ Frontend is not responding
) else (
    echo    ✅ Frontend is accessible
)

echo.
echo 🎯 Test URLs:
echo =============
echo Frontend:        http://localhost:3001
echo API Health:      http://localhost:3000/health
echo SRS API:         http://localhost:8080/api/v1/versions
echo HLS Stream:      http://localhost:8000/live/%STREAM_KEY%.m3u8
echo.

echo 📱 OBS Studio Configuration:
echo ============================
echo Server:          rtmp://localhost:1935/live
echo Stream Key:      %STREAM_KEY%
echo.

echo 🔧 Manual Tests:
echo ================
echo 1. Login to frontend with demo/demo123
echo 2. Create a new stream key
echo 3. Use OBS to stream to the RTMP URL above
echo 4. Check callback authentication in backend logs
echo 5. View stream in browser
echo.

echo 📋 Useful Commands:
echo ===================
echo View logs:       docker-compose logs -f
echo Restart:         docker-compose restart
echo Stop:            docker-compose down
echo Create demo:     scripts\create-demo-user.bat
echo.

echo ✅ All tests completed!
pause
