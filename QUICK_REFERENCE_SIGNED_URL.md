# 🚀 Quick Reference - Signed URL

## 📌 Tóm Tắt Nhanh

**Mục đích:** Tạo secure CDN URLs với token và expiry time (giống evgcdn)

**Test Result:** ✅ 100% match với PHP evgcdn example

## 🔧 Setup (1 phút)

```bash
# 1. Copy và edit .env
cp env.example .env

# 2. Thêm vào .env:
CDN_BASE_URL=http://3014973486.global.cdnfastest.com
CDN_SECURE_TOKEN=s3cret
CDN_URL_EXPIRY_MINUTES=60

# 3. Test
node test-signed-url.js
```

## 📡 API Endpoints

### 1️⃣ Get Signed URL (Authenticated)
```bash
GET /api/streams/:id/signed-url?expiry=120&ip=192.168.1.100
Headers: Authorization: Bearer <JWT_TOKEN>
```

### 2️⃣ Generate Signed URL (Public)
```bash
POST /api/streams/generate-signed-url
Body: {
  "streamKey": "demo-stream-key-123",
  "expiryMinutes": 60,
  "userIP": "192.168.1.100"
}
```

## 💻 Code Examples

### Frontend (React/JS):
```javascript
// Fetch signed URL
const res = await fetch('/api/streams/1/signed-url?expiry=60', {
  headers: { 'Authorization': `Bearer ${token}` }
});
const { signedUrl } = await res.json();

// Use in HLS player
const hls = new Hls();
hls.loadSource(signedUrl);
hls.attachMedia(video);
```

### Backend (Node.js):
```javascript
const { generateSignedStreamUrl } = require('./backend/utils/secureUrl');

const result = generateSignedStreamUrl(
  'http://cdn.com',      // CDN base URL
  '/live/stream.m3u8',   // File path
  's3cret',              // Secure token
  60,                    // Expiry minutes
  null                   // User IP (optional)
);

console.log(result.signedUrl);
// http://cdn.com/live/stream.m3u8?token=xxx&time=xxx
```

### PHP (giống evgcdn):
```php
<?php
echo getSignedUrlParam(
  'http://cdn.com',
  '/live/stream.m3u8',
  's3cret',
  time() + 3600,
  NULL
);
?>
```

## 🧪 Test Commands

```bash
# Test script
node test-signed-url.js

# Test API (authenticated)
curl -X GET "http://localhost:3000/api/streams/1/signed-url" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Test API (public)
curl -X POST "http://localhost:3000/api/streams/generate-signed-url" \
  -H "Content-Type: application/json" \
  -d '{"streamKey": "demo-stream-key-123", "expiryMinutes": 60}'
```

## 📊 URL Format

```
{CDN_BASE_URL}{FILE_PATH}?token={TOKEN}&time={TIMESTAMP}

Example:
http://3014973486.global.cdnfastest.com/live/demo-stream-key-123.m3u8?token=MCSyjS_F6DCcwch_z1Jumg&time=1759289008
```

**Where:**
- `token` = MD5 hash (base64 encoded, special chars replaced)
- `time` = Unix timestamp when URL expires

## 🔐 Security

| Feature | Description |
|---------|-------------|
| Token | MD5(secureToken + filePath + timestamp + IP) |
| Expiry | Auto-expire sau X minutes |
| IP Lock | Optional IP restriction |
| Verify | Server-side verification available |

## 📁 Key Files

```
backend/utils/secureUrl.js       - Core functions
backend/routes/streams.js        - API endpoints
backend/config.js                - Configuration
test-signed-url.js              - Test script
SIGNED_URL_GUIDE.md             - Full guide
example-usage.js                - Code examples
```

## ⚡ Common Use Cases

```javascript
// 1. Basic signed URL
const url = generateSignedStreamUrl(cdn, path, token, 60);

// 2. With IP restriction
const url = generateSignedStreamUrl(cdn, path, token, 60, '192.168.1.100');

// 3. Verify URL
const valid = verifySignedUrl(token, time, path, secretToken, ip);

// 4. Share link (2 hours)
const shareUrl = generateSignedStreamUrl(cdn, path, token, 120);

// 5. Pay-per-view (24 hours)
const ppvUrl = generateSignedStreamUrl(cdn, path, token, 1440);
```

## 🎯 Response Example

```json
{
  "streamKey": "demo-stream-key-123",
  "signedUrl": "http://cdn.com/live/stream.m3u8?token=xxx&time=1759289008",
  "expiresAt": "2025-10-01T03:23:28.000Z",
  "expiryTimestamp": 1759289008,
  "expiryMinutes": 60
}
```

## 📞 Troubleshooting

| Issue | Solution |
|-------|----------|
| Token không match | Check `CDN_SECURE_TOKEN` |
| URL expired | Tăng `expiryMinutes` |
| IP không khớp | Remove IP restriction hoặc dùng đúng IP |
| 404 Not Found | Check backend đã start và route đúng |

## 📚 Read More

- `SIGNED_URL_GUIDE.md` - Hướng dẫn chi tiết
- `IMPLEMENTATION_SUMMARY.md` - Technical details
- `example-usage.js` - More code examples

---

**Status:** ✅ Production Ready
**Test:** ✅ Passed (100% match với evgcdn PHP)
**Version:** 1.0.0



