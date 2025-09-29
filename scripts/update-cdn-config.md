# Cấu hình CDN cho Demo Local

## 📋 Thông tin hiện tại của bạn:
- **Group ID:** 712
- **Site ID:** 50074
- **Origin URL:** ingest.vaoluoitv.com:443
- **CDN URL:** 3014973486.global.cdnfastest.com

## 🔧 Cấu hình mới cho demo local:

### 1. Lấy IP local của bạn
```bash
# Windows
ipconfig | findstr "IPv4"

# Hoặc sử dụng ngrok
ngrok tcp 1935
```

### 2. Cập nhật trong CDN Dashboard

#### A. Pull Stream Configuration:
```
Stream Name: Football Demo Stream
Stream Type: RTMP Pull
Source URL: rtmp://YOUR_LOCAL_IP:1935/live
Stream Key: demo-stream-key-123
```

#### B. Origin Server Settings:
```
Origin Type: Custom RTMP
Origin URL: rtmp://YOUR_LOCAL_IP:1935/live
Connection Timeout: 30 seconds
Retry Count: 3
Retry Interval: 5 seconds
```

#### C. Authentication Settings:
```
Enable Authentication: Yes
Auth URL: http://YOUR_LOCAL_IP:3000/api/callback/on_publish
Auth Method: POST
Auth Timeout: 10 seconds
Auth Parameters: stream_key
```

#### D. Output Settings:
```
Output Format: HLS
Segment Duration: 10 seconds
Playlist Duration: 60 seconds
Enable Low Latency: Yes
```

### 3. Test URLs

#### Local URLs:
- **RTMP Input:** `rtmp://YOUR_LOCAL_IP:1935/live/demo-stream-key-123`
- **HLS Output:** `http://YOUR_LOCAL_IP:8000/live/demo-stream-key-123.m3u8`
- **API Health:** `http://YOUR_LOCAL_IP:3000/health`

#### CDN URLs (sau khi cấu hình):
- **CDN HLS:** `https://3014973486.global.cdnfastest.com/live/demo-stream-key-123.m3u8`
- **CDN RTMP:** `rtmp://3014973486.global.cdnfastest.com/live/demo-stream-key-123`

## 🚀 Bước thực hiện:

### Bước 1: Khởi động demo local
```bash
# Windows
scripts\start-demo.bat
scripts\create-demo-user.bat

# Linux/Mac
./scripts/start-demo.sh
./scripts/create-demo-user.sh
```

### Bước 2: Lấy thông tin kết nối
```bash
# Lấy IP local
ipconfig  # Windows
ifconfig  # Linux/Mac

# Hoặc sử dụng ngrok
ngrok tcp 1935    # RTMP
ngrok http 3000   # API
```

### Bước 3: Cập nhật CDN Dashboard
1. Login vào CDN dashboard
2. Tìm configuration cho Group ID: 712, Site ID: 50074
3. Cập nhật Origin URL thành `rtmp://YOUR_LOCAL_IP:1935/live`
4. Thêm Auth URL: `http://YOUR_LOCAL_IP:3000/api/callback/on_publish`
5. Save configuration

### Bước 4: Test streaming
1. Mở OBS Studio
2. Settings → Stream:
   - Server: `rtmp://YOUR_LOCAL_IP:1935/live`
   - Stream Key: `demo-stream-key-123`
3. Start Streaming
4. Kiểm tra CDN URL: `https://3014973486.global.cdnfastest.com/live/demo-stream-key-123.m3u8`

## 🔍 Troubleshooting:

### Nếu CDN không pull được stream:
1. **Kiểm tra network connectivity:**
   ```bash
   ping YOUR_LOCAL_IP
   telnet YOUR_LOCAL_IP 1935
   ```

2. **Kiểm tra authentication:**
   ```bash
   curl -X POST http://YOUR_LOCAL_IP:3000/api/callback/on_publish \
     -H "Content-Type: application/json" \
     -d '{"action":"on_publish","param":"demo-stream-key-123"}'
   ```

3. **Kiểm tra SRS logs:**
   ```bash
   docker-compose logs srs
   ```

### Nếu cần public access:
```bash
# Sử dụng ngrok
ngrok tcp 1935
ngrok http 3000

# Cập nhật CDN với ngrok URLs:
# Origin URL: rtmp://ngrok-url:port/live
# Auth URL: http://ngrok-url:port/api/callback/on_publish
```

## 📝 Ghi chú quan trọng:

1. **Port Forwarding:** Đảm bảo ports 1935 (RTMP) và 3000 (API) được mở trên router
2. **Firewall:** Kiểm tra Windows Firewall không block các ports
3. **Authentication:** CDN sẽ gọi callback để xác thực stream key
4. **Stream Key:** Sử dụng `demo-stream-key-123` hoặc tạo mới trong frontend

## ✅ Checklist:

- [ ] Demo local đang chạy
- [ ] IP local đã lấy được
- [ ] CDN Origin URL đã cập nhật
- [ ] Auth URL đã cấu hình
- [ ] OBS đã cấu hình đúng
- [ ] Stream đang hoạt động
- [ ] CDN URL có thể access được
