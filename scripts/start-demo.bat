@echo off
echo 🚀 Starting Livestream Football Demo
echo ====================================

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker is not running. Please start Docker first.
    pause
    exit /b 1
)

echo 📦 Building and starting containers...
docker-compose up -d --build

echo ⏳ Waiting for services to start...
timeout /t 10 /nobreak >nul

echo 🔍 Checking service health...

REM Check backend health
curl -s http://localhost:3000/health >nul 2>&1
if errorlevel 1 (
    echo ❌ Backend API is not responding
) else (
    echo ✅ Backend API is running
)

REM Check SRS health
curl -s http://localhost:8080/api/v1/versions >nul 2>&1
if errorlevel 1 (
    echo ❌ SRS Server is not responding
) else (
    echo ✅ SRS Server is running
)

echo.
echo 🎯 Demo URLs:
echo =============
echo Frontend:     http://localhost:3001
echo Backend API:  http://localhost:3000
echo SRS Server:   http://localhost:8080
echo HLS Stream:   http://localhost:8000/live/[stream_key].m3u8
echo.

echo 👤 Demo Credentials:
echo ===================
echo Username: demo
echo Password: demo123
echo Stream Key: demo-stream-key-123
echo.

echo 📡 RTMP URLs for OBS:
echo =====================
echo Server: rtmp://localhost:1935/live
echo Stream Key: demo-stream-key-123
echo.

echo 🔧 Next Steps:
echo ==============
echo 1. Open http://localhost:3001 in your browser
echo 2. Login with demo credentials
echo 3. Create a new stream or use the demo stream key
echo 4. Configure OBS Studio with the RTMP settings above
echo 5. Start streaming and watch at: http://localhost:3001/stream/demo-stream-key-123
echo.

echo 📋 Useful Commands:
echo ===================
echo View logs:        docker-compose logs -f
echo Stop services:    docker-compose down
echo Restart:          docker-compose restart
echo Create demo user: scripts\create-demo-user.bat
echo.

echo 🎉 Demo is ready! Happy streaming!
pause
