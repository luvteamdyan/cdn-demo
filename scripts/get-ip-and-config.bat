@echo off
echo 🌐 Lấy Local IP và Cấu hình CDN
echo ================================

echo.
echo 📡 Đang lấy Local IP...

REM Get local IP address
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr /i "IPv4"') do (
    set LOCAL_IP=%%i
    set LOCAL_IP=!LOCAL_IP: =!
    goto :found_ip
)
:found_ip

echo ✅ Local IP: %LOCAL_IP%
echo.

echo 🎯 CẤU HÌNH CDN CHO DEMO:
echo ========================
echo.
echo 📋 Thông tin CDN hiện tại của bạn:
echo - Group ID: 712
echo - Site ID: 50074
echo - CDN URL: 3014973486.global.cdnfastest.com
echo.

echo 🔧 Cấu hình mới cần thay đổi:
echo ==============================
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

echo 🔍 URLs để test:
echo ================
echo Local HLS: http://%LOCAL_IP%:8000/live/demo-stream-key-123.m3u8
echo Local RTMP: rtmp://%LOCAL_IP%:1935/live/demo-stream-key-123
echo API Health: http://%LOCAL_IP%:3000/health
echo.

echo 🎬 CDN Output URL (sau khi cấu hình):
echo =====================================
echo CDN HLS: https://3014973486.global.cdnfastest.com/live/demo-stream-key-123.m3u8
echo.

echo ⚠️  LƯU Ý QUAN TRỌNG:
echo ====================
echo 1. CDN sẽ pull HLS từ HTTP origin (không phải RTMP)
echo 2. Stream phải đang active (OBS streaming) thì CDN mới pull được
echo 3. Authentication chỉ cần cho stream input, không cần cho HLS output
echo.

echo 🚀 CÁC BƯỚC THỰC HIỆN:
echo =====================
echo.
echo Bước 1: Khởi động demo
echo   scripts\start-demo.bat
echo.
echo Bước 2: Tạo demo user
echo   scripts\create-demo-user.bat
echo.
echo Bước 3: Cập nhật CDN Dashboard
echo   - Login vào CDN dashboard
echo   - Tìm Group ID: 712, Site ID: 50074
echo   - Thay đổi Origin URL thành: http://%LOCAL_IP%:8000/live/demo-stream-key-123.m3u8
echo   - Thêm Auth URL: http://%LOCAL_IP%:3000/api/callback/on_publish
echo.
echo Bước 4: Test streaming
echo   - Mở OBS Studio
echo   - Cấu hình: Server: rtmp://%LOCAL_IP%:1935/live
echo   - Stream Key: demo-stream-key-123
echo   - Start Streaming
echo.
echo Bước 5: Test CDN
echo   - Kiểm tra: https://3014973486.global.cdnfastest.com/live/demo-stream-key-123.m3u8
echo.

echo 📞 Nếu cần public access (qua internet):
echo ========================================
echo Sử dụng ngrok:
echo   ngrok tcp 1935    # Cho RTMP
echo   ngrok http 3000   # Cho API
echo   ngrok http 8000   # Cho HLS
echo.
echo Sau đó thay %LOCAL_IP% bằng ngrok URL trong cấu hình CDN
echo.

pause
