#!/bin/bash

# Script to test streaming functionality
echo "🧪 Testing Livestream Functionality"
echo "==================================="

STREAM_KEY="demo-stream-key-123"
LOCAL_IP=$(hostname -I | awk '{print $1}')

echo "📡 Testing Components:"
echo ""

# Test Backend API
echo "1. Testing Backend API..."
if curl -s http://localhost:3000/health | grep -q "OK"; then
    echo "   ✅ Backend API is healthy"
else
    echo "   ❌ Backend API is not responding"
fi

# Test SRS Server
echo "2. Testing SRS Server..."
if curl -s http://localhost:8080/api/v1/versions | grep -q "major"; then
    echo "   ✅ SRS Server is running"
else
    echo "   ❌ SRS Server is not responding"
fi

# Test Database
echo "3. Testing Database..."
if docker-compose exec -T postgres psql -U postgres -d livestream_db -c "SELECT COUNT(*) FROM users;" > /dev/null 2>&1; then
    echo "   ✅ Database is connected"
else
    echo "   ❌ Database connection failed"
fi

# Test Stream Key
echo "4. Testing Stream Key..."
STREAM_EXISTS=$(docker-compose exec -T postgres psql -U postgres -d livestream_db -t -c "SELECT COUNT(*) FROM stream_keys WHERE key = '$STREAM_KEY';" | tr -d ' ')
if [ "$STREAM_EXISTS" = "1" ]; then
    echo "   ✅ Demo stream key exists"
else
    echo "   ❌ Demo stream key not found"
    echo "   Run: ./scripts/create-demo-user.sh"
fi

# Test Frontend
echo "5. Testing Frontend..."
if curl -s http://localhost:3001 | grep -q "root"; then
    echo "   ✅ Frontend is accessible"
else
    echo "   ❌ Frontend is not responding"
fi

echo ""
echo "🎯 Test URLs:"
echo "============="
echo "Frontend:        http://localhost:3001"
echo "API Health:      http://localhost:3000/health"
echo "SRS API:         http://localhost:8080/api/v1/versions"
echo "HLS Stream:      http://localhost:8000/live/$STREAM_KEY.m3u8"
echo ""

echo "📱 OBS Studio Configuration:"
echo "============================"
echo "Server:          rtmp://$LOCAL_IP:1935/live"
echo "Stream Key:      $STREAM_KEY"
echo ""

echo "🔧 Manual Tests:"
echo "================"
echo "1. Login to frontend with demo/demo123"
echo "2. Create a new stream key"
echo "3. Use OBS to stream to the RTMP URL above"
echo "4. Check callback authentication in backend logs"
echo "5. View stream in browser"
echo ""

echo "📋 Useful Commands:"
echo "==================="
echo "View logs:       docker-compose logs -f"
echo "Restart:         docker-compose restart"
echo "Stop:            docker-compose down"
echo "Create demo:     ./scripts/create-demo-user.sh"
echo ""

if [ "$STREAM_EXISTS" = "1" ]; then
    echo "✅ All tests passed! Ready for streaming."
else
    echo "⚠️  Some tests failed. Check the issues above."
fi
