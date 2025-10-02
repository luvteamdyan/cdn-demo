#!/bin/bash

echo "=== Bore Setup (Rust-based, Nhanh & Ổn định) ==="
echo ""

# Install bore
if ! command -v bore &> /dev/null; then
    echo "Installing bore..."
    cargo install bore-cli
    # Or download binary
    # curl -L https://github.com/ekzhang/bore/releases/download/v0.5.0/bore-v0.5.0-x86_64-apple-darwin.tar.gz | tar xz
    # sudo mv bore /usr/local/bin/
fi

echo "Bore advantages:"
echo "✅ Miễn phí"
echo "✅ Viết bằng Rust (rất nhanh)"
echo "✅ Không có warning page"
echo "✅ Ổn định cao"
echo "✅ Subdomain tùy chỉnh"
echo ""

echo "Usage:"
echo "bore local 8000 --to bore.pub"
echo ""
echo "Hoặc với subdomain:"
echo "bore local 8000 --to bore.pub --subdomain srs-demo"
echo ""

# Start bore
echo "Starting Bore tunnel..."
bore local 8000 --to bore.pub --subdomain srs-demo




