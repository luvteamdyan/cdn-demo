@echo off
echo 🧪 Test HTTP Origin Configuration
echo ==================================

REM Get local IP
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr /i "IPv4"') do (
    set IP=%%i
    set IP=!IP: =!
    goto :found_ip
)
:found_ip

set STREAM_KEY=demo-stream-key-123
set HLS_URL=http://%IP%:8000/live/%STREAM_KEY%.m3u8
set AUTH_URL=http://%IP%:3000/api/callback/on_publish

echo Testing HTTP Origin for CDN...
echo IP: %IP%
echo HLS URL: %HLS_URL%
echo Auth URL: %AUTH_URL%
echo.

echo 1. Testing Backend API...
curl -s http://%IP%:3000/health | findstr "OK" >nul
if errorlevel 1 (
    echo    ❌ Backend API not accessible
    echo    💡 Check: http://localhost:3000/health
) else (
    echo    ✅ Backend API accessible
)

echo.
echo 2. Testing SRS HTTP Server...
curl -s -I %HLS_URL% >nul 2>&1
if errorlevel 1 (
    echo    ❌ HLS not accessible - stream may be offline
    echo    💡 Start streaming first, then test
    echo    📱 OBS: rtmp://%IP%:1935/live/%STREAM_KEY%
) else (
    echo    ✅ HLS accessible from %IP%
)

echo.
echo 3. Testing Authentication Callback...
curl -X POST %AUTH_URL% -H "Content-Type: application/json" -d "{\"action\":\"on_publish\",\"param\":\"%STREAM_KEY%\"}" >nul 2>&1
if errorlevel 1 (
    echo    ❌ Auth callback not accessible
) else (
    echo    ✅ Auth callback accessible
)

echo.
echo 4. Testing HLS Content...
curl -s %HLS_URL% | findstr "EXTM3U" >nul
if errorlevel 1 (
    echo    ❌ HLS playlist not valid - stream may be offline
    echo    💡 Start OBS streaming first
) else (
    echo    ✅ HLS playlist is valid
)

echo.
echo 🎯 CDN Configuration Summary:
echo =============================
echo For your CDN dashboard (Group ID: 712, Site ID: 50074):
echo.
echo Origin Type: HTTP Pull
echo Origin URL: %HLS_URL%
echo Auth URL: %AUTH_URL%
echo Auth Method: POST
echo Auth Parameters: stream_key
echo.

echo 📱 To test this configuration:
echo ==============================
echo 1. Start demo: scripts\start-demo.bat
echo 2. Create demo user: scripts\create-demo-user.bat
echo 3. Open OBS Studio
echo 4. Configure OBS:
echo    - Server: rtmp://%IP%:1935/live
echo    - Stream Key: %STREAM_KEY%
echo 5. Start streaming in OBS
echo 6. Test HLS URL: %HLS_URL%
echo 7. Update CDN with the HTTP origin URL above
echo 8. Test CDN URL: https://3014973486.global.cdnfastest.com/live/%STREAM_KEY%.m3u8
echo.

echo ⚠️  Important Notes:
echo ===================
echo - CDN pulls HLS from HTTP origin (not RTMP)
echo - Stream must be active in OBS for HLS to be available
echo - CDN will cache HLS segments for better performance
echo - Authentication still works via callback API
echo.

echo 🔍 Debug Commands:
echo ==================
echo Check SRS status: curl http://%IP%:8080/api/v1/streams
echo Check HLS: curl %HLS_URL%
echo Check auth: curl -X POST %AUTH_URL% -H "Content-Type: application/json" -d "{\"action\":\"on_publish\",\"param\":\"%STREAM_KEY%\"}"
echo.

pause
