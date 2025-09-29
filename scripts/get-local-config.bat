@echo off
echo 🔧 Lấy thông tin cấu hình cho CDN
echo ==================================

echo.
echo 📡 Network Information:
echo =======================

REM Get local IP
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr /i "IPv4"') do (
    set IP=%%i
    set IP=!IP: =!
    echo Local IP: !IP!
    goto :found_ip
)
:found_ip

echo.
echo 🎯 CDN Configuration:
echo ====================
echo Origin URL: rtmp://%IP%:1935/live
echo Auth URL: http://%IP%:3000/api/callback/on_publish
echo.

echo 📱 OBS Studio Configuration:
echo ============================
echo Server: rtmp://%IP%:1935/live
echo Stream Key: demo-stream-key-123
echo.

echo 🌐 Test URLs:
echo =============
echo Local HLS: http://%IP%:8000/live/demo-stream-key-123.m3u8
echo API Health: http://%IP%:3000/health
echo.

echo 🔧 Next Steps:
echo ==============
echo 1. Update CDN Dashboard:
echo    - Origin URL: rtmp://%IP%:1935/live
echo    - Auth URL: http://%IP%:3000/api/callback/on_publish
echo.
echo 2. Configure OBS with the settings above
echo 3. Start streaming and test CDN URL
echo.

echo 💡 If you need public access, use ngrok:
echo    ngrok tcp 1935
echo    ngrok http 3000
echo.

pause
