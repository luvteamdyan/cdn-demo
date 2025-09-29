# Livestream Football Website Demo

Một demo hoàn chỉnh cho website live stream bóng đá sử dụng SRS server, backend API, và CDN thực tế (ECGCDN).

## 🏗️ Kiến trúc hệ thống

```
[OBS Studio] → [SRS Server] ← [CDN ECGCDN] → [Người dùng xem]
                    ↓
              [Backend API]
                    ↓
              [PostgreSQL DB]
                    ↓
              [Frontend React]
```

## 📋 Tính năng

- ✅ Quản lý stream keys với authentication
- ✅ SRS server với HTTP callback để xác thực stream
- ✅ Backend API với JWT authentication
- ✅ Frontend React với giao diện quản lý stream
- ✅ Hỗ trợ HLS streaming
- ✅ Tích hợp CDN thực tế (ECGCDN)
- ✅ Docker containerization
- ✅ Real-time viewer count tracking

## 🚀 Cài đặt và chạy

### Yêu cầu hệ thống

- Docker & Docker Compose
- Node.js 18+ (để chạy local development)
- PostgreSQL 15+
- OBS Studio (để test streaming)

### 1. Clone và khởi động

```bash
# Clone repository
git clone <your-repo-url>
cd demo-cdn-to-srs

# Khởi động tất cả services
docker-compose up -d

# Kiểm tra status
docker-compose ps
```

### 2. Tạo demo user

```bash
# Chạy script tạo demo user
docker-compose exec postgres psql -U postgres -d livestream_db -f /docker-entrypoint-initdb.d/create-demo-user.sql

# Hoặc chạy manual
docker-compose exec postgres psql -U postgres -d livestream_db -c "
INSERT INTO users (username, email, password_hash, role) 
VALUES ('demo', 'demo@example.com', '\$2a\$10\$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user')
ON CONFLICT (username) DO NOTHING;

INSERT INTO stream_keys (key, user_id, name, description, is_active)
VALUES ('demo-stream-key-123', (SELECT id FROM users WHERE username = 'demo'), 'Demo Football Match', 'Demo stream for testing', true)
ON CONFLICT (key) DO NOTHING;"
```

### 3. Truy cập ứng dụng

- **Frontend**: http://localhost:3001
- **Backend API**: http://localhost:3000
- **SRS Server**: http://localhost:8080 (API), rtmp://localhost:1935 (RTMP)
- **HLS Stream**: http://localhost:8000/live/[stream_key].m3u8

### 4. Demo credentials

```
Username: demo
Password: demo123
Stream Key: demo-stream-key-123
```

## 📡 Cấu hình CDN ECGCDN

### 1. Chạy script cấu hình

```bash
chmod +x scripts/setup-cdn.sh
./scripts/setup-cdn.sh
```

### 2. Cấu hình trong ECGCDN Dashboard

1. **Login vào ECGCDN Dashboard**
2. **Tạo Pull Stream Configuration:**
   - Stream Type: RTMP Pull
   - Source URL: `rtmp://YOUR_LOCAL_IP:1935/live`
   - Stream Key: `[Your Stream Key]`
   - Output Format: HLS

3. **Cấu hình Authentication:**
   - Enable Authentication: Yes
   - Auth URL: `http://YOUR_LOCAL_IP:3000/api/callback/on_publish`
   - Auth Method: POST
   - Auth Parameters: `stream_key`

4. **Set up Origin Server:**
   - Origin Type: Custom
   - Origin URL: `rtmp://YOUR_LOCAL_IP:1935/live`
   - Timeout: 30 seconds

### 3. Test với OBS Studio

1. Mở OBS Studio
2. Settings → Stream
3. Server: `rtmp://YOUR_LOCAL_IP:1935/live`
4. Stream Key: `demo-stream-key-123`
5. Start Streaming

### 4. Xem stream

- **Local**: http://localhost:8000/live/demo-stream-key-123.m3u8
- **CDN**: https://your-cdn-domain.com/live/demo-stream-key-123.m3u8

## 🔧 API Endpoints

### Authentication
- `POST /api/auth/register` - Đăng ký user mới
- `POST /api/auth/login` - Đăng nhập
- `GET /api/auth/me` - Lấy thông tin user hiện tại

### Stream Management
- `GET /api/streams` - Lấy danh sách stream keys
- `POST /api/streams` - Tạo stream key mới
- `GET /api/streams/:id` - Lấy thông tin stream key
- `PUT /api/streams/:id` - Cập nhật stream key
- `DELETE /api/streams/:id` - Xóa stream key
- `GET /api/streams/:id/rtmp-url` - Lấy RTMP URL

### SRS Callbacks
- `POST /api/callback/on_publish` - Xác thực khi bắt đầu stream
- `POST /api/callback/on_unpublish` - Khi kết thúc stream
- `POST /api/callback/on_play` - Khi có viewer xem
- `POST /api/callback/on_stop` - Khi viewer ngừng xem

## 🐳 Docker Services

### Backend (Node.js + Express)
- Port: 3000
- Database: PostgreSQL
- Features: JWT auth, stream management, SRS callbacks

### SRS Media Server
- RTMP: 1935
- HTTP API: 8080
- HLS: 8000
- Callback: 1985

### Frontend (React)
- Port: 3001
- Features: Stream management UI, viewer interface

### PostgreSQL Database
- Port: 5432
- Database: livestream_db

## 📊 Monitoring và Logs

```bash
# Xem logs của tất cả services
docker-compose logs -f

# Xem logs của service cụ thể
docker-compose logs -f backend
docker-compose logs -f srs
docker-compose logs -f frontend

# Kiểm tra health check
curl http://localhost:3000/health
curl http://localhost:8080/api/v1/versions
```

## 🔍 Troubleshooting

### 1. Stream không hiển thị
- Kiểm tra OBS có đang stream không
- Xem logs của SRS: `docker-compose logs srs`
- Kiểm tra callback authentication: `docker-compose logs backend`

### 2. CDN không pull được stream
- Kiểm tra network connectivity từ CDN đến local server
- Verify RTMP URL và stream key
- Check SRS authentication logs

### 3. Frontend không load được
- Kiểm tra backend API: `curl http://localhost:3000/health`
- Xem logs frontend: `docker-compose logs frontend`
- Verify database connection

### 4. Database connection issues
```bash
# Test database connection
docker-compose exec postgres psql -U postgres -d livestream_db -c "SELECT NOW();"

# Reset database
docker-compose down -v
docker-compose up -d
```

## 🚀 Production Deployment

### 1. Environment Variables
```bash
# Backend
NODE_ENV=production
DB_HOST=your-db-host
JWT_SECRET=your-secret-key

# SRS
SRS_LOG_LEVEL=warn
```

### 2. SSL/HTTPS
- Sử dụng reverse proxy (nginx) với SSL
- Cấu hình CDN với HTTPS endpoints

### 3. Scaling
- Horizontal scaling cho backend API
- Load balancer cho multiple SRS instances
- Database clustering cho PostgreSQL

## 📝 Development

### Chạy local development
```bash
# Backend
cd backend
npm install
npm run dev

# Frontend
cd frontend
npm install
npm start

# SRS (vẫn dùng Docker)
docker-compose up srs postgres -d
```

### Testing
```bash
# Run tests
npm test

# API testing với curl
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"demo","password":"demo123"}'
```

## 📞 Support

Nếu gặp vấn đề, hãy kiểm tra:
1. Docker containers đang chạy: `docker-compose ps`
2. Ports không bị conflict
3. Network connectivity giữa services
4. Logs của từng service

## 📄 License

MIT License - Xem file LICENSE để biết thêm chi tiết.
