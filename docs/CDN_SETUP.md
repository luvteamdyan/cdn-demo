# CDN Setup Guide - ECGCDN Integration

Hướng dẫn chi tiết để cấu hình CDN ECGCDN với hệ thống livestream demo.

## 🎯 Tổng quan

CDN sẽ hoạt động như một proxy giữa người dùng và SRS server local của bạn:

```
[Users] → [CDN ECGCDN] → [Your Local SRS Server] → [Backend API for Auth]
```

## 📋 Bước 1: Chuẩn bị môi trường

### 1.1 Khởi động hệ thống local
```bash
# Windows
scripts\start-demo.bat

# Linux/Mac
./scripts/start-demo.sh
```

### 1.2 Tạo demo user
```bash
# Windows
scripts\create-demo-user.bat

# Linux/Mac
./scripts/create-demo-user.sh
```

### 1.3 Kiểm tra hệ thống
```bash
# Windows
scripts\test-stream.bat

# Linux/Mac
./scripts/test-stream.sh
```

## 🌐 Bước 2: Cấu hình network

### 2.1 Lấy IP address của máy local
```bash
# Windows
ipconfig

# Linux/Mac
ifconfig
# hoặc
hostname -I
```

### 2.2 Cấu hình port forwarding (Router)
Cần mở các ports sau trên router:
- **Port 1935**: RTMP (SRS Server)
- **Port 3000**: Backend API
- **Port 8000**: HLS Streams

### 2.3 Hoặc sử dụng ngrok (Recommended)
```bash
# Cài đặt ngrok
# Download từ: https://ngrok.com/download

# Mở terminal và chạy:
ngrok tcp 1935    # Cho RTMP
ngrok http 3000   # Cho Backend API
ngrok http 8000   # Cho HLS Streams
```

## 🔧 Bước 3: Cấu hình ECGCDN Dashboard

### 3.1 Login vào ECGCDN
- Truy cập: https://dashboard.ecgcdn.com
- Đăng nhập với tài khoản của bạn

### 3.2 Tạo Pull Stream Configuration

1. **Vào mục "Stream Management" → "Pull Stream"**

2. **Cấu hình Basic Settings:**
   ```
   Stream Name: Football Demo Stream
   Stream Type: RTMP Pull
   Source URL: rtmp://YOUR_PUBLIC_IP:1935/live
   Stream Key: demo-stream-key-123
   ```

3. **Cấu hình Output Settings:**
   ```
   Output Format: HLS
   Segment Duration: 10 seconds
   Playlist Duration: 60 seconds
   Enable Low Latency: Yes
   ```

4. **Cấu hình Authentication:**
   ```
   Enable Authentication: Yes
   Auth URL: http://YOUR_PUBLIC_IP:3000/api/callback/on_publish
   Auth Method: POST
   Auth Timeout: 10 seconds
   Auth Parameters: stream_key
   ```

5. **Cấu hình Origin Server:**
   ```
   Origin Type: Custom RTMP
   Origin URL: rtmp://YOUR_PUBLIC_IP:1935/live
   Connection Timeout: 30 seconds
   Retry Count: 3
   Retry Interval: 5 seconds
   ```

### 3.3 Cấu hình CORS (nếu cần)
```
Allow Origins: *
Allow Methods: GET, POST, OPTIONS
Allow Headers: Content-Type, Authorization
```

## 🎬 Bước 4: Test streaming

### 4.1 Cấu hình OBS Studio

1. **Mở OBS Studio**
2. **Settings → Stream:**
   ```
   Service: Custom
   Server: rtmp://YOUR_PUBLIC_IP:1935/live
   Stream Key: demo-stream-key-123
   ```
3. **Click "Start Streaming"**

### 4.2 Kiểm tra logs

```bash
# Xem logs SRS
docker-compose logs -f srs

# Xem logs Backend
docker-compose logs -f backend

# Xem logs callback authentication
curl -X POST http://localhost:3000/api/callback/on_publish \
  -H "Content-Type: application/json" \
  -d '{"action":"on_publish","client_id":"test","ip":"127.0.0.1","vhost":"__defaultVhost__","app":"live","stream":"demo-stream-key-123","param":"demo-stream-key-123"}'
```

### 4.3 Test URLs

**Local URLs:**
- HLS: `http://YOUR_LOCAL_IP:8000/live/demo-stream-key-123.m3u8`
- API: `http://YOUR_LOCAL_IP:3000/health`

**CDN URLs (sau khi cấu hình):**
- HLS: `https://your-cdn-domain.com/live/demo-stream-key-123.m3u8`
- API: `https://your-cdn-domain.com/api/health`

## 🔍 Bước 5: Troubleshooting

### 5.1 Stream không hiển thị trên CDN

**Kiểm tra:**
1. SRS server có đang chạy không
2. RTMP URL có đúng không
3. Stream key có tồn tại trong database không
4. Authentication callback có hoạt động không

**Debug commands:**
```bash
# Kiểm tra SRS API
curl http://localhost:8080/api/v1/streams

# Kiểm tra stream key trong database
docker-compose exec postgres psql -U postgres -d livestream_db -c "SELECT * FROM stream_keys WHERE key = 'demo-stream-key-123';"

# Test authentication callback
curl -X POST http://localhost:3000/api/callback/on_publish \
  -H "Content-Type: application/json" \
  -d '{"action":"on_publish","param":"demo-stream-key-123"}'
```

### 5.2 CDN không pull được từ origin

**Kiểm tra:**
1. Network connectivity từ CDN đến local server
2. Port forwarding có hoạt động không
3. Firewall settings
4. RTMP URL format

### 5.3 Authentication failed

**Kiểm tra:**
1. Backend API có accessible từ CDN không
2. Callback URL có đúng không
3. Database connection
4. Stream key có active không

## 📊 Bước 6: Monitoring

### 6.1 CDN Dashboard
- Monitor viewer count
- Check bandwidth usage
- View error logs

### 6.2 Local Monitoring
```bash
# Real-time logs
docker-compose logs -f

# SRS statistics
curl http://localhost:8080/api/v1/summaries

# Database queries
docker-compose exec postgres psql -U postgres -d livestream_db -c "SELECT * FROM streams WHERE status = 'online';"
```

## 🚀 Production Considerations

### 6.1 Security
- Sử dụng HTTPS cho tất cả endpoints
- Implement rate limiting
- Validate stream keys properly
- Use strong JWT secrets

### 6.2 Performance
- Enable SRS caching
- Configure CDN caching rules
- Monitor bandwidth usage
- Implement load balancing

### 6.3 Scalability
- Multiple SRS instances
- Database clustering
- CDN edge locations
- Auto-scaling backend

## 📞 Support

Nếu gặp vấn đề:
1. Kiểm tra logs của tất cả services
2. Verify network connectivity
3. Test từng component riêng biệt
4. Check ECGCDN documentation

**Useful Links:**
- [ECGCDN Documentation](https://docs.ecgcdn.com)
- [SRS Documentation](https://ossrs.net/lts/en-us/docs/)
- [OBS Studio Setup](https://obsproject.com/help)
