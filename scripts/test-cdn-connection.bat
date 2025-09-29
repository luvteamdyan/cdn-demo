@echo off
echo 🧪 Test CDN Connection
echo ======================

REM Get local IP
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr /i "IPv4"') do (
    set IP=%%i
    set IP=!IP: =!
    goto :found_ip
)
:found_ip

echo Testing connection to: %IP%
echo.

echo 1. Testing Backend API...
curl -s http://%IP%:3000/health | findstr "OK" >nul
if errorlevel 1 (
    echo    ❌ Backend API not accessible from %IP%
    echo    💡 Try: http://localhost:3000/health
) else (
    echo    ✅ Backend API accessible from %IP%
)

echo.
echo 2. Testing SRS RTMP...
echo    💡 Use telnet or OBS to test: rtmp://%IP%:1935/live
echo    📱 OBS Server: rtmp://%IP%:1935/live
echo    📱 OBS Stream Key: demo-stream-key-123

echo.
echo 3. Testing HLS...
curl -s -I http://%IP%:8000/live/demo-stream-key-123.m3u8 >nul
if errorlevel 1 (
    echo    ❌ HLS not accessible from %IP%
    echo    💡 Try: http://localhost:8000/live/demo-stream-key-123.m3u8
) else (
    echo    ✅ HLS accessible from %IP%
)

echo.
echo 4. Testing Authentication Callback...
curl -X POST http://%IP%:3000/api/callback/on_publish -H "Content-Type: application/json" -d "{\"action\":\"on_publish\",\"param\":\"demo-stream-key-123\"}" >nul 2>&1
if errorlevel 1 (
    echo    ❌ Authentication callback not accessible from %IP%
) else (
    echo    ✅ Authentication callback accessible from %IP%
)

echo.
echo 🎯 CDN Configuration Summary:
echo =============================
echo Current CDN Settings:
echo - Group ID: 712
echo - Site ID: 50074
echo - Origin URL: ingest.vaoluoitv.com:443 (NEED TO CHANGE)
echo - CDN URL: 3014973486.global.cdnfastest.com
echo.
echo New Settings for Demo:
echo - Origin URL: rtmp://%IP%:1935/live (CHANGE TO THIS)
echo - Auth URL: http://%IP%:3000/api/callback/on_publish (ADD THIS)
echo.

echo 🔧 Update Steps:
echo ================
echo 1. Login to your CDN dashboard
echo 2. Find configuration for Group ID: 712, Site ID: 50074
echo 3. Change Origin URL to: rtmp://%IP%:1935/live
echo 4. Add Auth URL: http://%IP%:3000/api/callback/on_publish
echo 5. Set Auth Method: POST
echo 6. Set Auth Parameters: stream_key
echo 7. Save configuration
echo.

echo 📱 Test with OBS:
echo ================
echo 1. Open OBS Studio
echo 2. Settings → Stream
echo 3. Server: rtmp://%IP%:1935/live
echo 4. Stream Key: demo-stream-key-123
echo 5. Start Streaming
echo 6. Check CDN URL: https://3014973486.global.cdnfastest.com/live/demo-stream-key-123.m3u8
echo.

pause
