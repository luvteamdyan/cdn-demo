# CDN Configuration với HTTP Origin

Hướng dẫn cấu hình CDN sử dụng HTTP origin thay vì RTMP.

## 🔄 Workflow mới

```
[OBS] → [SRS RTMP] → [SRS HLS] → [CDN HTTP Pull] → [Users]
                ↓
        [Backend Auth API]
```

## 📋 Cấu hình CDN Dashboard

### Thông tin hiện tại:
- **Group ID:** 712
- **Site ID:** 50074
- **CDN URL:** 3014973486.global.cdnfastest.com

### Cấu hình mới:
```
Origin Type: HTTP Pull
Origin URL: http://YOUR_LOCAL_IP:8000/live/demo-stream-key-123.m3u8
Auth URL: http://YOUR_LOCAL_IP:3000/api/callback/on_publish
Auth Method: POST
Auth Parameters: stream_key
```

## 🚀 Các bước thực hiện

### 1. Lấy thông tin cấu hình
```bash
# Windows
scripts\cdn-http-config.bat

# Linux/Mac
./scripts/cdn-http-config.sh
```

### 2. Khởi động demo
```bash
# Windows
scripts\start-demo.bat
scripts\create-demo-user.bat

# Linux/Mac
./scripts/start-demo.sh
./scripts/create-demo-user.sh
```

### 3. Cấu hình OBS Studio
```
Settings → Stream:
- Service: Custom
- Server: rtmp://YOUR_LOCAL_IP:1935/live
- Stream Key: demo-stream-key-123
```

### 4. Test HTTP Origin
```bash
# Windows
scripts\test-http-origin.bat

# Linux/Mac
./scripts/test-http-origin.sh
```

### 5. Cập nhật CDN Dashboard
1. Login vào CDN dashboard
2. Tìm configuration cho Group ID: 712, Site ID: 50074
3. Thay đổi Origin Type thành "HTTP Pull"
4. Cập nhật Origin URL: `http://YOUR_LOCAL_IP:8000/live/demo-stream-key-123.m3u8`
5. Thêm Auth URL: `http://YOUR_LOCAL_IP:3000/api/callback/on_publish`
6. Save configuration

## 🔍 Test URLs

### Local URLs:
- **RTMP Input:** `rtmp://YOUR_LOCAL_IP:1935/live/demo-stream-key-123`
- **HLS Origin:** `http://YOUR_LOCAL_IP:8000/live/demo-stream-key-123.m3u8`
- **API Health:** `http://YOUR_LOCAL_IP:3000/health`

### CDN URLs:
- **CDN HLS:** `https://3014973486.global.cdnfastest.com/live/demo-stream-key-123.m3u8`

## ⚠️ Lưu ý quan trọng

### 1. Stream phải đang active
- CDN chỉ pull được khi OBS đang stream
- HLS segments chỉ được tạo khi có stream input
- Nếu stream offline, CDN sẽ không có content để pull

### 2. Authentication flow
- OBS stream → SRS callback → Backend auth
- CDN pull → SRS serve HLS (không cần auth)
- Auth chỉ cần cho stream input, không cần cho HLS output

### 3. CORS Configuration
- SRS đã được cấu hình CORS cho HLS
- CDN có thể pull HLS từ HTTP origin
- Không cần cấu hình thêm CORS

## 🔧 Troubleshooting

### CDN không pull được HLS
1. **Kiểm tra stream đang active:**
   ```bash
   curl http://YOUR_LOCAL_IP:8080/api/v1/streams
   ```

2. **Kiểm tra HLS accessible:**
   ```bash
   curl http://YOUR_LOCAL_IP:8000/live/demo-stream-key-123.m3u8
   ```

3. **Kiểm tra HLS content:**
   ```bash
   curl http://YOUR_LOCAL_IP:8000/live/demo-stream-key-123.m3u8 | head -10
   ```

### HLS playlist empty hoặc invalid
1. **Kiểm tra OBS đang stream**
2. **Kiểm tra SRS logs:**
   ```bash
   docker-compose logs srs
   ```
3. **Restart SRS:**
   ```bash
   docker-compose restart srs
   ```

### CDN authentication failed
1. **Kiểm tra backend API:**
   ```bash
   curl http://YOUR_LOCAL_IP:3000/health
   ```
2. **Test auth callback:**
   ```bash
   curl -X POST http://YOUR_LOCAL_IP:3000/api/callback/on_publish \
     -H "Content-Type: application/json" \
     -d '{"action":"on_publish","param":"demo-stream-key-123"}'
   ```

## 📊 Monitoring

### Check SRS Status
```bash
# Streams
curl http://YOUR_LOCAL_IP:8080/api/v1/streams

# Summaries
curl http://YOUR_LOCAL_IP:8080/api/v1/summaries

# Clients
curl http://YOUR_LOCAL_IP:8080/api/v1/clients
```

### Check HLS Files
```bash
# List HLS files
curl http://YOUR_LOCAL_IP:8000/live/

# Check specific stream
curl http://YOUR_LOCAL_IP:8000/live/demo-stream-key-123.m3u8
```

## 🎯 Advantages của HTTP Origin

1. **Better Compatibility:** Nhiều CDN hỗ trợ HTTP pull hơn RTMP
2. **Easier Authentication:** Auth chỉ cần cho input, output không cần
3. **Better Caching:** CDN có thể cache HLS segments hiệu quả
4. **Lower Latency:** HTTP pull thường nhanh hơn RTMP
5. **Easier Debugging:** HTTP requests dễ debug hơn RTMP

## 🔄 Migration từ RTMP Origin

Nếu bạn đang dùng RTMP origin và muốn chuyển sang HTTP:

1. **Update CDN config** như hướng dẫn trên
2. **Test thoroughly** với HTTP origin
3. **Monitor performance** so với RTMP
4. **Keep RTMP config** làm backup nếu cần

HTTP origin thường cho performance tốt hơn và ổn định hơn cho CDN integration.
