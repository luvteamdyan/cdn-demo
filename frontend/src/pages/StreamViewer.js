import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { Play, Pause, Volume2, VolumeX, Maximize, RefreshCw } from 'lucide-react';

const StreamViewer = () => {
  const { streamKey } = useParams();
  const [isPlaying, setIsPlaying] = useState(false);
  const [isMuted, setIsMuted] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);
  const [viewerCount, setViewerCount] = useState(0);
  const [isFullscreen, setIsFullscreen] = useState(false);

  // Stream URLs
  const hlsUrl = `http://localhost:8000/live/${streamKey}.m3u8`;
  const rtmpUrl = `rtmp://localhost:1935/live/${streamKey}`;

  useEffect(() => {
    // Check if stream is available
    checkStreamAvailability();
    
    // Update viewer count every 5 seconds
    const interval = setInterval(updateViewerCount, 5000);
    
    return () => clearInterval(interval);
  }, [streamKey]);

  const checkStreamAvailability = async () => {
    try {
      setIsLoading(true);
      setError(null);
      
      // Try to fetch the HLS manifest
      const response = await fetch(hlsUrl, { method: 'HEAD' });
      if (!response.ok) {
        throw new Error('Stream not found or offline');
      }
      
      setIsLoading(false);
    } catch (err) {
      setError(err.message);
      setIsLoading(false);
    }
  };

  const updateViewerCount = async () => {
    // In a real implementation, this would call your API
    // For demo purposes, we'll simulate viewer count
    setViewerCount(Math.floor(Math.random() * 100) + 1);
  };

  const togglePlayPause = () => {
    const video = document.getElementById('stream-video');
    if (video) {
      if (video.paused) {
        video.play();
        setIsPlaying(true);
      } else {
        video.pause();
        setIsPlaying(false);
      }
    }
  };

  const toggleMute = () => {
    const video = document.getElementById('stream-video');
    if (video) {
      video.muted = !video.muted;
      setIsMuted(video.muted);
    }
  };

  const toggleFullscreen = () => {
    const video = document.getElementById('stream-video');
    if (video) {
      if (!document.fullscreenElement) {
        video.requestFullscreen();
        setIsFullscreen(true);
      } else {
        document.exitFullscreen();
        setIsFullscreen(false);
      }
    }
  };

  const refreshStream = () => {
    checkStreamAvailability();
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-900 flex items-center justify-center">
        <div className="text-center">
          <RefreshCw className="h-12 w-12 text-white animate-spin mx-auto mb-4" />
          <p className="text-white text-lg">Loading stream...</p>
          <p className="text-gray-400 text-sm mt-2">Checking stream availability</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gray-900 flex items-center justify-center">
        <div className="text-center max-w-md">
          <div className="bg-red-600 rounded-full w-16 h-16 flex items-center justify-center mx-auto mb-4">
            <Pause className="h-8 w-8 text-white" />
          </div>
          <h1 className="text-white text-xl font-semibold mb-2">Stream Offline</h1>
          <p className="text-gray-400 mb-4">{error}</p>
          <div className="space-y-2">
            <button
              onClick={refreshStream}
              className="w-full bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors flex items-center justify-center"
            >
              <RefreshCw className="h-4 w-4 mr-2" />
              Refresh
            </button>
            <p className="text-gray-500 text-sm">
              Stream Key: <code className="bg-gray-800 px-2 py-1 rounded">{streamKey}</code>
            </p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-900">
      {/* Header */}
      <div className="bg-black bg-opacity-50 p-4">
        <div className="max-w-6xl mx-auto flex justify-between items-center">
          <div>
            <h1 className="text-white text-xl font-semibold">Live Stream</h1>
            <p className="text-gray-400 text-sm">Stream Key: {streamKey}</p>
          </div>
          <div className="flex items-center space-x-4">
            <div className="flex items-center text-white">
              <div className="w-2 h-2 bg-red-500 rounded-full mr-2 animate-pulse"></div>
              <span className="text-sm">LIVE</span>
            </div>
            <div className="text-white text-sm">
              {viewerCount} viewers
            </div>
          </div>
        </div>
      </div>

      {/* Video Player */}
      <div className="max-w-6xl mx-auto p-4">
        <div className="relative bg-black rounded-lg overflow-hidden shadow-2xl">
          <video
            id="stream-video"
            className="video-player w-full h-auto"
            controls
            autoPlay
            muted={isMuted}
            onLoadStart={() => setIsLoading(true)}
            onCanPlay={() => setIsLoading(false)}
            onPlay={() => setIsPlaying(true)}
            onPause={() => setIsPlaying(false)}
          >
            <source src={hlsUrl} type="application/x-mpegURL" />
            <p>Your browser does not support HLS streaming.</p>
          </video>

          {/* Custom Controls Overlay */}
          <div className="absolute bottom-4 left-4 right-4 bg-black bg-opacity-75 rounded-lg p-4 opacity-0 hover:opacity-100 transition-opacity duration-300">
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-4">
                <button
                  onClick={togglePlayPause}
                  className="text-white hover:text-blue-400 transition-colors"
                >
                  {isPlaying ? (
                    <Pause className="h-6 w-6" />
                  ) : (
                    <Play className="h-6 w-6" />
                  )}
                </button>
                
                <button
                  onClick={toggleMute}
                  className="text-white hover:text-blue-400 transition-colors"
                >
                  {isMuted ? (
                    <VolumeX className="h-6 w-6" />
                  ) : (
                    <Volume2 className="h-6 w-6" />
                  )}
                </button>
              </div>

              <div className="flex items-center space-x-4">
                <button
                  onClick={refreshStream}
                  className="text-white hover:text-blue-400 transition-colors"
                  title="Refresh Stream"
                >
                  <RefreshCw className="h-6 w-6" />
                </button>
                
                <button
                  onClick={toggleFullscreen}
                  className="text-white hover:text-blue-400 transition-colors"
                  title="Fullscreen"
                >
                  <Maximize className="h-6 w-6" />
                </button>
              </div>
            </div>
          </div>

          {/* Loading Overlay */}
          {isLoading && (
            <div className="absolute inset-0 bg-black bg-opacity-50 flex items-center justify-center">
              <div className="text-center">
                <RefreshCw className="h-8 w-8 text-white animate-spin mx-auto mb-2" />
                <p className="text-white text-sm">Buffering...</p>
              </div>
            </div>
          )}
        </div>

        {/* Stream Info */}
        <div className="mt-6 bg-gray-800 rounded-lg p-6">
          <h2 className="text-white text-lg font-semibold mb-4">Stream Information</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-gray-400 text-sm mb-1">Stream Key</label>
              <code className="bg-gray-900 text-green-400 px-3 py-2 rounded block">
                {streamKey}
              </code>
            </div>
            <div>
              <label className="block text-gray-400 text-sm mb-1">RTMP URL</label>
              <code className="bg-gray-900 text-blue-400 px-3 py-2 rounded block text-xs break-all">
                {rtmpUrl}
              </code>
            </div>
            <div>
              <label className="block text-gray-400 text-sm mb-1">HLS URL</label>
              <code className="bg-gray-900 text-purple-400 px-3 py-2 rounded block text-xs break-all">
                {hlsUrl}
              </code>
            </div>
            <div>
              <label className="block text-gray-400 text-sm mb-1">Status</label>
              <div className="flex items-center">
                <div className="w-2 h-2 bg-red-500 rounded-full mr-2 animate-pulse"></div>
                <span className="text-green-400 font-medium">Live</span>
              </div>
            </div>
          </div>
        </div>

        {/* Instructions */}
        <div className="mt-6 bg-blue-900 bg-opacity-30 border border-blue-500 rounded-lg p-6">
          <h3 className="text-blue-400 text-lg font-semibold mb-4">How to Stream</h3>
          <div className="space-y-3 text-gray-300">
            <p>1. Open OBS Studio</p>
            <p>2. Go to Settings → Stream</p>
            <p>3. Set Server to: <code className="bg-gray-800 px-2 py-1 rounded text-blue-400">rtmp://localhost:1935/live</code></p>
            <p>4. Set Stream Key to: <code className="bg-gray-800 px-2 py-1 rounded text-green-400">{streamKey}</code></p>
            <p>5. Click "Start Streaming"</p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default StreamViewer;
