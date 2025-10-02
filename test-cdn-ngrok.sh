#!/bin/bash

NGROK_URL="https://pleasable-psychographically-cody.ngrok-free.dev"
STREAM_KEY="demo-stream-key-123"

echo "=== Testing CDN Origin with Ngrok ==="
echo "Ngrok URL: $NGROK_URL"
echo "Stream Key: $STREAM_KEY"
echo ""

# Test HLS stream
echo "1. Testing HLS Stream..."
HLS_URL="$NGROK_URL/live/$STREAM_KEY.m3u8"
echo "URL: $HLS_URL"

HLS_RESPONSE=$(curl -s -H "ngrok-skip-browser-warning: true" \
                    -H "User-Agent: CDN-Origin/1.0" \
                    -w "%{http_code}" \
                    "$HLS_URL")

if [[ "$HLS_RESPONSE" == *"200"* ]]; then
    echo "✅ HLS Stream: OK"
    echo "Response: $(echo "$HLS_RESPONSE" | head -c 100)..."
else
    echo "❌ HLS Stream: Failed"
    echo "Response: $HLS_RESPONSE"
fi

echo ""

# Test HTTP-FLV stream
echo "2. Testing HTTP-FLV Stream..."
FLV_URL="$NGROK_URL/live/$STREAM_KEY.flv"
echo "URL: $FLV_URL"

FLV_RESPONSE=$(curl -s -H "ngrok-skip-browser-warning: true" \
                    -H "User-Agent: CDN-Origin/1.0" \
                    -w "%{http_code}" \
                    -I "$FLV_URL")

if [[ "$FLV_RESPONSE" == *"200"* ]]; then
    echo "✅ HTTP-FLV Stream: OK"
else
    echo "❌ HTTP-FLV Stream: Failed"
    echo "Response: $FLV_RESPONSE"
fi

echo ""

# Test SRS API
echo "3. Testing SRS API..."
API_URL="$NGROK_URL/api/v1/streams"
echo "URL: $API_URL"

API_RESPONSE=$(curl -s -H "ngrok-skip-browser-warning: true" \
                    -H "User-Agent: CDN-Origin/1.0" \
                    -w "%{http_code}" \
                    "$API_URL")

if [[ "$API_RESPONSE" == *"200"* ]]; then
    echo "✅ SRS API: OK"
    echo "Response: $(echo "$API_RESPONSE" | head -c 200)..."
else
    echo "❌ SRS API: Failed"
    echo "Response: $API_RESPONSE"
fi

echo ""

# Test SRS versions API
echo "4. Testing SRS Versions API..."
VERSIONS_URL="$NGROK_URL/api/v1/versions"
echo "URL: $VERSIONS_URL"

VERSIONS_RESPONSE=$(curl -s -H "ngrok-skip-browser-warning: true" \
                         -H "User-Agent: CDN-Origin/1.0" \
                         -w "%{http_code}" \
                         "$VERSIONS_URL")

if [[ "$VERSIONS_RESPONSE" == *"200"* ]]; then
    echo "✅ SRS Versions API: OK"
    echo "Response: $(echo "$VERSIONS_RESPONSE" | head -c 200)..."
else
    echo "❌ SRS Versions API: Failed"
    echo "Response: $VERSIONS_RESPONSE"
fi

echo ""
echo "=== CDN Origin Configuration ==="
echo "Use this URL as your CDN origin: $NGROK_URL"
echo ""
echo "Required headers for CDN:"
echo "  - ngrok-skip-browser-warning: true"
echo "  - User-Agent: CDN-Origin/1.0"
echo ""
echo "Stream URLs:"
echo "  - HLS: $HLS_URL"
echo "  - HTTP-FLV: $FLV_URL"
echo ""
echo "=== CDN Configuration Example ==="
echo "For CDN providers like Cloudflare, KeyCDN, etc.:"
echo "Origin URL: $NGROK_URL"
echo "Path: /live/*"
echo "Headers:"
echo "  - ngrok-skip-browser-warning: true"
echo "  - User-Agent: CDN-Origin/1.0"
echo ""
echo "Test URLs for CDN:"
echo "  - https://your-cdn-domain.com/live/$STREAM_KEY.flv"
echo "  - https://your-cdn-domain.com/live/$STREAM_KEY.m3u8"
echo ""
echo "=== Troubleshooting 504 Error ==="
echo "If you still get 504 errors:"
echo "1. Make sure ngrok is running: ps aux | grep ngrok"
echo "2. Check ngrok status: curl http://localhost:4040/api/tunnels"
echo "3. Verify stream is published: curl -I $FLV_URL"
echo "4. Check CDN timeout settings (should be > 30 seconds)"
echo "5. Ensure CDN is forwarding the required headers"


