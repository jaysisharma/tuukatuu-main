import React, { useState, useEffect } from 'react';
import { api } from '../../api';

export default function RiderAnalytics() {
  const [analytics, setAnalytics] = useState(null);
  const [loading, setLoading] = useState(true);
  const [period, setPeriod] = useState('month');

  useEffect(() => {
    fetchAnalytics();
  }, [period]);

  const fetchAnalytics = async () => {
    try {
      setLoading(true);
      const response = await api.get(`/admin/riders/analytics?period=${period}`);
      setAnalytics(response.data.analytics);
    } catch (error) {
      console.error('Error fetching rider analytics:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
      </div>
    );
  }

  if (!analytics) {
    return (
      <div className="text-center py-12">
        <h2 className="text-xl font-semibold text-gray-900">No analytics data available</h2>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Rider Analytics</h1>
          <p className="text-gray-600">Comprehensive insights into rider performance and statistics</p>
        </div>
        <select
          value={period}
          onChange={(e) => setPeriod(e.target.value)}
          className="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
        >
          <option value="week">Last Week</option>
          <option value="month">Last Month</option>
          <option value="year">Last Year</option>
        </select>
      </div>

      {/* Overview Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-white p-6 rounded-lg shadow">
          <div className="flex items-center">
            <div className="p-2 bg-blue-100 rounded-lg">
              <span className="text-blue-600 text-xl">👥</span>
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Total Riders</p>
              <p className="text-2xl font-bold text-gray-900">{analytics.overview.totalRiders}</p>
            </div>
          </div>
        </div>
        <div className="bg-white p-6 rounded-lg shadow">
          <div className="flex items-center">
            <div className="p-2 bg-green-100 rounded-lg">
              <span className="text-green-600 text-xl">✅</span>
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Approved Riders</p>
              <p className="text-2xl font-bold text-gray-900">{analytics.overview.approvedRiders}</p>
            </div>
          </div>
        </div>
        <div className="bg-white p-6 rounded-lg shadow">
          <div className="flex items-center">
            <div className="p-2 bg-yellow-100 rounded-lg">
              <span className="text-yellow-600 text-xl">🟢</span>
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Online Riders</p>
              <p className="text-2xl font-bold text-gray-900">{analytics.overview.onlineRiders}</p>
            </div>
          </div>
        </div>
        <div className="bg-white p-6 rounded-lg shadow">
          <div className="flex items-center">
            <div className="p-2 bg-purple-100 rounded-lg">
              <span className="text-purple-600 text-xl">📈</span>
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">New Riders</p>
              <p className="text-2xl font-bold text-gray-900">{analytics.overview.newRiders}</p>
            </div>
          </div>
        </div>
      </div>

      {/* Performance Metrics */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-medium text-gray-900 mb-4">Performance Overview</h3>
          <div className="space-y-4">
            <div className="flex justify-between items-center">
              <span className="text-sm text-gray-600">Average Rating</span>
              <span className="text-sm font-medium text-gray-900">
                ⭐ {analytics.performance.avgRating.toFixed(1)}
              </span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-sm text-gray-600">Completion Rate</span>
              <span className="text-sm font-medium text-gray-900">
                {(analytics.performance.avgCompletionRate * 100).toFixed(1)}%
              </span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-sm text-gray-600">Total Deliveries</span>
              <span className="text-sm font-medium text-gray-900">
                {analytics.performance.totalDeliveries.toLocaleString()}
              </span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-sm text-gray-600">Total Earnings</span>
              <span className="text-sm font-medium text-gray-900">
                ₹{analytics.performance.totalEarnings.toLocaleString()}
              </span>
            </div>
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-medium text-gray-900 mb-4">Approval Rate</h3>
          <div className="flex items-center justify-center h-32">
            <div className="text-center">
              <div className="text-3xl font-bold text-primary">{analytics.overview.approvalRate}%</div>
              <div className="text-sm text-gray-600">Approval Rate</div>
            </div>
          </div>
        </div>
      </div>

      {/* Status Distribution */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-medium text-gray-900 mb-4">Status Distribution</h3>
          <div className="space-y-3">
            {analytics.statusDistribution.map((status) => (
              <div key={status._id} className="flex justify-between items-center">
                <div className="flex items-center">
                  <div className={`w-3 h-3 rounded-full mr-2 ${
                    status._id === 'online' ? 'bg-green-500' :
                    status._id === 'offline' ? 'bg-gray-500' :
                    status._id === 'busy' ? 'bg-yellow-500' :
                    status._id === 'on_delivery' ? 'bg-blue-500' : 'bg-gray-500'
                  }`}></div>
                  <span className="text-sm text-gray-600 capitalize">
                    {status._id.replace('_', ' ')}
                  </span>
                </div>
                <span className="text-sm font-medium text-gray-900">{status.count}</span>
              </div>
            ))}
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-medium text-gray-900 mb-4">Vehicle Distribution</h3>
          <div className="space-y-3">
            {analytics.vehicleDistribution.map((vehicle) => (
              <div key={vehicle._id} className="flex justify-between items-center">
                <div className="flex items-center">
                  <span className="text-lg mr-2">
                    {vehicle._id === 'bike' ? '🏍️' :
                     vehicle._id === 'scooter' ? '🛵' :
                     vehicle._id === 'car' ? '🚗' :
                     vehicle._id === 'bicycle' ? '🚲' : '🚗'}
                  </span>
                  <span className="text-sm text-gray-600 capitalize">{vehicle._id}</span>
                </div>
                <span className="text-sm font-medium text-gray-900">{vehicle.count}</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Top Performing Riders */}
      <div className="bg-white rounded-lg shadow">
        <div className="px-6 py-4 border-b border-gray-200">
          <h3 className="text-lg font-medium text-gray-900">Top Performing Riders</h3>
        </div>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Rider</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Rating</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Deliveries</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Earnings</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {analytics.topRiders.map((rider) => (
                <tr key={rider._id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="flex-shrink-0 h-10 w-10">
                        <div className="h-10 w-10 rounded-full bg-gray-300 flex items-center justify-center">
                          <span className="text-sm font-medium text-gray-700">
                            {rider.userId?.name?.charAt(0).toUpperCase() || 'R'}
                          </span>
                        </div>
                      </div>
                      <div className="ml-4">
                        <div className="text-sm font-medium text-gray-900">{rider.userId?.name || 'Unknown'}</div>
                        <div className="text-sm text-gray-500">{rider.userId?.email || 'No email'}</div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">
                      ⭐ {rider.performance.averageRating.toFixed(1)}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">{rider.performance.completedDeliveries}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">₹{rider.earnings.totalEarnings.toLocaleString()}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                      rider.status === 'online' ? 'bg-green-100 text-green-800' :
                      rider.status === 'offline' ? 'bg-gray-100 text-gray-800' :
                      rider.status === 'busy' ? 'bg-yellow-100 text-yellow-800' :
                      rider.status === 'on_delivery' ? 'bg-blue-100 text-blue-800' :
                      'bg-gray-100 text-gray-800'
                    }`}>
                      {rider.status.replace('_', ' ')}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Insights */}
      <div className="bg-white p-6 rounded-lg shadow">
        <h3 className="text-lg font-medium text-gray-900 mb-4">Key Insights</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="space-y-3">
            <div className="flex items-start">
              <div className="flex-shrink-0">
                <div className="w-2 h-2 bg-green-500 rounded-full mt-2"></div>
              </div>
              <div className="ml-3">
                <p className="text-sm text-gray-900">
                  <strong>High Performance:</strong> {analytics.overview.approvedRiders} out of {analytics.overview.totalRiders} riders are approved and active.
                </p>
              </div>
            </div>
            <div className="flex items-start">
              <div className="flex-shrink-0">
                <div className="w-2 h-2 bg-blue-500 rounded-full mt-2"></div>
              </div>
              <div className="ml-3">
                <p className="text-sm text-gray-900">
                  <strong>Good Coverage:</strong> {analytics.overview.onlineRiders} riders are currently online and available for deliveries.
                </p>
              </div>
            </div>
          </div>
          <div className="space-y-3">
            <div className="flex items-start">
              <div className="flex-shrink-0">
                <div className="w-2 h-2 bg-yellow-500 rounded-full mt-2"></div>
              </div>
              <div className="ml-3">
                <p className="text-sm text-gray-900">
                  <strong>Quality Service:</strong> Average rider rating of {analytics.performance.avgRating.toFixed(1)} stars indicates good customer satisfaction.
                </p>
              </div>
            </div>
            <div className="flex items-start">
              <div className="flex-shrink-0">
                <div className="w-2 h-2 bg-purple-500 rounded-full mt-2"></div>
              </div>
              <div className="ml-3">
                <p className="text-sm text-gray-900">
                  <strong>Growth:</strong> {analytics.overview.newRiders} new riders joined in the last {period}.
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
} 