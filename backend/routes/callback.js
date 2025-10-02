const express = require('express');
const { Pool } = require('pg');

const router = express.Router();
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'livestream_db',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'password',
});

// SRS Callback for stream authentication (POST)
router.post('/on_publish', async (req, res) => {
  try {
    console.log('SRS on_publish callback:', req.body);
    
    const { action, client_id, ip, vhost, app, stream, param } = req.body;
    
    if (action !== 'on_publish') {
      return res.status(400).json({ code: 1, message: 'Invalid action' });
    }

    // Extract stream key from stream field (SRS sends it there)
    const streamKey = stream;
    
    if (!streamKey) {
      console.log('No stream key provided');
      return res.status(200).json({ code: 1, message: 'Stream key required' });
    }

    // Validate stream key in database
    const result = await pool.query(
      'SELECT * FROM stream_keys WHERE key = $1 AND is_active = true',
      [streamKey]
    );

    if (result.rows.length === 0) {
      console.log('Invalid or inactive stream key:', streamKey);
      return res.status(200).json({ code: 1, message: 'Invalid or inactive stream key' });
    }

    const streamKeyData = result.rows[0];
    
    // Create stream record
    await pool.query(
      'INSERT INTO streams (stream_key_id, status, started_at) VALUES ($1, $2, CURRENT_TIMESTAMP)',
      [streamKeyData.id, 'online']
    );

    console.log('Stream authenticated successfully:', streamKey);
    
    // Return success (code 0 means allow)
    res.status(200).json({ 
      code: 0, 
      message: 'Stream authenticated successfully',
      stream_key: streamKey,
      user_id: streamKeyData.user_id
    });

  } catch (error) {
    console.error('Stream authentication error:', error);
    res.status(200).json({ code: 1, message: 'Authentication error' });
  }
});

// SRS Callback for stream authentication (GET - fallback)
router.get('/on_publish', async (req, res) => {
  try {
    console.log('SRS on_publish callback (GET):', req.query);
    
    const { action, client_id, ip, vhost, app, stream, param } = req.query;
    
    if (action !== 'on_publish') {
      return res.status(400).json({ code: 1, message: 'Invalid action' });
    }

    // Extract stream key from stream field (SRS sends it there)
    const streamKey = stream;
    
    if (!streamKey) {
      console.log('No stream key provided');
      return res.status(200).json({ code: 1, message: 'Stream key required' });
    }

    // Validate stream key in database
    const result = await pool.query(
      'SELECT * FROM stream_keys WHERE key = $1 AND is_active = true',
      [streamKey]
    );

    if (result.rows.length === 0) {
      console.log('Invalid or inactive stream key:', streamKey);
      return res.status(200).json({ code: 1, message: 'Invalid or inactive stream key' });
    }

    const streamKeyData = result.rows[0];
    
    // Create stream record
    await pool.query(
      'INSERT INTO streams (stream_key_id, status, started_at) VALUES ($1, $2, CURRENT_TIMESTAMP)',
      [streamKeyData.id, 'online']
    );

    console.log('Stream authenticated successfully (GET):', streamKey);
    
    // Return success (code 0 means allow)
    res.status(200).json({ 
      code: 0, 
      message: 'Stream authenticated successfully',
      stream_key: streamKey,
      user_id: streamKeyData.user_id
    });

  } catch (error) {
    console.error('Stream authentication error (GET):', error);
    res.status(200).json({ code: 1, message: 'Authentication error' });
  }
});

// SRS Callback for stream unpublish (when stream ends)
router.post('/on_unpublish', async (req, res) => {
  try {
    console.log('SRS on_unpublish callback:', req.body);
    
    const { action, client_id, ip, vhost, app, stream } = req.body;
    
    if (action !== 'on_unpublish') {
      return res.status(400).json({ code: 1, message: 'Invalid action' });
    }

    // Extract stream key from stream field
    const streamKey = stream;
    
    if (!streamKey) {
      return res.status(200).json({ code: 1, message: 'Stream key required' });
    }

    // Find and update stream record
    const result = await pool.query(
      `UPDATE streams 
       SET status = 'offline', ended_at = CURRENT_TIMESTAMP, viewer_count = 0
       WHERE stream_key_id = (SELECT id FROM stream_keys WHERE key = $1) 
       AND status = 'online'
       RETURNING *`,
      [streamKey]
    );

    console.log('Stream ended:', streamKey);
    
    // Return success
    res.status(200).json({ 
      code: 0, 
      message: 'Stream ended successfully'
    });

  } catch (error) {
    console.error('Stream unpublish error:', error);
    res.status(200).json({ code: 1, message: 'Unpublish error' });
  }
});

// SRS Callback for client connect (viewer count tracking)
router.post('/on_play', async (req, res) => {
  try {
    console.log('SRS on_play callback:', req.body);
    
    const { action, client_id, ip, vhost, app, stream } = req.body;
    
    if (action !== 'on_play') {
      return res.status(400).json({ code: 1, message: 'Invalid action' });
    }

    // Extract stream key from stream field
    const streamKey = stream;
    
    if (!streamKey) {
      return res.status(200).json({ code: 1, message: 'Stream key required' });
    }

    // Update viewer count
    await pool.query(
      `UPDATE streams 
       SET viewer_count = viewer_count + 1
       WHERE stream_key_id = (SELECT id FROM stream_keys WHERE key = $1) 
       AND status = 'online'`,
      [streamKey]
    );

    console.log('Viewer connected to stream:', streamKey);
    
    res.status(200).json({ 
      code: 0, 
      message: 'Viewer connected successfully'
    });

  } catch (error) {
    console.error('Viewer connect error:', error);
    res.status(200).json({ code: 1, message: 'Connect error' });
  }
});

// SRS Callback for client disconnect
router.post('/on_stop', async (req, res) => {
  try {
    console.log('SRS on_stop callback:', req.body);
    
    const { action, client_id, ip, vhost, app, stream } = req.body;
    
    if (action !== 'on_stop') {
      return res.status(400).json({ code: 1, message: 'Invalid action' });
    }

    // Extract stream key from stream field
    const streamKey = stream;
    
    if (!streamKey) {
      return res.status(200).json({ code: 1, message: 'Stream key required' });
    }

    // Decrease viewer count
    await pool.query(
      `UPDATE streams 
       SET viewer_count = GREATEST(viewer_count - 1, 0)
       WHERE stream_key_id = (SELECT id FROM stream_keys WHERE key = $1) 
       AND status = 'online'`,
      [streamKey]
    );

    console.log('Viewer disconnected from stream:', streamKey);
    
    res.status(200).json({ 
      code: 0, 
      message: 'Viewer disconnected successfully'
    });

  } catch (error) {
    console.error('Viewer disconnect error:', error);
    res.status(200).json({ code: 1, message: 'Disconnect error' });
  }
});


// Health check for callback endpoints
router.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    endpoints: ['on_publish', 'on_unpublish', 'on_play', 'on_stop']
  });
});

module.exports = router;
