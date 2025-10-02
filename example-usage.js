/**
 * EXAMPLE: Cách sử dụng Signed URL trong ứng dụng
 */

// ============================================================================
// 1. BACKEND - Generate Signed URL trong route handler
// ============================================================================

const express = require('express');
const { generateSignedStreamUrl } = require('./backend/utils/secureUrl');
const config = require('./backend/config');

const app = express();

// Example endpoint để frontend lấy signed URL
app.get('/api/get-stream-url/:streamKey', async (req, res) => {
  const { streamKey } = req.params;
  const { expiry = 60, ip } = req.query;
  
  // Generate signed URL
  const cdnBaseUrl = process.env.CDN_BASE_URL || 'http://3014973486.global.cdnfastest.com';
  const filePath = `/live/${streamKey}.m3u8`;
  
  const signedUrlData = generateSignedStreamUrl(
    cdnBaseUrl,
    filePath,
    config.cdn.secureToken,
    parseInt(expiry),
    ip || req.ip
  );
  
  res.json({
    success: true,
    data: signedUrlData
  });
});

// ============================================================================
// 2. FRONTEND - Fetch và sử dụng Signed URL
// ============================================================================

// React Component Example
class VideoPlayer extends React.Component {
  state = {
    signedUrl: null,
    loading: true
  };
  
  async componentDidMount() {
    await this.fetchSignedUrl();
  }
  
  async fetchSignedUrl() {
    try {
      const response = await fetch(
        `http://localhost:3000/api/streams/1/signed-url?expiry=120`,
        {
          headers: {
            'Authorization': `Bearer ${this.props.authToken}`
          }
        }
      );
      
      const data = await response.json();
      
      this.setState({ 
        signedUrl: data.signedUrl,
        loading: false 
      });
      
      // Initialize video player with signed URL
      this.initializePlayer(data.signedUrl);
    } catch (error) {
      console.error('Failed to get signed URL:', error);
    }
  }
  
  initializePlayer(url) {
    // HLS.js example
    if (Hls.isSupported()) {
      const hls = new Hls();
      hls.loadSource(url);
      hls.attachMedia(this.videoElement);
    }
    // Native HLS support (Safari)
    else if (this.videoElement.canPlayType('application/vnd.apple.mpegurl')) {
      this.videoElement.src = url;
    }
  }
  
  render() {
    if (this.state.loading) {
      return <div>Loading...</div>;
    }
    
    return (
      <video 
        ref={el => this.videoElement = el}
        controls 
        autoPlay
      />
    );
  }
}

// ============================================================================
// 3. VANILLA JAVASCRIPT - Simple fetch example
// ============================================================================

async function playStream(streamId, authToken) {
  // Fetch signed URL from API
  const response = await fetch(
    `http://localhost:3000/api/streams/${streamId}/signed-url?expiry=60`,
    {
      headers: {
        'Authorization': `Bearer ${authToken}`
      }
    }
  );
  
  const data = await response.json();
  
  console.log('Signed URL:', data.signedUrl);
  console.log('Expires at:', data.expiresAt);
  
  // Use the signed URL in your video player
  const video = document.getElementById('video-player');
  const hls = new Hls();
  hls.loadSource(data.signedUrl);
  hls.attachMedia(video);
  
  hls.on(Hls.Events.MANIFEST_PARSED, () => {
    video.play();
  });
}

// ============================================================================
// 4. PUBLIC STREAM - Generate signed URL without authentication
// ============================================================================

async function getPublicStreamUrl(streamKey) {
  const response = await fetch(
    'http://localhost:3000/api/streams/generate-signed-url',
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        streamKey: streamKey,
        expiryMinutes: 30
      })
    }
  );
  
  const data = await response.json();
  return data.signedUrl;
}

// Usage
getPublicStreamUrl('demo-stream-key-123').then(url => {
  console.log('Public stream URL:', url);
  // Use URL in player
});

// ============================================================================
// 5. SHARE STREAM - Generate URL để share với người khác
// ============================================================================

async function generateShareableLink(streamId, authToken, expiryMinutes = 120) {
  const response = await fetch(
    `http://localhost:3000/api/streams/${streamId}/signed-url?expiry=${expiryMinutes}`,
    {
      headers: {
        'Authorization': `Bearer ${authToken}`
      }
    }
  );
  
  const data = await response.json();
  
  // Create a shareable link
  const shareableUrl = data.signedUrl;
  const expiresAt = new Date(data.expiresAt);
  
  return {
    url: shareableUrl,
    message: `Stream link (expires at ${expiresAt.toLocaleString()})`,
    copyToClipboard: () => {
      navigator.clipboard.writeText(shareableUrl);
      alert('Link copied to clipboard!');
    }
  };
}

// Usage
generateShareableLink(1, 'your-jwt-token', 60).then(result => {
  console.log(result.message);
  console.log('URL:', result.url);
  // result.copyToClipboard(); // Copy to clipboard
});

// ============================================================================
// 6. EMBED PLAYER - Create embeddable player with signed URL
// ============================================================================

function createEmbedPlayer(containerId, streamId, authToken) {
  const container = document.getElementById(containerId);
  
  // Create video element
  const video = document.createElement('video');
  video.controls = true;
  video.autoplay = true;
  video.style.width = '100%';
  video.style.maxWidth = '800px';
  
  container.appendChild(video);
  
  // Fetch and load stream
  fetch(`http://localhost:3000/api/streams/${streamId}/signed-url`, {
    headers: { 'Authorization': `Bearer ${authToken}` }
  })
  .then(res => res.json())
  .then(data => {
    const hls = new Hls();
    hls.loadSource(data.signedUrl);
    hls.attachMedia(video);
    
    // Show expiry warning
    const expiryDate = new Date(data.expiresAt);
    const warning = document.createElement('p');
    warning.textContent = `Link expires at: ${expiryDate.toLocaleString()}`;
    warning.style.color = '#ff6600';
    container.appendChild(warning);
  })
  .catch(error => {
    console.error('Failed to load stream:', error);
    container.innerHTML = '<p>Failed to load stream</p>';
  });
}

// Usage
createEmbedPlayer('player-container', 1, 'your-jwt-token');

// ============================================================================
// 7. AUTO REFRESH - Tự động refresh URL trước khi hết hạn
// ============================================================================

class StreamPlayer {
  constructor(streamId, authToken) {
    this.streamId = streamId;
    this.authToken = authToken;
    this.refreshInterval = null;
    this.currentUrl = null;
    this.expiryTimestamp = null;
  }
  
  async start() {
    await this.refreshUrl();
    this.scheduleRefresh();
  }
  
  async refreshUrl() {
    try {
      const response = await fetch(
        `http://localhost:3000/api/streams/${this.streamId}/signed-url?expiry=60`,
        {
          headers: { 'Authorization': `Bearer ${this.authToken}` }
        }
      );
      
      const data = await response.json();
      this.currentUrl = data.signedUrl;
      this.expiryTimestamp = data.expiryTimestamp;
      
      console.log('URL refreshed:', this.currentUrl);
      console.log('Expires at:', data.expiresAt);
      
      // Update player source if needed
      this.updatePlayerSource(this.currentUrl);
    } catch (error) {
      console.error('Failed to refresh URL:', error);
    }
  }
  
  scheduleRefresh() {
    // Refresh 5 minutes before expiry
    const now = Math.floor(Date.now() / 1000);
    const timeUntilRefresh = (this.expiryTimestamp - now - 300) * 1000;
    
    if (timeUntilRefresh > 0) {
      setTimeout(() => {
        this.refreshUrl();
        this.scheduleRefresh();
      }, timeUntilRefresh);
    }
  }
  
  updatePlayerSource(url) {
    // Update your player source here
    console.log('Updating player with new URL:', url);
  }
  
  stop() {
    if (this.refreshInterval) {
      clearInterval(this.refreshInterval);
    }
  }
}

// Usage
const player = new StreamPlayer(1, 'your-jwt-token');
player.start();

// ============================================================================
// 8. CURL EXAMPLES - Test từ command line
// ============================================================================

/*
# 1. Get signed URL (authenticated)
curl -X GET "http://localhost:3000/api/streams/1/signed-url?expiry=120" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# 2. Generate signed URL (public)
curl -X POST "http://localhost:3000/api/streams/generate-signed-url" \
  -H "Content-Type: application/json" \
  -d '{
    "streamKey": "demo-stream-key-123",
    "expiryMinutes": 60,
    "userIP": "192.168.1.100"
  }'

# 3. Test the signed URL
curl -I "http://3014973486.global.cdnfastest.com/live/demo-stream-key-123.m3u8?token=xxx&time=xxx"
*/

console.log('Examples loaded successfully!');
console.log('Check the code above for different usage patterns.');



