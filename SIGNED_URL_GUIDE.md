# 🔐 Hướng Dẫn Sử Dụng Signed URL (Secure CDN URLs)

## 📖 Giới thiệu

Tính năng Signed URL cho phép bạn tạo các URL có bảo mật với token và thời gian hết hạn, tương tự như cơ chế secure URL của evgcdn.

## 🎯 Cách hoạt động

Signed URL được tạo bằng cách:
1. Kết hợp: `secureToken + filePath + expiryTimestamp + userIP`
2. Tạo MD5 hash
3. Encode Base64 và thay thế ký tự đặc biệt
4. Thêm vào URL dưới dạng `?token=xxx&time=xxx`

## 🔧 Cấu hình

### 1. Cập nhật file `.env`:

```bash
# CDN Secure URL Configuration
CDN_BASE_URL=http://3014973486.global.cdnfastest.com
CDN_SECURE_TOKEN=your_secret_token_here
CDN_URL_EXPIRY_MINUTES=60
```

### 2. Các biến môi trường:

- `CDN_BASE_URL`: URL gốc của CDN (vd: http://3014973486.global.cdnfastest.com)
- `CDN_SECURE_TOKEN`: Secret token dùng để ký URL (thay 's3cret' bằng token của bạn)
- `CDN_URL_EXPIRY_MINUTES`: Thời gian mặc định URL có hiệu lực (phút)

## 📡 API Endpoints

### 1. Lấy Signed URL (Authenticated)

**Endpoint:** `GET /api/streams/:id/signed-url`

**Headers:**
```
Authorization: Bearer <your_jwt_token>
```

**Query Parameters:**
- `expiry` (optional): Số phút URL có hiệu lực (default: 60)
- `ip` (optional): IP của user để restrict access

**Request Example:**
```bash
curl -X GET "http://localhost:3000/api/streams/1/signed-url?expiry=120&ip=192.168.1.100" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response:**
```json
{
  "streamKey": "demo-stream-key-123",
  "signedUrl": "http://3014973486.global.cdnfastest.com/live/demo-stream-key-123.m3u8?token=2PHbRUPhi7KCJYgekF1gLA&time=1633024800",
  "expiresAt": "2025-10-01T12:00:00.000Z",
  "expiryTimestamp": 1633024800,
  "expiryMinutes": 120,
  "cdnBaseUrl": "http://3014973486.global.cdnfastest.com",
  "filePath": "/live/demo-stream-key-123.m3u8",
  "usage": {
    "description": "Use this signed URL to access the HLS stream via CDN",
    "note": "URL will expire after the specified time",
    "example": "Use in video player or share with viewers"
  }
}
```

### 2. Generate Signed URL (Public)

**Endpoint:** `POST /api/streams/generate-signed-url`

**Request Body:**
```json
{
  "streamKey": "demo-stream-key-123",
  "expiryMinutes": 60,
  "userIP": "192.168.1.100"
}
```

**Request Example:**
```bash
curl -X POST "http://localhost:3000/api/streams/generate-signed-url" \
  -H "Content-Type: application/json" \
  -d '{
    "streamKey": "demo-stream-key-123",
    "expiryMinutes": 60,
    "userIP": "192.168.1.100"
  }'
```

**Response:**
```json
{
  "streamKey": "demo-stream-key-123",
  "signedUrl": "http://3014973486.global.cdnfastest.com/live/demo-stream-key-123.m3u8?token=2PHbRUPhi7KCJYgekF1gLA&time=1633024800",
  "expiresAt": "2025-10-01T12:00:00.000Z",
  "expiryTimestamp": 1633024800,
  "expiryMinutes": 60
}
```

## 🧪 Test Signed URL

### 1. Chạy test script:

```bash
node test-signed-url.js
```

Script này sẽ test:
- Generate URL giống ví dụ PHP của evgcdn
- Generate URL cho CDN demo của bạn
- Generate URL với IP restriction
- Verify signed URL
- Test expired URL
- Test multiple streams

### 2. Test với curl:

```bash
# Test generate signed URL
curl -X POST "http://localhost:3000/api/streams/generate-signed-url" \
  -H "Content-Type: application/json" \
  -d '{
    "streamKey": "demo-stream-key-123",
    "expiryMinutes": 60
  }'
```

## 💻 Code Examples

### JavaScript/Node.js:

```javascript
const { generateSignedStreamUrl } = require('./backend/utils/secureUrl');

// Generate signed URL
const signedUrlData = generateSignedStreamUrl(
  'http://3014973486.global.cdnfastest.com',
  '/live/demo-stream-key-123.m3u8',
  's3cret',
  60,  // 60 minutes
  null // no IP restriction
);

console.log('Signed URL:', signedUrlData.signedUrl);
console.log('Expires At:', signedUrlData.expiresAt);
```

### Frontend (React/JavaScript):

```javascript
// Fetch signed URL from API
async function getSignedStreamUrl(streamId) {
  const response = await fetch(
    `http://localhost:3000/api/streams/${streamId}/signed-url?expiry=120`,
    {
      headers: {
        'Authorization': `Bearer ${yourJwtToken}`
      }
    }
  );
  
  const data = await response.json();
  return data.signedUrl;
}

// Use in video player
const signedUrl = await getSignedStreamUrl(1);
player.src = signedUrl;
```

### PHP (tương tự evgcdn):

```php
<?php
function getSignedUrlParam($cdnResourceUrl, $filePath, $secureToken, $expiryTimestamp, $userIP = NULL){
    $strippedPath = substr($filePath, 0, strrpos($filePath, '/'));
    $invalidChars = ['+','/'];
    $validChars = ['-','_'];
    $hashStr = md5("$secureToken$filePath$expiryTimestamp$userIP", TRUE);
    $valid_str = str_replace($invalidChars, $validChars, base64_encode($hashStr));
    $hotkey_params = str_replace('=', '', $valid_str);        
    $final_str = $cdnResourceUrl . $filePath . '?token=' . $hotkey_params . '&time=' . $expiryTimestamp;
    return $final_str;
}

echo getSignedUrlParam(
    'http://3014973486.global.cdnfastest.com',
    '/live/demo-stream-key-123.m3u8',
    's3cret',
    time() + 3600, // 1 hour from now
    NULL
);
?>
```

## 🔐 Security Best Practices

### 1. Secret Token:
- Không bao giờ expose `CDN_SECURE_TOKEN` trên client-side
- Sử dụng token phức tạp, random
- Thay đổi token định kỳ

### 2. Expiry Time:
- Sử dụng thời gian hết hạn hợp lý (30-120 phút)
- Không set quá lâu để tránh URL bị leak

### 3. IP Restriction:
- Bật IP restriction cho streams quan trọng
- Chú ý users có thể thay đổi IP (mobile networks)

### 4. HTTPS:
- Luôn sử dụng HTTPS cho production
- Update `CDN_BASE_URL` thành `https://`

## 📝 URL Format

Signed URL có format:
```
{CDN_BASE_URL}{FILE_PATH}?token={TOKEN}&time={TIMESTAMP}
```

Ví dụ:
```
http://3014973486.global.cdnfastest.com/live/demo-stream-key-123.m3u8?token=2PHbRUPhi7KCJYgekF1gLA&time=1633024800
```

Trong đó:
- `token`: MD5 hash được encode của (secureToken + filePath + timestamp + IP)
- `time`: Unix timestamp khi URL hết hạn

## ❓ Troubleshooting

### URL bị reject:

1. **Token sai:**
   - Kiểm tra `CDN_SECURE_TOKEN` khớp với CDN config
   - Đảm bảo không có whitespace trong token

2. **URL expired:**
   - Tăng `expiryMinutes`
   - Đồng bộ system time trên server

3. **IP không khớp:**
   - Remove IP restriction hoặc
   - Sử dụng đúng IP của user

### Test verification:

```javascript
const { verifySignedUrl } = require('./backend/utils/secureUrl');

const result = verifySignedUrl(
  'token_from_url',
  timestamp,
  '/live/stream.m3u8',
  'your_secret_token',
  user_ip
);

console.log(result); // { valid: true/false, error: '...' }
```

## 🎬 Integration với Video Player

### HLS.js:

```javascript
const signedUrl = await getSignedStreamUrl(streamId);

const video = document.getElementById('video');
const hls = new Hls();
hls.loadSource(signedUrl);
hls.attachMedia(video);
```

### Video.js:

```javascript
const signedUrl = await getSignedStreamUrl(streamId);

const player = videojs('my-video');
player.src({
  src: signedUrl,
  type: 'application/x-mpegURL'
});
```

## 📞 Support

Nếu có vấn đề, kiểm tra:
1. Backend logs: `docker-compose logs backend`
2. Test script: `node test-signed-url.js`
3. API health: `curl http://localhost:3000/health`

---

**Chúc bạn thành công! 🎉**



