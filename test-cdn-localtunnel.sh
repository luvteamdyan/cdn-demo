#!/bin/bash

LOCALTUNNEL_URL="https://srs-demo.loca.lt"
STREAM_KEY="demo-stream-key-123"

echo "=== Testing CDN Origin with LocalTunnel ==="
echo "LocalTunnel URL: $LOCALTUNNEL_URL"
echo "Stream Key: $STREAM_KEY"
echo ""

# Test HLS stream
echo "1. Testing HLS Stream..."
HLS_URL="$LOCALTUNNEL_URL/live/$STREAM_KEY.m3u8"
echo "URL: $HLS_URL"

HLS_RESPONSE=$(curl -s -H "User-Agent: CDN-Origin/1.0" \
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
FLV_URL="$LOCALTUNNEL_URL/live/$STREAM_KEY.flv"
echo "URL: $FLV_URL"

FLV_RESPONSE=$(curl -s -H "User-Agent: CDN-Origin/1.0" \
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
API_URL="$LOCALTUNNEL_URL/api/v1/streams"
echo "URL: $API_URL"

API_RESPONSE=$(curl -s -H "User-Agent: CDN-Origin/1.0" \
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
VERSIONS_URL="$LOCALTUNNEL_URL/api/v1/versions"
echo "URL: $VERSIONS_URL"

VERSIONS_RESPONSE=$(curl -s -H "User-Agent: CDN-Origin/1.0" \
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
echo "Use this URL as your CDN origin: $LOCALTUNNEL_URL"
echo ""
echo "Required headers for CDN:"
echo "  - User-Agent: CDN-Origin/1.0"
echo ""
echo "Stream URLs:"
echo "  - HLS: $HLS_URL"
echo "  - HTTP-FLV: $FLV_URL"
echo ""
echo "=== CDN Configuration Example ==="
echo "For CDN providers like Cloudflare, KeyCDN, etc.:"
echo "Origin URL: $LOCALTUNNEL_URL"
echo "Path: /live/*"
echo "Headers: User-Agent: CDN-Origin/1.0"
echo ""
echo "Test URLs for CDN:"
echo "  - https://your-cdn-domain.com/live/$STREAM_KEY.flv"
echo "  - https://your-cdn-domain.com/live/$STREAM_KEY.m3u8"


