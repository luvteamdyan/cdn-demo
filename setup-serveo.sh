#!/bin/bash

echo "=== Serveo Setup (SSH-based, Rất ổn định) ==="
echo ""

echo "Serveo advantages:"
echo "✅ Miễn phí"
echo "✅ Không cần cài đặt gì"
echo "✅ Sử dụng SSH (rất ổn định)"
echo "✅ Không có warning page"
echo "✅ URL có thể tùy chỉnh"
echo ""

echo "Usage:"
echo "ssh -R 80:localhost:8000 serveo.net"
echo ""
echo "Hoặc với subdomain tùy chỉnh:"
echo "ssh -R srs-demo:80:localhost:8000 serveo.net"
echo ""

# Start serveo
echo "Starting Serveo tunnel..."
ssh -R 80:localhost:8000 serveo.net




