#!/bin/bash

echo "=== Ngrok Alternatives for CDN Origin ==="
echo ""

echo "1. Cloudflare Tunnel (Khuyến nghị nhất)"
echo "   ✅ Miễn phí, ổn định, không warning page"
echo "   ✅ Có thể dùng custom domain"
echo "   📝 Cần đăng ký Cloudflare account"
echo "   🚀 Chạy: ./setup-cloudflare-tunnel.sh"
echo ""

echo "2. LocalTunnel"
echo "   ✅ Miễn phí, đơn giản"
echo "   ✅ Không cần đăng ký"
echo "   ⚠️  URL có thể thay đổi"
echo "   🚀 Chạy: ./setup-localtunnel.sh"
echo ""

echo "3. Serveo (SSH-based)"
echo "   ✅ Miễn phí, rất ổn định"
echo "   ✅ Không cần cài đặt"
echo "   ✅ URL có thể tùy chỉnh"
echo "   🚀 Chạy: ./setup-serveo.sh"
echo ""

echo "4. Bore (Rust-based)"
echo "   ✅ Miễn phí, nhanh"
echo "   ✅ Ổn định cao"
echo "   📝 Cần cài đặt"
echo "   🚀 Chạy: ./setup-bore.sh"
echo ""

echo "5. VPS + Domain (Giải pháp production)"
echo "   ✅ Hoàn toàn kiểm soát"
echo "   ✅ URL ổn định vĩnh viễn"
echo "   ✅ Không giới hạn"
echo "   💰 Cần VPS và domain"
echo ""

echo "=== So sánh với Ngrok ==="
echo "Ngrok Free:"
echo "  ❌ Warning page"
echo "  ❌ URL thay đổi mỗi lần restart"
echo "  ❌ Giới hạn bandwidth"
echo ""
echo "Alternatives:"
echo "  ✅ Không warning page"
echo "  ✅ Ổn định hơn"
echo "  ✅ Miễn phí hoàn toàn"
echo ""

echo "Chọn giải pháp nào? (1-5)"
read -p "Enter choice: " choice

case $choice in
    1)
        echo "Setting up Cloudflare Tunnel..."
        ./setup-cloudflare-tunnel.sh
        ;;
    2)
        echo "Setting up LocalTunnel..."
        ./setup-localtunnel.sh
        ;;
    3)
        echo "Setting up Serveo..."
        ./setup-serveo.sh
        ;;
    4)
        echo "Setting up Bore..."
        ./setup-bore.sh
        ;;
    5)
        echo "VPS setup guide:"
        echo "1. Mua VPS (DigitalOcean, Linode, Vultr)"
        echo "2. Mua domain"
        echo "3. Cấu hình DNS"
        echo "4. Deploy SRS server"
        echo "5. Setup SSL certificate"
        ;;
    *)
        echo "Invalid choice"
        ;;
esac




