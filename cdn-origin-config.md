# CDN Origin Configuration

## Ngrok URL với Header
- **Ngrok URL**: `https://pleasable-psychographically-cody.ngrok-free.dev`
- **HLS Stream**: `https://pleasable-psychographically-cody.ngrok-free.dev/live/demo-stream-key-123.m3u8`
- **HTTP-FLV**: `https://pleasable-psychographically-cody.ngrok-free.dev/live/demo-stream-key-123.flv`

## Cấu hình CDN Origin

### 1. Cloudflare (Khuyến nghị)
```
Origin URL: https://pleasable-psychographically-cody.ngrok-free.dev
Origin Headers:
  - ngrok-skip-browser-warning: true
  - User-Agent: CDN-Origin/1.0
```

### 2. AWS CloudFront
```
Origin Domain: pleasable-psychographically-cody.ngrok-free.dev
Origin Protocol: HTTPS
Custom Headers:
  - ngrok-skip-browser-warning: true
  - User-Agent: CDN-Origin/1.0
```

### 3. KeyCDN
```
Origin URL: https://pleasable-psychographically-cody.ngrok-free.dev
Custom Headers:
  - ngrok-skip-browser-warning: true
  - User-Agent: CDN-Origin/1.0
```

### 4. BunnyCDN
```
Origin URL: https://pleasable-psychographically-cody.ngrok-free.dev
Custom Headers:
  - ngrok-skip-browser-warning: true
  - User-Agent: CDN-Origin/1.0
```

## Test Commands

### Test HLS Stream
```bash
curl -H "ngrok-skip-browser-warning: true" \
     -H "User-Agent: CDN-Origin/1.0" \
     "https://pleasable-psychographically-cody.ngrok-free.dev/live/demo-stream-key-123.m3u8"
```

### Test HTTP-FLV Stream
```bash
curl -H "ngrok-skip-browser-warning: true" \
     -H "User-Agent: CDN-Origin/1.0" \
     "https://pleasable-psychographically-cody.ngrok-free.dev/live/demo-stream-key-123.flv"
```

## Lưu ý quan trọng

1. **Ngrok Free Limitations**:
   - URL sẽ thay đổi mỗi khi restart ngrok
   - Có giới hạn bandwidth
   - Warning page cho browser (nhưng không ảnh hưởng CDN)

2. **Giải pháp tốt hơn**:
   - Sử dụng Cloudflare Tunnel (miễn phí, không warning)
   - Mua ngrok account để có custom domain
   - Sử dụng VPS với domain riêng

3. **Headers cần thiết**:
   - `ngrok-skip-browser-warning: true` - Bỏ qua warning page
   - `User-Agent: CDN-Origin/1.0` - Custom user agent

