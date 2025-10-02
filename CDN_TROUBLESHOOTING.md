# CDN Troubleshooting - Không có logs

## Vấn đề hiện tại
- CDN trả về HTTP 504 Gateway Timeout
- CDN không có logs
- LocalTunnel có thể không ổn định

## Nguyên nhân

### 1. CDN Timeout quá ngắn
```
CDN → Origin (LocalTunnel) → SRS
     ↑ Timeout 30s
```
**Giải pháp:** Tăng CDN origin timeout lên 60-120s

### 2. LocalTunnel không ổn định
- LocalTunnel có thể bị drop connection
- Không phù hợp cho production

### 3. CDN Cache Policy
- CDN có thể cache error response
- Cần clear cache hoặc disable cache

## Giải pháp

### Giải pháp 1: Tăng CDN Timeout
1. Vào CDN dashboard
2. Tìm "Origin Settings" hoặc "Timeout Settings"
3. Tăng "Origin Timeout" từ 30s lên 60-120s
4. Save và test lại

### Giải pháp 2: Sử dụng Cloudflare Tunnel
```bash
# Cài đặt cloudflared
brew install cloudflared

# Đăng nhập
cloudflared tunnel login

# Tạo tunnel
cloudflared tunnel create srs-tunnel

# Chạy tunnel
cloudflared tunnel run srs-tunnel --url http://localhost:8000
```

### Giải pháp 3: VPS + Domain (Production)
1. Mua VPS (DigitalOcean, Linode, Vultr)
2. Mua domain
3. Deploy SRS server lên VPS
4. Cấu hình DNS
5. Sử dụng VPS domain làm CDN origin

### Giải pháp 4: Clear CDN Cache
1. Vào CDN dashboard
2. Tìm "Cache" hoặc "Purge"
3. Clear cache cho domain
4. Test lại

## Test Commands

### Test Origin trực tiếp
```bash
curl -I "https://srs-demo.loca.lt/live/demo-stream-key-123.flv"
```

### Test với timeout dài
```bash
curl -I --max-time 120 "https://3014143238.global.cdnfastest.com/live/demo-stream-key-123.flv"
```

### Test với cache busting
```bash
curl -I "https://3014143238.global.cdnfastest.com/live/demo-stream-key-123.flv?v=$(date +%s)"
```

## Monitoring

### Kiểm tra SRS logs
```bash
docker logs cdn-demo-srs-1 -f
```

### Kiểm tra Backend logs
```bash
docker logs cdn-demo-backend-1 -f
```

### Kiểm tra LocalTunnel
```bash
ps aux | grep lt
```

## Kết luận

**CDN không có logs vì:**
1. CDN timeout trước khi nhận được response từ origin
2. LocalTunnel không ổn định cho production
3. Cần sử dụng giải pháp ổn định hơn

**Khuyến nghị:**
- Sử dụng Cloudflare Tunnel hoặc VPS
- Tăng CDN timeout
- Monitor logs thường xuyên




