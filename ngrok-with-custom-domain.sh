#!/bin/bash

# Cách 2: Sử dụng ngrok với custom domain (cần ngrok account)
# Uncomment và thay đổi domain nếu bạn có ngrok account

# ngrok http 8000 --domain=your-custom-domain.ngrok.io

echo "Để sử dụng custom domain:"
echo "1. Đăng ký ngrok account tại https://ngrok.com"
echo "2. Lấy auth token từ dashboard"
echo "3. Chạy: ngrok config add-authtoken YOUR_TOKEN"
echo "4. Tạo custom domain: ngrok http 8000 --domain=your-domain.ngrok.io"
echo ""
echo "Hoặc sử dụng cách 1 với proxy server"

