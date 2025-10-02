#!/bin/bash

echo "=== LocalTunnel Setup (Đơn giản & Miễn phí) ==="
echo ""

# Install localtunnel
if ! command -v lt &> /dev/null; then
    echo "Installing localtunnel..."
    npm install -g localtunnel
fi

echo "LocalTunnel advantages:"
echo "✅ Miễn phí"
echo "✅ Không cần đăng ký"
echo "✅ Đơn giản sử dụng"
echo "✅ Không có warning page"
echo ""

echo "Usage:"
echo "lt --port 8000 --subdomain srs-demo"
echo ""
echo "This will create: https://srs-demo.loca.lt"
echo ""

# Start localtunnel
echo "Starting LocalTunnel..."
lt --port 8000 --subdomain srs-demo




