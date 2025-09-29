import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from 'react-query';
import axios from 'axios';
import Layout from '../components/Layout';
import { useForm } from 'react-hook-form';
import toast from 'react-hot-toast';
import { 
  Plus, 
  Video, 
  Copy, 
  Edit, 
  Trash2, 
  Eye,
  ExternalLink,
  CheckCircle,
  XCircle
} from 'lucide-react';

const StreamManager = () => {
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [editingStream, setEditingStream] = useState(null);
  const queryClient = useQueryClient();

  const { data: streamKeys, isLoading } = useQuery(
    'streamKeys',
    () => axios.get('/api/streams').then(res => res.data.streamKeys),
    {
      refetchInterval: 5000,
    }
  );

  const createMutation = useMutation(
    (data) => axios.post('/api/streams', data),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('streamKeys');
        setShowCreateModal(false);
        toast.success('Stream created successfully!');
      },
      onError: (error) => {
        toast.error(error.response?.data?.error || 'Failed to create stream');
      },
    }
  );

  const updateMutation = useMutation(
    ({ id, data }) => axios.put(`/api/streams/${id}`, data),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('streamKeys');
        setEditingStream(null);
        toast.success('Stream updated successfully!');
      },
      onError: (error) => {
        toast.error(error.response?.data?.error || 'Failed to update stream');
      },
    }
  );

  const deleteMutation = useMutation(
    (id) => axios.delete(`/api/streams/${id}`),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('streamKeys');
        toast.success('Stream deleted successfully!');
      },
      onError: (error) => {
        toast.error(error.response?.data?.error || 'Failed to delete stream');
      },
    }
  );

  const copyToClipboard = (text) => {
    navigator.clipboard.writeText(text);
    toast.success('Copied to clipboard!');
  };

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
            <h1 className="text-2xl font-bold text-gray-900">Stream Manager</h1>
            <p className="text-gray-600">Create and manage your livestreams</p>
          </div>
          <button
            onClick={() => setShowCreateModal(true)}
            className="inline-flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
          >
            <Plus className="h-4 w-4 mr-2" />
            New Stream
          </button>
        </div>

        {/* Streams List */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {streamKeys && streamKeys.length > 0 ? (
            streamKeys.map((streamKey) => (
              <StreamCard
                key={streamKey.id}
                streamKey={streamKey}
                onEdit={setEditingStream}
                onDelete={deleteMutation.mutate}
                onCopy={copyToClipboard}
              />
            ))
          ) : (
            <div className="col-span-2 card text-center py-12">
              <Video className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">No streams yet</h3>
              <p className="text-gray-600 mb-4">Create your first stream to get started</p>
              <button
                onClick={() => setShowCreateModal(true)}
                className="inline-flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
              >
                <Plus className="h-4 w-4 mr-2" />
                Create Stream
              </button>
            </div>
          )}
        </div>

        {/* Create/Edit Modal */}
        {(showCreateModal || editingStream) && (
          <StreamModal
            streamKey={editingStream}
            onSubmit={editingStream ? 
              (data) => updateMutation.mutate({ id: editingStream.id, data }) :
              createMutation.mutate
            }
            onClose={() => {
              setShowCreateModal(false);
              setEditingStream(null);
            }}
            loading={createMutation.isLoading || updateMutation.isLoading}
          />
        )}
      </div>
    </Layout>
  );
};

const StreamCard = ({ streamKey, onEdit, onDelete, onCopy }) => {
  const [showDetails, setShowDetails] = useState(false);

  return (
    <div className="card">
      <div className="flex justify-between items-start mb-4">
        <div>
          <h3 className="text-lg font-semibold text-gray-900">{streamKey.name}</h3>
          <p className="text-sm text-gray-600">{streamKey.description || 'No description'}</p>
        </div>
        <div className="flex space-x-2">
          <button
            onClick={() => onEdit(streamKey)}
            className="p-2 text-gray-400 hover:text-blue-600 transition-colors"
          >
            <Edit className="h-4 w-4" />
          </button>
          <button
            onClick={() => onDelete(streamKey.id)}
            className="p-2 text-gray-400 hover:text-red-600 transition-colors"
          >
            <Trash2 className="h-4 w-4" />
          </button>
        </div>
      </div>

      <div className="flex items-center justify-between mb-4">
        <span
          className={`status-${streamKey.active_streams > 0 ? 'online' : 'offline'}`}
        >
          {streamKey.active_streams > 0 ? 'Live' : 'Offline'}
        </span>
        <div className="flex items-center text-sm text-gray-600">
          <Eye className="h-4 w-4 mr-1" />
          {streamKey.viewer_count || 0} viewers
        </div>
      </div>

      <div className="space-y-2">
        <button
          onClick={() => setShowDetails(!showDetails)}
          className="w-full text-left text-sm text-blue-600 hover:text-blue-700 font-medium"
        >
          {showDetails ? 'Hide' : 'Show'} stream details
        </button>

        {showDetails && (
          <div className="space-y-2 p-3 bg-gray-50 rounded-lg">
            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">Stream Key:</span>
              <div className="flex items-center">
                <code className="text-xs bg-white px-2 py-1 rounded border mr-2">
                  {streamKey.key}
                </code>
                <button
                  onClick={() => onCopy(streamKey.key)}
                  className="p-1 text-gray-400 hover:text-blue-600 transition-colors"
                >
                  <Copy className="h-3 w-3" />
                </button>
              </div>
            </div>
            
            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">RTMP URL:</span>
              <div className="flex items-center">
                <code className="text-xs bg-white px-2 py-1 rounded border mr-2 max-w-32 truncate">
                  rtmp://localhost:1935/live/{streamKey.key}
                </code>
                <button
                  onClick={() => onCopy(`rtmp://localhost:1935/live/${streamKey.key}`)}
                  className="p-1 text-gray-400 hover:text-blue-600 transition-colors"
                >
                  <Copy className="h-3 w-3" />
                </button>
              </div>
            </div>

            <div className="flex space-x-2 pt-2">
              <a
                href={`/stream/${streamKey.key}`}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center px-3 py-1 text-xs bg-blue-100 text-blue-700 rounded hover:bg-blue-200 transition-colors"
              >
                <ExternalLink className="h-3 w-3 mr-1" />
                View Stream
              </a>
            </div>
          </div>
        )}
      </div>

      <div className="mt-4 pt-4 border-t border-gray-200">
        <div className="flex items-center justify-between text-xs text-gray-500">
          <span>Created: {new Date(streamKey.created_at).toLocaleDateString()}</span>
          <span className={streamKey.is_active ? 'text-green-600' : 'text-red-600'}>
            {streamKey.is_active ? (
              <>
                <CheckCircle className="h-3 w-3 inline mr-1" />
                Active
              </>
            ) : (
              <>
                <XCircle className="h-3 w-3 inline mr-1" />
                Inactive
              </>
            )}
          </span>
        </div>
      </div>
    </div>
  );
};

const StreamModal = ({ streamKey, onSubmit, onClose, loading }) => {
  const {
    register,
    handleSubmit,
    formState: { errors },
    reset,
  } = useForm({
    defaultValues: streamKey ? {
      name: streamKey.name,
      description: streamKey.description,
      is_active: streamKey.is_active,
    } : {},
  });

  const handleFormSubmit = (data) => {
    onSubmit(data);
  };

  return (
    <div className="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 w-full max-w-md">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">
          {streamKey ? 'Edit Stream' : 'Create New Stream'}
        </h2>
        
        <form onSubmit={handleSubmit(handleFormSubmit)} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Stream Name
            </label>
            <input
              {...register('name', { required: 'Stream name is required' })}
              type="text"
              className="form-input"
              placeholder="Enter stream name"
            />
            {errors.name && (
              <p className="text-sm text-red-600 mt-1">{errors.name.message}</p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Description
            </label>
            <textarea
              {...register('description')}
              rows={3}
              className="form-input"
              placeholder="Enter stream description (optional)"
            />
          </div>

          {streamKey && (
            <div className="flex items-center">
              <input
                {...register('is_active')}
                type="checkbox"
                className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
              />
              <label className="ml-2 block text-sm text-gray-700">
                Active
              </label>
            </div>
          )}

          <div className="flex space-x-3 pt-4">
            <button
              type="button"
              onClick={onClose}
              className="flex-1 px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={loading}
              className="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors disabled:opacity-50"
            >
              {loading ? 'Saving...' : streamKey ? 'Update' : 'Create'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default StreamManager;
