const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();
const PORT = 3002;

// Proxy middleware với custom headers
const ngrokProxy = createProxyMiddleware({
  target: 'http://localhost:8000', // SRS server
  changeOrigin: true,
  onProxyReq: (proxyReq, req, res) => {
    // Thêm header để skip ngrok warning
    proxyReq.setHeader('ngrok-skip-browser-warning', 'true');
    proxyReq.setHeader('User-Agent', 'CDN-Origin-Proxy/1.0');
  },
  onProxyRes: (proxyRes, req, res) => {
    // Thêm CORS headers
    proxyRes.headers['Access-Control-Allow-Origin'] = '*';
    proxyRes.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS';
    proxyRes.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization';
  }
});

// Apply proxy to all routes
app.use('/', ngrokProxy);

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    message: 'Ngrok proxy is running',
    target: 'http://localhost:8000'
  });
});

app.listen(PORT, () => {
  console.log(`Ngrok proxy server running on port ${PORT}`);
  console.log(`This proxy adds ngrok-skip-browser-warning header`);
  console.log(`Use this URL for CDN origin: http://localhost:${PORT}`);
});

