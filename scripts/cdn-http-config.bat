@echo off
echo 🌐 Cấu hình CDN với HTTP Origin
echo ================================

REM Get local IP
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr /i "IPv4"') do (
    set IP=%%i
    set IP=!IP: =!
    goto :found_ip
)
:found_ip

echo.
echo 📋 Thông tin CDN hiện tại:
echo ==========================
echo Group ID: 712
echo Site ID: 50074
echo Origin URL: ingest.vaoluoitv.com:443 (NEED TO CHANGE)
echo CDN URL: 3014973486.global.cdnfastest.com
echo.

echo 🔧 Cấu hình mới cho HTTP Origin:
echo ================================
echo Origin Type: HTTP Pull
echo Origin URL: http://%IP%:8000/live/demo-stream-key-123.m3u8
echo Auth URL: http://%IP%:3000/api/callback/on_publish
echo.

echo 📱 Workflow mới:
echo ================
echo 1. OBS Stream → rtmp://%IP%:1935/live/demo-stream-key-123
echo 2. SRS tạo HLS → http://%IP%:8000/live/demo-stream-key-123.m3u8
echo 3. CDN Pull HLS từ HTTP origin
echo 4. CDN serve cho users → https://3014973486.global.cdnfastest.com/live/demo-stream-key-123.m3u8
echo.

echo 🎯 CDN Dashboard Settings:
echo ==========================
echo Origin Type: HTTP Pull (not RTMP)
echo Origin URL: http://%IP%:8000/live/demo-stream-key-123.m3u8
echo Auth URL: http://%IP%:3000/api/callback/on_publish
echo Auth Method: POST
echo Auth Parameters: stream_key
echo.

echo 🔍 Test URLs:
echo =============
echo Local HLS: http://%IP%:8000/live/demo-stream-key-123.m3u8
echo Local RTMP: rtmp://%IP%:1935/live/demo-stream-key-123
echo API Health: http://%IP%:3000/health
echo.

echo 📱 OBS Configuration:
echo ====================
echo Server: rtmp://%IP%:1935/live
echo Stream Key: demo-stream-key-123
echo.

echo ⚠️  Lưu ý quan trọng:
echo ====================
echo 1. CDN sẽ pull HLS playlist từ HTTP origin
echo 2. SRS phải đang stream để tạo HLS segments
echo 3. Authentication vẫn qua callback API
echo 4. CDN sẽ cache và serve HLS cho users
echo.

echo 🚀 Steps to implement:
echo =====================
echo 1. Start demo: scripts\start-demo.bat
echo 2. Create demo user: scripts\create-demo-user.bat
echo 3. Update CDN origin to: http://%IP%:8000/live/demo-stream-key-123.m3u8
echo 4. Add auth URL: http://%IP%:3000/api/callback/on_publish
echo 5. Start OBS streaming
echo 6. Test CDN URL
echo.

pause
