@echo off
echo 🧪 Test Toàn Bộ Hệ Thống
echo =========================

REM Get local IP
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr /i "IPv4"') do (
    set LOCAL_IP=%%i
    set LOCAL_IP=!LOCAL_IP: =!
    goto :found_ip
)
:found_ip

echo Local IP: %LOCAL_IP%
echo.

echo 🔍 Kiểm tra các services...
echo ===========================

echo 1. Kiểm tra Docker containers...
docker-compose ps
echo.

echo 2. Kiểm tra Backend API...
curl -s http://%LOCAL_IP%:3000/health
if errorlevel 1 (
    echo    ❌ Backend API không hoạt động
    echo    💡 Chạy: scripts\start-demo.bat
) else (
    echo    ✅ Backend API hoạt động tốt
)
echo.

echo 3. Kiểm tra SRS Server...
curl -s http://%LOCAL_IP%:8080/api/v1/versions
if errorlevel 1 (
    echo    ❌ SRS Server không hoạt động
) else (
    echo    ✅ SRS Server hoạt động tốt
)
echo.

echo 4. Kiểm tra Frontend...
curl -s http://%LOCAL_IP%:3001 | findstr "root" >nul
if errorlevel 1 (
    echo    ❌ Frontend không hoạt động
) else (
    echo    ✅ Frontend hoạt động tốt
)
echo.

echo 5. Kiểm tra Database...
docker-compose exec -T postgres psql -U postgres -d livestream_db -c "SELECT COUNT(*) FROM users;" >nul 2>&1
if errorlevel 1 (
    echo    ❌ Database không kết nối được
) else (
    echo    ✅ Database kết nối tốt
)
echo.

echo 6. Kiểm tra Demo User...
docker-compose exec -T postgres psql -U postgres -d livestream_db -c "SELECT username FROM users WHERE username = 'demo';" 2>nul | findstr "demo" >nul
if errorlevel 1 (
    echo    ❌ Demo user chưa tạo
    echo    💡 Chạy: scripts\create-demo-user.bat
) else (
    echo    ✅ Demo user đã tồn tại
)
echo.

echo 7. Kiểm tra Demo Stream Key...
docker-compose exec -T postgres psql -U postgres -d livestream_db -c "SELECT key FROM stream_keys WHERE key = 'demo-stream-key-123';" 2>nul | findstr "demo-stream-key-123" >nul
if errorlevel 1 (
    echo    ❌ Demo stream key chưa tạo
    echo    💡 Chạy: scripts\create-demo-user.bat
) else (
    echo    ✅ Demo stream key đã tồn tại
)
echo.

echo 🎯 CẤU HÌNH CDN CHO BẠN:
echo =========================
echo.
echo 📋 Thông tin CDN:
echo - Group ID: 712
echo - Site ID: 50074
echo - CDN URL: 3014973486.global.cdnfastest.com
echo.
echo 🔧 Cấu hình cần thay đổi:
echo Origin Type: HTTP Pull
echo Origin URL: http://%LOCAL_IP%:8000/live/demo-stream-key-123.m3u8
echo Auth URL: http://%LOCAL_IP%:3000/api/callback/on_publish
echo Auth Method: POST
echo Auth Parameters: stream_key
echo.

echo 📱 Cấu hình OBS Studio:
echo =======================
echo Server: rtmp://%LOCAL_IP%:1935/live
echo Stream Key: demo-stream-key-123
echo.

echo 🔍 Test URLs:
echo =============
echo Local HLS: http://%LOCAL_IP%:8000/live/demo-stream-key-123.m3u8
echo Local RTMP: rtmp://%LOCAL_IP%:1935/live/demo-stream-key-123
echo API Health: http://%LOCAL_IP%:3000/health
echo Frontend: http://%LOCAL_IP%:3001
echo.

echo 🎬 CDN Output (sau khi cấu hình):
echo =================================
echo CDN HLS: https://3014973486.global.cdnfastest.com/live/demo-stream-key-123.m3u8
echo.

echo 🚀 WORKFLOW HOÀN CHỈNH:
echo =======================
echo 1. OBS Stream → rtmp://%LOCAL_IP%:1935/live/demo-stream-key-123
echo 2. SRS tạo HLS → http://%LOCAL_IP%:8000/live/demo-stream-key-123.m3u8
echo 3. CDN Pull HLS từ HTTP origin
echo 4. Users xem từ CDN → https://3014973486.global.cdnfastest.com/live/demo-stream-key-123.m3u8
echo.

echo ⚠️  LƯU Ý:
echo ==========
echo - Stream phải đang active (OBS streaming) thì CDN mới pull được HLS
echo - Authentication chỉ cần cho stream input, không cần cho HLS output
echo - CDN sẽ cache HLS segments để serve cho users
echo.

echo 📞 Nếu cần public access:
echo ==========================
echo Sử dụng ngrok:
echo   ngrok tcp 1935
echo   ngrok http 3000
echo   ngrok http 8000
echo.
echo Thay %LOCAL_IP% bằng ngrok URL trong cấu hình CDN
echo.

echo ✅ Test hoàn tất!
echo Bạn có thể bắt đầu cấu hình CDN với thông tin trên.
echo.

pause
