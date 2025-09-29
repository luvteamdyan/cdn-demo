module.exports = {
  database: {
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME || 'livestream_db',
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'password',
  },
  jwt: {
    secret: process.env.JWT_SECRET || 'demo_jwt_secret_key_for_development_only',
    expiresIn: '24h',
  },
  srs: {
    apiUrl: process.env.SRS_API_URL || 'http://srs:8080',
    callbackUrl: process.env.SRS_CALLBACK_URL || 'http://backend:3000/api/callback',
  },
  cdn: {
    domain: process.env.CDN_DOMAIN || 'localhost',
    rtmpUrl: process.env.CDN_RTMP_URL || 'rtmp://localhost:1935/live',
    hlsUrl: process.env.CDN_HLS_URL || 'http://localhost:8000/live',
  },
};
