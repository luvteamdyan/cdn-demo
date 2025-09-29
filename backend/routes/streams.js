const express = require('express');
const { v4: uuidv4 } = require('uuid');
const { body, validationResult } = require('express-validator');
const { Pool } = require('pg');

const router = express.Router();
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'livestream_db',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'password',
});

// Middleware to verify JWT token
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  const jwt = require('jsonwebtoken');
  jwt.verify(token, process.env.JWT_SECRET || 'fallback_secret', (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid or expired token' });
    }
    req.user = user;
    next();
  });
};

// Create new stream key
router.post('/', authenticateToken, [
  body('name').isLength({ min: 1 }).trim().escape(),
  body('description').optional().trim()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { name, description } = req.body;
    const streamKey = uuidv4();

    const result = await pool.query(
      'INSERT INTO stream_keys (key, user_id, name, description) VALUES ($1, $2, $3, $4) RETURNING *',
      [streamKey, req.user.userId, name, description]
    );

    res.status(201).json({
      message: 'Stream key created successfully',
      streamKey: result.rows[0]
    });
  } catch (error) {
    console.error('Create stream key error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get all stream keys for user
router.get('/', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT sk.*, 
              COUNT(CASE WHEN s.status = 'online' THEN 1 END) as active_streams
       FROM stream_keys sk
       LEFT JOIN streams s ON sk.id = s.stream_key_id
       WHERE sk.user_id = $1
       GROUP BY sk.id
       ORDER BY sk.created_at DESC`,
      [req.user.userId]
    );

    res.json({ streamKeys: result.rows });
  } catch (error) {
    console.error('Get stream keys error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get specific stream key
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT sk.*, 
              s.status, s.viewer_count, s.started_at
       FROM stream_keys sk
       LEFT JOIN streams s ON sk.id = s.stream_key_id AND s.status = 'online'
       WHERE sk.id = $1 AND sk.user_id = $2`,
      [req.params.id, req.user.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Stream key not found' });
    }

    res.json({ streamKey: result.rows[0] });
  } catch (error) {
    console.error('Get stream key error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update stream key
router.put('/:id', authenticateToken, [
  body('name').optional().isLength({ min: 1 }).trim().escape(),
  body('description').optional().trim(),
  body('is_active').optional().isBoolean()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { name, description, is_active } = req.body;
    const updateFields = [];
    const updateValues = [];
    let paramCount = 1;

    if (name !== undefined) {
      updateFields.push(`name = $${paramCount}`);
      updateValues.push(name);
      paramCount++;
    }

    if (description !== undefined) {
      updateFields.push(`description = $${paramCount}`);
      updateValues.push(description);
      paramCount++;
    }

    if (is_active !== undefined) {
      updateFields.push(`is_active = $${paramCount}`);
      updateValues.push(is_active);
      paramCount++;
    }

    if (updateFields.length === 0) {
      return res.status(400).json({ error: 'No fields to update' });
    }

    updateValues.push(req.params.id, req.user.userId);

    const result = await pool.query(
      `UPDATE stream_keys 
       SET ${updateFields.join(', ')}, updated_at = CURRENT_TIMESTAMP
       WHERE id = $${paramCount} AND user_id = $${paramCount + 1}
       RETURNING *`,
      updateValues
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Stream key not found' });
    }

    res.json({
      message: 'Stream key updated successfully',
      streamKey: result.rows[0]
    });
  } catch (error) {
    console.error('Update stream key error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Delete stream key
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      'DELETE FROM stream_keys WHERE id = $1 AND user_id = $2 RETURNING *',
      [req.params.id, req.user.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Stream key not found' });
    }

    res.json({ message: 'Stream key deleted successfully' });
  } catch (error) {
    console.error('Delete stream key error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get RTMP URL for streaming
router.get('/:id/rtmp-url', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM stream_keys WHERE id = $1 AND user_id = $2 AND is_active = true',
      [req.params.id, req.user.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Stream key not found or inactive' });
    }

    const streamKey = result.rows[0];
    const rtmpUrl = `rtmp://localhost:1935/live/${streamKey.key}`;

    res.json({
      rtmpUrl,
      streamKey: streamKey.key,
      instructions: {
        obs: {
          server: 'rtmp://localhost:1935/live',
          streamKey: streamKey.key
        },
        cdn: {
          server: 'rtmp://your-cdn-domain.com/live',
          streamKey: streamKey.key
        }
      }
    });
  } catch (error) {
    console.error('Get RTMP URL error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
