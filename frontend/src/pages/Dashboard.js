import React from 'react';
import { Link } from 'react-router-dom';
import { useQuery } from 'react-query';
import axios from 'axios';
import Layout from '../components/Layout';
import { Video, Plus, Users, Clock, TrendingUp } from 'lucide-react';

const Dashboard = () => {
  const { data: streamKeys, isLoading } = useQuery(
    'streamKeys',
    () => axios.get('/api/streams').then(res => res.data.streamKeys),
    {
      refetchInterval: 5000, // Refresh every 5 seconds
    }
  );

  const totalStreams = streamKeys?.length || 0;
  const activeStreams = streamKeys?.filter(sk => sk.active_streams > 0).length || 0;
  const totalViewers = streamKeys?.reduce((sum, sk) => sum + (sk.viewer_count || 0), 0) || 0;

  if (isLoading) {
    return (
      <Layout>
        <div className="flex items-center justify-center h-64">
          <div className="loading-spinner"></div>
        </div>
      </Layout>
    );
  }

  return (
    <Layout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
            <p className="text-gray-600">Manage your livestreams and monitor performance</p>
          </div>
          <Link
            to="/streams"
            className="inline-flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
          >
            <Plus className="h-4 w-4 mr-2" />
            New Stream
          </Link>
        </div>

        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
          <div className="card">
            <div className="flex items-center">
              <div className="p-2 bg-blue-100 rounded-lg">
                <Video className="h-6 w-6 text-blue-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Total Streams</p>
                <p className="text-2xl font-bold text-gray-900">{totalStreams}</p>
              </div>
            </div>
          </div>

          <div className="card">
            <div className="flex items-center">
              <div className="p-2 bg-green-100 rounded-lg">
                <TrendingUp className="h-6 w-6 text-green-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Active Streams</p>
                <p className="text-2xl font-bold text-gray-900">{activeStreams}</p>
              </div>
            </div>
          </div>

          <div className="card">
            <div className="flex items-center">
              <div className="p-2 bg-purple-100 rounded-lg">
                <Users className="h-6 w-6 text-purple-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Total Viewers</p>
                <p className="text-2xl font-bold text-gray-900">{totalViewers}</p>
              </div>
            </div>
          </div>

          <div className="card">
            <div className="flex items-center">
              <div className="p-2 bg-orange-100 rounded-lg">
                <Clock className="h-6 w-6 text-orange-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Uptime</p>
                <p className="text-2xl font-bold text-gray-900">99.9%</p>
              </div>
            </div>
          </div>
        </div>

        {/* Recent Streams */}
        <div className="card">
          <div className="flex justify-between items-center mb-6">
            <h2 className="text-lg font-semibold text-gray-900">Recent Streams</h2>
            <Link
              to="/streams"
              className="text-blue-600 hover:text-blue-700 text-sm font-medium"
            >
              View all
            </Link>
          </div>

          {streamKeys && streamKeys.length > 0 ? (
            <div className="space-y-4">
              {streamKeys.slice(0, 5).map((streamKey) => (
                <div
                  key={streamKey.id}
                  className="flex items-center justify-between p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
                >
                  <div className="flex items-center space-x-4">
                    <div className="p-2 bg-gray-100 rounded-lg">
                      <Video className="h-5 w-5 text-gray-600" />
                    </div>
                    <div>
                      <h3 className="font-medium text-gray-900">{streamKey.name}</h3>
                      <p className="text-sm text-gray-600">{streamKey.description || 'No description'}</p>
                    </div>
                  </div>
                  <div className="flex items-center space-x-4">
                    <span
                      className={`status-${streamKey.active_streams > 0 ? 'online' : 'offline'}`}
                    >
                      {streamKey.active_streams > 0 ? 'Live' : 'Offline'}
                    </span>
                    {streamKey.active_streams > 0 && (
                      <span className="text-sm text-gray-600">
                        {streamKey.viewer_count || 0} viewers
                      </span>
                    )}
                    <Link
                      to={`/stream/${streamKey.key}`}
                      className="text-blue-600 hover:text-blue-700 text-sm font-medium"
                    >
                      View
                    </Link>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="text-center py-8">
              <Video className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">No streams yet</h3>
              <p className="text-gray-600 mb-4">Create your first stream to get started</p>
              <Link
                to="/streams"
                className="inline-flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
              >
                <Plus className="h-4 w-4 mr-2" />
                Create Stream
              </Link>
            </div>
          )}
        </div>

        {/* Quick Actions */}
        <div className="card">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Quick Actions</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <Link
              to="/streams"
              className="flex items-center p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
            >
              <Plus className="h-5 w-5 text-blue-600 mr-3" />
              <div>
                <h3 className="font-medium text-gray-900">Create Stream</h3>
                <p className="text-sm text-gray-600">Set up a new livestream</p>
              </div>
            </Link>
            
            <Link
              to="/streams"
              className="flex items-center p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
            >
              <Video className="h-5 w-5 text-green-600 mr-3" />
              <div>
                <h3 className="font-medium text-gray-900">Manage Streams</h3>
                <p className="text-sm text-gray-600">View and edit existing streams</p>
              </div>
            </Link>
            
            <div className="flex items-center p-4 border border-gray-200 rounded-lg bg-gray-50">
              <TrendingUp className="h-5 w-5 text-purple-600 mr-3" />
              <div>
                <h3 className="font-medium text-gray-900">Analytics</h3>
                <p className="text-sm text-gray-600">Coming soon</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
};

export default Dashboard;
