# 🚀 Quick Start Guide

Hướng dẫn nhanh để chạy demo livestream football website.

## ⚡ Cài đặt nhanh (5 phút)

### 1. Khởi động hệ thống
```bash
# Windows
scripts\start-demo.bat

# Linux/Mac
chmod +x scripts/*.sh
./scripts/start-demo.sh
```

### 2. Tạo demo user
```bash
# Windows
scripts\create-demo-user.bat

# Linux/Mac
./scripts/create-demo-user.sh
```

### 3. Truy cập ứng dụng
- **Frontend**: http://localhost:3001
- **Login**: demo / demo123

## 🎬 Test streaming với OBS

### Cấu hình OBS Studio
```
Settings → Stream:
- Service: Custom
- Server: rtmp://localhost:1935/live
- Stream Key: demo-stream-key-123
```

### Xem stream
- **Local**: http://localhost:3001/stream/demo-stream-key-123
- **HLS**: http://localhost:8000/live/demo-stream-key-123.m3u8

## 🌐 Cấu hình CDN (ECGCDN)

### 1. Cấu hình ngrok (cho public access)
```bash
ngrok tcp 1935    # RTMP
ngrok http 3000   # API
```

### 2. Cấu hình trong ECGCDN Dashboard
```
Pull Stream Configuration:
- Source URL: rtmp://YOUR_NGROK_URL:1935/live
- Stream Key: demo-stream-key-123
- Auth URL: http://YOUR_NGROK_URL:3000/api/callback/on_publish
```

### 3. Test CDN stream
- **CDN HLS**: https://your-cdn-domain.com/live/demo-stream-key-123.m3u8

## 🔧 Troubleshooting

### Kiểm tra hệ thống
```bash
# Windows
scripts\test-stream.bat

# Linux/Mac
./scripts/test-stream.sh
```

### Xem logs
```bash
docker-compose logs -f
```

### Restart services
```bash
docker-compose restart
```

## 📚 Tài liệu chi tiết

- [README.md](README.md) - Hướng dẫn đầy đủ
- [CDN Setup](docs/CDN_SETUP.md) - Cấu hình CDN chi tiết
- [Troubleshooting](docs/TROUBLESHOOTING.md) - Khắc phục sự cố

## 🎯 URLs quan trọng

| Service | URL | Description |
|---------|-----|-------------|
| Frontend | http://localhost:3001 | Web interface |
| Backend API | http://localhost:3000 | REST API |
| SRS Server | http://localhost:8080 | Media server API |
| HLS Stream | http://localhost:8000/live/[key].m3u8 | Video stream |
| RTMP | rtmp://localhost:1935/live | Streaming input |

## ✅ Checklist

- [ ] Docker đang chạy
- [ ] Services đã khởi động (docker-compose ps)
- [ ] Demo user đã tạo
- [ ] Frontend accessible
- [ ] OBS configured
- [ ] Stream working locally
- [ ] CDN configured (optional)

## 🆘 Cần giúp đỡ?

1. Chạy `scripts/test-stream.bat` để kiểm tra
2. Xem logs: `docker-compose logs -f`
3. Check [Troubleshooting Guide](docs/TROUBLESHOOTING.md)
4. Restart: `docker-compose down && docker-compose up -d`

**Happy Streaming! 🎉**
