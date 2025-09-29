#!/bin/bash
echo "🔧 Lấy thông tin cấu hình cho CDN"
echo "=================================="

echo ""
echo "📡 Network Information:"
echo "======================="

# Get local IP
LOCAL_IP=$(hostname -I | awk '{print $1}')
echo "Local IP: $LOCAL_IP"

echo ""
echo "🎯 CDN Configuration:"
echo "===================="
echo "Origin URL: rtmp://$LOCAL_IP:1935/live"
echo "Auth URL: http://$LOCAL_IP:3000/api/callback/on_publish"
echo ""

echo "📱 OBS Studio Configuration:"
echo "============================"
echo "Server: rtmp://$LOCAL_IP:1935/live"
echo "Stream Key: demo-stream-key-123"
echo ""

echo "🌐 Test URLs:"
echo "============="
echo "Local HLS: http://$LOCAL_IP:8000/live/demo-stream-key-123.m3u8"
echo "API Health: http://$LOCAL_IP:3000/health"
echo ""

echo "🔧 Next Steps:"
echo "=============="
echo "1. Update CDN Dashboard:"
echo "   - Origin URL: rtmp://$LOCAL_IP:1935/live"
echo "   - Auth URL: http://$LOCAL_IP:3000/api/callback/on_publish"
echo ""
echo "2. Configure OBS with the settings above"
echo "3. Start streaming and test CDN URL"
echo ""

echo "💡 If you need public access, use ngrok:"
echo "   ngrok tcp 1935"
echo "   ngrok http 3000"
echo ""

echo "📋 CDN Dashboard Settings:"
echo "=========================="
echo "Group ID: 712"
echo "Site ID: 50074"
echo "Origin URL: rtmp://$LOCAL_IP:1935/live (CHANGE THIS)"
echo "CDN URL: 3014973486.global.cdnfastest.com"
echo "Auth URL: http://$LOCAL_IP:3000/api/callback/on_publish (ADD THIS)"
echo ""
