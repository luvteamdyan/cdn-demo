# 🔐 Hướng Dẫn Cấu Hình Secure URL trên CDN Dashboard

## 📸 Cấu Hình Hiện Tại

Dựa trên screenshot CDN dashboard, đây là cách cấu hình để match với implementation:

## ✅ Bước 1: Bật Secure URL

- **Status**: ON (màu xanh) ✅

## ✅ Bước 2: Chọn Type

- **Type**: `By Params` ✅
- Đây là đúng vì implementation dùng query parameters: `?token=xxx&time=xxx`

## 🔑 Bước 3: Secret Key (QUAN TRỌNG!)

### Option A: Generate Secret Key mới

1. Click nút **"Generate"** trên dashboard
2. Copy secret key được generate
3. Update vào file `.env`:

```bash
CDN_SECURE_TOKEN=<secret_key_vừa_copy>
```

### Option B: Sử dụng Secret Key có sẵn

1. Mở file `.env` của bạn
2. Copy giá trị của `CDN_SECURE_TOKEN`
3. Paste vào field **"Secret Key"** trên dashboard

### ⚠️ Lưu ý QUAN TRỌNG:

**Secret key trên CDN dashboard PHẢI GIỐNG với `CDN_SECURE_TOKEN` trong `.env`**

```bash
# File: .env
CDN_SECURE_TOKEN=s3cret  # ← Phải giống với Secret Key trên CDN
```

## 🌐 Bước 4: Include User-IP

### Có 2 options:

#### ☐ Không check (Recommended)

**Ưu điểm:**
- Đơn giản hơn
- Không bị vấn đề khi user đổi IP (mobile networks)
- Phù hợp cho livestream public

**Code:**
```javascript
const signedUrl = generateSignedStreamUrl(
  cdnBaseUrl,
  filePath,
  secureToken,
  60,
  null  // ← không cần IP
);
```

#### ✅ Check (Bảo mật cao hơn)

**Ưu điểm:**
- Bảo mật tốt hơn
- Chỉ user với IP cụ thể mới xem được
- Phù hợp cho pay-per-view hoặc private streams

**Code:**
```javascript
const signedUrl = generateSignedStreamUrl(
  cdnBaseUrl,
  filePath,
  secureToken,
  60,
  req.ip  // ← Bắt buộc phải truyền IP
);
```

## 📺 Bước 5: Enable Rewrite M3U8/MPD

### ✅ Recommended: BẬT option này

**Lý do:**
- HLS/DASH playlists chứa links đến nhiều .ts/.m4s files (chunks)
- Nếu bật: CDN tự động sign tất cả chunk URLs
- Nếu không: chỉ playlist được sign, chunks vẫn public

**Ví dụ khi BẬT:**
```m3u8
#EXTM3U
#EXTINF:10.0,
chunk_0.ts?token=xxx&time=yyy
#EXTINF:10.0,
chunk_1.ts?token=xxx&time=yyy
```

**Ví dụ khi TẮT:**
```m3u8
#EXTM3U
#EXTINF:10.0,
chunk_0.ts  ← Không có token, public access!
#EXTINF:10.0,
chunk_1.ts  ← Không có token, public access!
```

**Kết luận:** ✅ **BẬT** cho live streaming

## 🔧 Bước 6: Additional Params (Optional)

### Khi nào cần?

Nếu bạn muốn track hoặc thêm metadata vào URLs:

**Ví dụ use cases:**
- `uid`: User ID để track xem ai đang xem
- `session`: Session ID
- `device`: Device type

### Cách cấu hình:

1. Trên dashboard: Nhập tên param (ví dụ: `uid`) → Enter
2. Update code:

```javascript
// Update backend/utils/secureUrl.js
function getSignedUrlParamWithExtras(cdnResourceUrl, filePath, secureToken, expiryTimestamp, userIP = null, extras = {}) {
  // Hash generation (giữ nguyên)
  const hashInput = `${secureToken}${filePath}${expiryTimestamp}${userIP || ''}`;
  const hash = crypto.createHash('md5').update(hashInput).digest();
  const validStr = hash.toString('base64')
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=/g, '');
  
  // Build query string with extras
  let queryParams = `token=${validStr}&time=${expiryTimestamp}`;
  
  // Add extra parameters
  Object.entries(extras).forEach(([key, value]) => {
    queryParams += `&${key}=${encodeURIComponent(value)}`;
  });
  
  return `${cdnResourceUrl}${filePath}?${queryParams}`;
}

// Usage:
const url = getSignedUrlParamWithExtras(
  cdnBaseUrl,
  filePath,
  secureToken,
  timestamp,
  null,
  { uid: 'user123', device: 'mobile' }
);
// Result: http://cdn.com/stream.m3u8?token=xxx&time=yyy&uid=user123&device=mobile
```

### 💡 Recommendation:

**Để trống** nếu không cần tracking. Có thể thêm sau nếu cần.

---

## 📋 Cấu Hình Đề Xuất

```
┌─────────────────────────────────────────┐
│ Secure Url                     [ON]  ✅ │
├─────────────────────────────────────────┤
│ Type                                    │
│  ┌───────────────────────────────────┐  │
│  │ By Params                      ▼ │  │ ✅
│  └───────────────────────────────────┘  │
├─────────────────────────────────────────┤
│ Secret Key                              │
│  ┌───────────────────────────────────┐  │
│  │ s3cret (match với .env)          │  │ ⚠️ IMPORTANT
│  └───────────────────────────────────┘  │
├─────────────────────────────────────────┤
│ ☐ Include User-IP                       │ ← Uncheck (đơn giản hơn)
│ ✅ Enable Rewrite M3U8/MPD              │ ← Check (cho HLS)
├─────────────────────────────────────────┤
│ Additional Params                       │
│  ┌───────────────────────────────────┐  │
│  │ (leave empty)                    │  │ ← Để trống
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

---

## 🧪 Test Sau Khi Cấu Hình

### 1. Generate test URL:

```bash
node test-signed-url.js
```

### 2. Test với API:

```bash
curl -X POST "http://localhost:3000/api/streams/generate-signed-url" \
  -H "Content-Type: application/json" \
  -d '{
    "streamKey": "demo-stream-key-123",
    "expiryMinutes": 60
  }'
```

### 3. Test URL trên CDN:

```bash
# Copy signed URL từ response
# Paste vào browser hoặc test với curl
curl -I "http://3014973486.global.cdnfastest.com/live/demo-stream-key-123.m3u8?token=xxx&time=yyy"
```

**Expected Result:**
- ✅ 200 OK → Cấu hình đúng!
- ❌ 403 Forbidden → Secret key không match hoặc URL expired
- ❌ 401 Unauthorized → Token không hợp lệ

---

## 🔄 Troubleshooting

### ❌ Lỗi: 403 Forbidden

**Nguyên nhân:**
1. Secret key không match
2. URL đã expired
3. IP không match (nếu bật Include User-IP)

**Giải pháp:**
```bash
# 1. Check secret key
cat .env | grep CDN_SECURE_TOKEN
# Phải giống với Secret Key trên CDN dashboard

# 2. Check expiry time
node -e "console.log(new Date(1759289008 * 1000))"
# Phải > current time

# 3. Tắt Include User-IP nếu đang test
```

### ❌ Lỗi: Token không match

**Nguyên nhân:** Secret key khác nhau giữa backend và CDN

**Giải pháp:**
1. Mở CDN dashboard → copy Secret Key
2. Update `.env`:
```bash
CDN_SECURE_TOKEN=<secret_key_từ_dashboard>
```
3. Restart backend:
```bash
docker-compose restart backend
```

### ❌ Chunks không có token (M3U8 issues)

**Nguyên nhân:** Chưa bật "Enable Rewrite M3U8/MPD"

**Giải pháp:**
- ✅ Check option "Enable Rewrite M3U8/MPD" trên dashboard
- Save và test lại

---

## 📝 Summary

| Setting | Value | Reason |
|---------|-------|--------|
| Secure Url | ✅ ON | Enable bảo mật |
| Type | By Params | Match với implementation |
| Secret Key | `s3cret` | Must match `.env` |
| Include User-IP | ☐ OFF | Đơn giản, flexible |
| Rewrite M3U8 | ✅ ON | Protect HLS chunks |
| Additional Params | Empty | Không cần tracking |

---

## 🚀 Next Steps

1. ✅ Cấu hình CDN theo bảng trên
2. ✅ Sync Secret Key với `.env`
3. ✅ Save settings trên CDN dashboard
4. ✅ Test với `test-signed-url.js`
5. ✅ Test URL thật trên CDN
6. ✅ Integrate vào frontend

**Chúc bạn thành công! 🎉**



