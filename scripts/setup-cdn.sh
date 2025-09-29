#!/bin/bash

# Script to configure ECGCDN for livestream demo
# This script provides instructions and sample configurations for ECGCDN

echo "🚀 ECGCDN Configuration for Livestream Demo"
echo "============================================"

# Get local IP address
LOCAL_IP=$(hostname -I | awk '{print $1}')

echo ""
echo "📋 Configuration Steps:"
echo ""

echo "1. Login to your ECGCDN dashboard"
echo "   - Go to: https://dashboard.ecgcdn.com"
echo ""

echo "2. Create a new Pull Stream Configuration:"
echo "   - Stream Type: RTMP Pull"
echo "   - Source URL: rtmp://$LOCAL_IP:1935/live"
echo "   - Stream Key: [Your Stream Key]"
echo "   - Output Format: HLS"
echo ""

echo "3. Configure CDN Settings:"
echo "   - Enable Authentication: Yes"
echo "   - Auth URL: http://$LOCAL_IP:3000/api/callback/on_publish"
echo "   - Auth Method: POST"
echo "   - Auth Parameters: stream_key"
echo ""

echo "4. Set up Origin Server:"
echo "   - Origin Type: Custom"
echo "   - Origin URL: rtmp://$LOCAL_IP:1935/live"
echo "   - Timeout: 30 seconds"
echo "   - Retry Count: 3"
echo ""

echo "5. Configure CORS (if needed):"
echo "   - Allow Origins: *"
echo "   - Allow Methods: GET, POST, OPTIONS"
echo "   - Allow Headers: Content-Type, Authorization"
echo ""

echo "📝 Sample ECGCDN Configuration:"
echo "================================"
cat << EOF
{
  "stream_config": {
    "type": "rtmp_pull",
    "source": {
      "url": "rtmp://$LOCAL_IP:1935/live",
      "stream_key": "your_stream_key_here"
    },
    "output": {
      "format": "hls",
      "segment_duration": 10,
      "playlist_duration": 60
    },
    "authentication": {
      "enabled": true,
      "callback_url": "http://$LOCAL_IP:3000/api/callback/on_publish",
      "method": "POST",
      "timeout": 10
    },
    "caching": {
      "enabled": true,
      "ttl": 3600,
      "max_size": "1GB"
    }
  }
}
EOF

echo ""
echo "🔧 Local Network Configuration:"
echo "==============================="
echo "Make sure your local server is accessible from the internet:"
echo "1. Configure port forwarding on your router:"
echo "   - Port 1935 (RTMP) -> $LOCAL_IP:1935"
echo "   - Port 3000 (API) -> $LOCAL_IP:3000"
echo "   - Port 8000 (HLS) -> $LOCAL_IP:8000"
echo ""
echo "2. Or use ngrok for tunneling:"
echo "   ngrok tcp 1935  # For RTMP"
echo "   ngrok http 3000 # For API"
echo "   ngrok http 8000 # For HLS"
echo ""

echo "📱 Test URLs:"
echo "============="
echo "Local RTMP: rtmp://$LOCAL_IP:1935/live/[stream_key]"
echo "Local HLS:  http://$LOCAL_IP:8000/live/[stream_key].m3u8"
echo "Local API:  http://$LOCAL_IP:3000/health"
echo ""

echo "🎯 CDN Test URLs (after configuration):"
echo "======================================"
echo "CDN HLS: https://your-cdn-domain.com/live/[stream_key].m3u8"
echo "CDN API: https://your-cdn-domain.com/api/health"
echo ""

echo "✅ Configuration Complete!"
echo "Remember to:"
echo "1. Update your CDN dashboard with the above settings"
echo "2. Test the stream with OBS using your stream key"
echo "3. Verify the CDN is pulling from your local SRS server"
echo "4. Check logs in both SRS and your backend for any issues"
