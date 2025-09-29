# Troubleshooting Guide

Hướng dẫn khắc phục sự cố cho hệ thống livestream demo.

## 🚨 Common Issues

### 1. Docker Services không khởi động

**Triệu chứng:**
```
ERROR: Container not starting
Service not responding
```

**Giải pháp:**
```bash
# Kiểm tra Docker daemon
docker info

# Kiểm tra port conflicts
netstat -an | findstr :3000
netstat -an | findstr :1935
netstat -an | findstr :8000

# Restart Docker services
docker-compose down
docker-compose up -d

# Xem logs chi tiết
docker-compose logs [service_name]
```

### 2. Backend API không response

**Triệu chứng:**
```
curl: (7) Failed to connect to localhost port 3000
Backend API is not responding
```

**Giải pháp:**
```bash
# Kiểm tra container status
docker-compose ps

# Xem backend logs
docker-compose logs backend

# Kiểm tra database connection
docker-compose exec backend node -e "
const { Pool } = require('pg');
const pool = new Pool({
  host: 'postgres',
  port: 5432,
  database: 'livestream_db',
  user: 'postgres',
  password: 'password'
});
pool.query('SELECT NOW()').then(console.log).catch(console.error);
"

# Restart backend
docker-compose restart backend
```

### 3. Database Connection Failed

**Triệu chứng:**
```
Error: connect ECONNREFUSED
Database connection failed
```

**Giải pháp:**
```bash
# Kiểm tra PostgreSQL container
docker-compose exec postgres psql -U postgres -c "SELECT version();"

# Kiểm tra database exists
docker-compose exec postgres psql -U postgres -l

# Recreate database
docker-compose down -v
docker-compose up -d postgres
sleep 10
docker-compose up -d

# Manual database setup
docker-compose exec postgres psql -U postgres -c "CREATE DATABASE livestream_db;"
```

### 4. SRS Server không hoạt động

**Triệu chứng:**
```
SRS Server is not responding
RTMP connection failed
```

**Giải pháp:**
```bash
# Kiểm tra SRS logs
docker-compose logs srs

# Kiểm tra SRS API
curl http://localhost:8080/api/v1/versions

# Kiểm tra config file
docker-compose exec srs cat /usr/local/srs/conf/srs.conf

# Test RTMP connection
ffmpeg -f lavfi -i testsrc=duration=10:size=320x240:rate=1 -f flv rtmp://localhost:1935/live/test

# Restart SRS
docker-compose restart srs
```

### 5. Frontend không load

**Triệu chứng:**
```
Frontend is not responding
React app not loading
```

**Giải pháp:**
```bash
# Kiểm tra frontend logs
docker-compose logs frontend

# Kiểm tra API connection
curl http://localhost:3000/health

# Clear browser cache
# Hard refresh: Ctrl+Shift+R (Windows) or Cmd+Shift+R (Mac)

# Restart frontend
docker-compose restart frontend

# Check environment variables
docker-compose exec frontend env | grep REACT_APP
```

### 6. Stream Authentication Failed

**Triệu chứng:**
```
Stream authentication failed
Invalid stream key
```

**Giải pháp:**
```bash
# Kiểm tra stream key trong database
docker-compose exec postgres psql -U postgres -d livestream_db -c "
SELECT sk.key, sk.name, sk.is_active, u.username 
FROM stream_keys sk 
JOIN users u ON sk.user_id = u.id;"

# Test authentication callback
curl -X POST http://localhost:3000/api/callback/on_publish \
  -H "Content-Type: application/json" \
  -d '{
    "action": "on_publish",
    "client_id": "test",
    "ip": "127.0.0.1",
    "vhost": "__defaultVhost__",
    "app": "live",
    "stream": "demo-stream-key-123",
    "param": "demo-stream-key-123"
  }'

# Kiểm tra backend logs
docker-compose logs backend | grep callback

# Recreate demo user
scripts/create-demo-user.bat  # Windows
./scripts/create-demo-user.sh  # Linux/Mac
```

### 7. HLS Stream không play

**Triệu chứng:**
```
HLS stream not loading
Video player shows error
```

**Giải pháp:**
```bash
# Kiểm tra HLS URL
curl -I http://localhost:8000/live/demo-stream-key-123.m3u8

# Kiểm tra SRS HLS config
docker-compose exec srs cat /usr/local/srs/conf/srs.conf | grep -A 10 hls

# Test với ffplay
ffplay http://localhost:8000/live/demo-stream-key-123.m3u8

# Kiểm tra nginx logs (nếu có)
docker-compose logs srs | grep nginx

# Restart SRS
docker-compose restart srs
```

### 8. CDN không pull được stream

**Triệu chứng:**
```
CDN not pulling from origin
Stream not available on CDN
```

**Giải pháp:**
```bash
# Kiểm tra network connectivity
ping your-cdn-domain.com
telnet your-local-ip 1935

# Test RTMP từ external
ffmpeg -f lavfi -i testsrc=duration=10:size=320x240:rate=1 \
  -f flv rtmp://YOUR_PUBLIC_IP:1935/live/test

# Kiểm tra port forwarding
# Router: Port 1935 -> Your Local IP:1935

# Sử dụng ngrok
ngrok tcp 1935
# Sử dụng ngrok URL thay vì public IP

# Kiểm tra firewall
# Windows: Windows Defender Firewall
# Linux: ufw status / iptables -L
```

## 🔧 Debug Commands

### System Health Check
```bash
# Check all services
docker-compose ps

# Check resource usage
docker stats

# Check logs
docker-compose logs --tail=50

# Check network
docker network ls
docker network inspect demo-cdn-to-srs_default
```

### Database Debug
```bash
# Connect to database
docker-compose exec postgres psql -U postgres -d livestream_db

# Check tables
\dt

# Check users
SELECT * FROM users;

# Check stream keys
SELECT * FROM stream_keys;

# Check active streams
SELECT * FROM streams WHERE status = 'online';
```

### SRS Debug
```bash
# SRS API status
curl http://localhost:8080/api/v1/versions

# SRS streams
curl http://localhost:8080/api/v1/streams

# SRS clients
curl http://localhost:8080/api/v1/clients

# SRS summaries
curl http://localhost:8080/api/v1/summaries
```

### Network Debug
```bash
# Check ports
netstat -an | findstr :3000
netstat -an | findstr :1935
netstat -an | findstr :8000
netstat -an | findstr :8080

# Test connections
telnet localhost 3000
telnet localhost 1935
telnet localhost 8000

# Check external connectivity
curl -I http://your-public-ip:3000/health
```

## 🚀 Performance Issues

### High CPU Usage
```bash
# Check container stats
docker stats

# Optimize SRS config
# Reduce video quality in OBS
# Use hardware acceleration
```

### Memory Issues
```bash
# Check memory usage
docker stats --format "table {{.Container}}\t{{.MemUsage}}"

# Increase Docker memory limit
# Restart services
docker-compose restart
```

### Network Latency
```bash
# Check network latency
ping your-cdn-domain.com
traceroute your-cdn-domain.com

# Optimize SRS settings
# Use CDN edge locations
# Enable low latency mode
```

## 📞 Getting Help

### Collect Debug Information
```bash
# System info
docker --version
docker-compose --version
systeminfo  # Windows
uname -a    # Linux/Mac

# Service logs
docker-compose logs > debug.log 2>&1

# Network info
ipconfig /all  # Windows
ifconfig       # Linux/Mac

# Process info
tasklist | findstr docker  # Windows
ps aux | grep docker       # Linux/Mac
```

### Contact Support
1. **Check logs** trước khi liên hệ
2. **Collect debug information** như trên
3. **Describe the issue** chi tiết
4. **Provide steps to reproduce**
5. **Include error messages**

### Useful Resources
- [Docker Documentation](https://docs.docker.com/)
- [SRS Documentation](https://ossrs.net/lts/en-us/docs/)
- [ECGCDN Documentation](https://docs.ecgcdn.com)
- [OBS Studio Help](https://obsproject.com/help)
