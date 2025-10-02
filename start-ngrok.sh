#!/bin/bash

echo "Starting ngrok tunnel for SRS server..."
echo "This will create a public tunnel to your local SRS server on port 8000"
echo ""

# Start ngrok in background
ngrok http 8000 --log=stdout > ngrok.log 2>&1 &
NGROK_PID=$!

echo "Ngrok started with PID: $NGROK_PID"
echo "Waiting for ngrok to initialize..."

# Wait for ngrok to start
sleep 5

# Get tunnel URL
echo "Getting tunnel URL..."
TUNNEL_URL=$(curl -s http://localhost:4040/api/tunnels | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if data['tunnels']:
        tunnel = data['tunnels'][0]
        print(tunnel['public_url'])
    else:
        print('No tunnels found')
except:
    print('Error getting tunnel info')
")

if [ "$TUNNEL_URL" != "No tunnels found" ] && [ "$TUNNEL_URL" != "Error getting tunnel info" ]; then
    echo ""
    echo "✅ Ngrok tunnel created successfully!"
    echo "🌐 Public URL: $TUNNEL_URL"
    echo ""
    echo "Your SRS server is now accessible at:"
    echo "  HLS Stream: $TUNNEL_URL/live/demo-stream-key-123.m3u8"
    echo "  HTTP-FLV: $TUNNEL_URL/live/demo-stream-key-123.flv"
    echo ""
    echo "You can now configure your CDN to use this URL as origin:"
    echo "  Origin URL: $TUNNEL_URL"
    echo ""
    echo "To stop ngrok, run: kill $NGROK_PID"
    echo "Ngrok web interface: http://localhost:4040"
else
    echo "❌ Failed to get tunnel URL"
    echo "Check ngrok.log for details"
    kill $NGROK_PID
    exit 1
fi

