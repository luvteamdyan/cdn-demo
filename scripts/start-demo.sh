#!/bin/bash

# Script to start the livestream demo
echo "🚀 Starting Livestream Football Demo"
echo "===================================="

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo "📦 Building and starting containers..."
docker-compose up -d --build

echo "⏳ Waiting for services to start..."
sleep 10

echo "🔍 Checking service health..."

# Check backend health
if curl -s http://localhost:3000/health > /dev/null; then
    echo "✅ Backend API is running"
else
    echo "❌ Backend API is not responding"
fi

# Check SRS health
if curl -s http://localhost:8080/api/v1/versions > /dev/null; then
    echo "✅ SRS Server is running"
else
    echo "❌ SRS Server is not responding"
fi

# Check database connection
if docker-compose exec -T postgres psql -U postgres -d livestream_db -c "SELECT NOW();" > /dev/null 2>&1; then
    echo "✅ Database is connected"
else
    echo "❌ Database connection failed"
fi

echo ""
echo "🎯 Demo URLs:"
echo "============="
echo "Frontend:     http://localhost:3001"
echo "Backend API:  http://localhost:3000"
echo "SRS Server:   http://localhost:8080"
echo "HLS Stream:   http://localhost:8000/live/[stream_key].m3u8"
echo ""

echo "👤 Demo Credentials:"
echo "==================="
echo "Username: demo"
echo "Password: demo123"
echo "Stream Key: demo-stream-key-123"
echo ""

echo "📡 RTMP URLs for OBS:"
echo "====================="
echo "Server: rtmp://localhost:1935/live"
echo "Stream Key: demo-stream-key-123"
echo ""

echo "🔧 Next Steps:"
echo "=============="
echo "1. Open http://localhost:3001 in your browser"
echo "2. Login with demo credentials"
echo "3. Create a new stream or use the demo stream key"
echo "4. Configure OBS Studio with the RTMP settings above"
echo "5. Start streaming and watch at: http://localhost:3001/stream/demo-stream-key-123"
echo ""

echo "📋 Useful Commands:"
echo "==================="
echo "View logs:        docker-compose logs -f"
echo "Stop services:    docker-compose down"
echo "Restart:          docker-compose restart"
echo "Create demo user: ./scripts/create-demo-user.sh"
echo ""

echo "🎉 Demo is ready! Happy streaming!"
