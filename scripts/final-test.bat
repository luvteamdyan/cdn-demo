@echo off
echo 🎉 FINAL TEST - Demo Livestream System
echo ======================================

REM Get local IP
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr /i "IPv4"') do (
    set LOCAL_IP=%%i
    set LOCAL_IP=!LOCAL_IP: =!
    goto :found_ip
)
:found_ip

echo Local IP: %LOCAL_IP%
echo.

echo 🔍 Testing All Services...
echo ==========================

echo 1. Backend API...
curl -s http://%LOCAL_IP%:3000/health | findstr "OK" >nul
if errorlevel 1 (
    echo    ❌ Backend API failed
) else (
    echo    ✅ Backend API OK
)

echo 2. SRS Server...
curl -s http://%LOCAL_IP%:8080/api/v1/versions | findstr "5.0.213" >nul
if errorlevel 1 (
    echo    ❌ SRS Server failed
) else (
    echo    ✅ SRS Server OK
)

echo 3. Frontend...
curl -s http://%LOCAL_IP%:3001 | findstr "root" >nul
if errorlevel 1 (
    echo    ❌ Frontend failed
) else (
    echo    ✅ Frontend OK
)

echo 4. Database...
docker-compose exec -T postgres psql -U postgres -d livestream_db -c "SELECT COUNT(*) FROM users;" >nul 2>&1
if errorlevel 1 (
    echo    ❌ Database failed
) else (
    echo    ✅ Database OK
)

echo 5. Demo User...
docker-compose exec -T postgres psql -U postgres -d livestream_db -c "SELECT username FROM users WHERE username = 'demo';" 2>nul | findstr "demo" >nul
if errorlevel 1 (
    echo    ❌ Demo user not found
) else (
    echo    ✅ Demo user OK
)

echo.
echo 🎯 CDN CONFIGURATION FOR YOU:
echo =============================
echo.
echo 📋 Your CDN Settings:
echo - Group ID: 712
echo - Site ID: 50074
echo - CDN URL: 3014973486.global.cdnfastest.com
echo.
echo 🔧 Update CDN Dashboard:
echo Origin Type: HTTP Pull
echo Origin URL: http://%LOCAL_IP%:8000/live/demo-stream-key-123.m3u8
echo Auth URL: http://%LOCAL_IP%:3000/api/callback/on_publish
echo Auth Method: POST
echo Auth Parameters: stream_key
echo.

echo 📱 OBS Studio Configuration:
echo ============================
echo Server: rtmp://%LOCAL_IP%:1935/live
echo Stream Key: demo-stream-key-123
echo.

echo 🌐 Test URLs:
echo =============
echo Frontend:        http://%LOCAL_IP%:3001
echo API Health:      http://%LOCAL_IP%:3000/health
echo SRS API:         http://%LOCAL_IP%:8080/api/v1/versions
echo Local HLS:       http://%LOCAL_IP%:8000/live/demo-stream-key-123.m3u8
echo CDN HLS:         https://3014973486.global.cdnfastest.com/live/demo-stream-key-123.m3u8
echo.

echo 👤 Demo Credentials:
echo ===================
echo Username: demo
echo Password: demo123
echo Stream Key: demo-stream-key-123
echo.

echo 🚀 NEXT STEPS:
echo ==============
echo 1. Update your CDN dashboard with the HTTP origin URL above
echo 2. Open OBS Studio and configure with the RTMP settings
echo 3. Start streaming in OBS
echo 4. Test the CDN URL
echo 5. Login to frontend to manage streams
echo.

echo ⚠️  IMPORTANT NOTES:
echo ====================
echo - Stream must be active (OBS streaming) for CDN to pull HLS
echo - CDN will pull from HTTP origin, not RTMP directly
echo - Authentication works via callback API
echo - HLS segments are created automatically when streaming
echo.

echo 🎉 SYSTEM READY! Happy Streaming!
echo.
pause