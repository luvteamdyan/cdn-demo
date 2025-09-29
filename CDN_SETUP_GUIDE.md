# 🎯 Hướng Dẫn Cấu Hình CDN Cho Demo

## 📋 Thông tin CDN hiện tại của bạn:
- **Group ID:** 712
- **Site ID:** 50074
- **CDN URL:** 3014973486.global.cdnfastest.com
- **Local IP:** 26.9.244.118

## 🚀 Bước 1: Lấy thông tin cấu hình

### Chạy script để lấy IP và cấu hình:
```bash
scripts\get-ip-and-config.bat
```

**Kết quả sẽ hiển thị:**
- Local IP: 26.9.244.118
- Cấu hình CDN cần thay đổi
- Cấu hình OBS Studio
- Test URLs

## 🔧 Bước 2: Khởi động demo

### 2.1 Khởi động tất cả services:
```bash
scripts\start-demo.bat
```

### 2.2 Tạo demo user:
```bash
scripts\create-demo-user.bat
```

### 2.3 Test toàn bộ hệ thống:
```bash
scripts\test-complete-system.bat
```

## 🌐 Bước 3: Cấu hình CDN Dashboard

### 3.1 Login vào CDN dashboard
- Truy cập dashboard của CDN provider
- Tìm configuration cho Group ID: 712, Site ID: 50074

### 3.2 Cập nhật Origin Configuration:
```
Origin Type: HTTP Pull (thay vì RTMP)
Origin URL: http://26.9.244.118:8000/live/demo-stream-key-123.m3u8
```

### 3.3 Cấu hình Authentication:
```
Auth URL: http://26.9.244.118:3000/api/callback/on_publish
Auth Method: POST
Auth Parameters: stream_key
Auth Timeout: 10 seconds
```

### 3.4 Cấu hình Output:
```
Output Format: HLS
Segment Duration: 10 seconds
Playlist Duration: 60 seconds
```

## 📱 Bước 4: Cấu hình OBS Studio

### 4.1 Mở OBS Studio

### 4.2 Settings → Stream:
```
Service: Custom
Server: rtmp://26.9.244.118:1935/live
Stream Key: demo-stream-key-123
```

### 4.3 Start Streaming

## 🧪 Bước 5: Test hệ thống

### 5.1 Test Local URLs:
- **HLS:** http://26.9.244.118:8000/live/demo-stream-key-123.m3u8
- **API:** http://26.9.244.118:3000/health
- **Frontend:** http://26.9.244.118:3001

### 5.2 Test CDN URL:
- **CDN HLS:** https://3014973486.global.cdnfastest.com/live/demo-stream-key-123.m3u8

## 🔍 Workflow hoàn chỉnh:

```
[OBS Studio] 
    ↓ (RTMP)
[Local SRS Server: 26.9.244.118:1935]
    ↓ (tạo HLS)
[Local HLS: 26.9.244.118:8000/live/demo-stream-key-123.m3u8]
    ↓ (HTTP Pull)
[CDN: 3014973486.global.cdnfastest.com]
    ↓ (serve cho users)
[Users xem stream]
```

## ⚠️ Lưu ý quan trọng:

### 1. Stream phải đang active
- CDN chỉ pull được HLS khi OBS đang streaming
- Nếu OBS dừng, CDN sẽ không có content để pull

### 2. Authentication flow
- OBS → SRS → Backend API (xác thực stream key)
- CDN → SRS (pull HLS, không cần auth)
- Users → CDN (xem stream)

### 3. Network requirements
- Port 1935 (RTMP) phải accessible từ OBS
- Port 3000 (API) phải accessible từ CDN
- Port 8000 (HLS) phải accessible từ CDN

## 🌍 Nếu cần public access:

### Sử dụng ngrok:
```bash
ngrok tcp 1935    # RTMP
ngrok http 3000   # API
ngrok http 8000   # HLS
```

### Cập nhật CDN với ngrok URLs:
```
Origin URL: http://ngrok-url:port/live/demo-stream-key-123.m3u8
Auth URL: http://ngrok-url:port/api/callback/on_publish
```

## 🔧 Troubleshooting:

### CDN không pull được HLS:
1. Kiểm tra OBS đang streaming
2. Kiểm tra HLS URL: http://26.9.244.118:8000/live/demo-stream-key-123.m3u8
3. Kiểm tra SRS logs: `docker-compose logs srs`

### Authentication failed:
1. Kiểm tra API: http://26.9.244.118:3000/health
2. Kiểm tra callback: `curl -X POST http://26.9.244.118:3000/api/callback/on_publish -H "Content-Type: application/json" -d '{"action":"on_publish","param":"demo-stream-key-123"}'`

### Stream không hiển thị:
1. Kiểm tra SRS: http://26.9.244.118:8080/api/v1/streams
2. Kiểm tra database: `docker-compose exec postgres psql -U postgres -d livestream_db -c "SELECT * FROM stream_keys;"`

## 📞 Commands hữu ích:

```bash
# Xem logs
docker-compose logs -f

# Restart services
docker-compose restart

# Check status
docker-compose ps

# Test complete system
scripts\test-complete-system.bat
```

## ✅ Checklist:

- [ ] Local IP đã lấy được (26.9.244.118)
- [ ] Demo đã khởi động
- [ ] Demo user đã tạo
- [ ] CDN đã cấu hình với HTTP origin
- [ ] OBS đã cấu hình đúng
- [ ] Stream đang hoạt động
- [ ] CDN URL có thể access được

**Chúc bạn thành công! 🎉**
