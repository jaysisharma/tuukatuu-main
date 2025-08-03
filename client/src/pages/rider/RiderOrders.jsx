import React, { useState, useEffect } from 'react';
import { api } from '../../api';

export default function RiderOrders() {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('current');

  useEffect(() => {
    fetchOrders();
  }, []);

  const fetchOrders = async () => {
    try {
      // This would need to be implemented in the backend
      const response = await api.get('/riders/orders');
      setOrders(response.orders || []);
    } catch (error) {
      console.error('Error fetching orders:', error);
    } finally {
      setLoading(false);
    }
  };

  const updateOrderStatus = async (orderId, status) => {
    try {
      await api.put('/riders/orders/status', { orderId, status });
      alert(`Order status updated to ${status}!`);
      fetchOrders();
    } catch (error) {
      console.error('Error updating order status:', error);
      alert('Failed to update order status. Please try again.');
    }
  };

  const getStatusBadge = (status) => {
    const statusConfig = {
      picked_up: { color: 'bg-blue-100 text-blue-800', label: 'Picked Up' },
      on_the_way: { color: 'bg-yellow-100 text-yellow-800', label: 'On The Way' },
      delivered: { color: 'bg-green-100 text-green-800', label: 'Delivered' },
      cancelled: { color: 'bg-red-100 text-red-800', label: 'Cancelled' }
    };
    const config = statusConfig[status] || { color: 'bg-gray-100 text-gray-800', label: status };
    return <span className={`px-2 py-1 rounded-full text-xs font-medium ${config.color}`}>{config.label}</span>;
  };

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
      </div>
    );
  }

  const currentOrders = orders.filter(order => 
    ['picked_up', 'on_the_way'].includes(order.status)
  );
  const completedOrders = orders.filter(order => 
    ['delivered', 'cancelled'].includes(order.status)
  );

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Orders</h1>
        <p className="text-gray-600">Manage your current and completed orders</p>
      </div>

      {/* Tabs */}
      <div className="bg-white rounded-lg shadow">
        <div className="border-b border-gray-200">
          <nav className="-mb-px flex space-x-8 px-6">
            <button
              onClick={() => setActiveTab('current')}
              className={`py-4 px-1 border-b-2 font-medium text-sm ${
                activeTab === 'current'
                  ? 'border-primary text-primary'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              }`}
            >
              Current Orders ({currentOrders.length})
            </button>
            <button
              onClick={() => setActiveTab('completed')}
              className={`py-4 px-1 border-b-2 font-medium text-sm ${
                activeTab === 'completed'
                  ? 'border-primary text-primary'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              }`}
            >
              Completed Orders ({completedOrders.length})
            </button>
          </nav>
        </div>

        <div className="p-6">
          {activeTab === 'current' && (
            <div className="space-y-4">
              {currentOrders.length > 0 ? (
                currentOrders.map((order) => (
                  <div key={order._id} className="border border-gray-200 rounded-lg p-4">
                    <div className="flex justify-between items-start">
                      <div className="flex-1">
                        <div className="flex items-center justify-between mb-2">
                          <h3 className="text-lg font-medium text-gray-900">
                            Order #{order._id.slice(-6)}
                          </h3>
                          {getStatusBadge(order.status)}
                        </div>
                        
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                          <div>
                            <p className="text-sm font-medium text-gray-700">From</p>
                            <p className="text-sm text-gray-900">{order.vendorId?.storeName || 'Unknown Store'}</p>
                            <p className="text-sm text-gray-600">{order.pickupLocation?.address}</p>
                          </div>
                          <div>
                            <p className="text-sm font-medium text-gray-700">To</p>
                            <p className="text-sm text-gray-900">{order.customerId?.name || 'Customer'}</p>
                            <p className="text-sm text-gray-600">{order.deliveryLocation?.address}</p>
                          </div>
                        </div>

                        <div className="flex items-center justify-between text-sm text-gray-600">
                          <span>Delivery Fee: ₹{order.deliveryFee || 50}</span>
                          <span>Assigned: {formatDate(order.assignedAt || order.createdAt)}</span>
                        </div>
                      </div>

                      <div className="ml-4 flex flex-col space-y-2">
                        {order.status === 'picked_up' && (
                          <button
                            onClick={() => updateOrderStatus(order._id, 'on_the_way')}
                            className="px-3 py-1 bg-blue-600 text-white rounded text-sm hover:bg-blue-700"
                          >
                            Start Delivery
                          </button>
                        )}
                        {order.status === 'on_the_way' && (
                          <button
                            onClick={() => updateOrderStatus(order._id, 'delivered')}
                            className="px-3 py-1 bg-green-600 text-white rounded text-sm hover:bg-green-700"
                          >
                            Mark Delivered
                          </button>
                        )}
                      </div>
                    </div>
                  </div>
                ))
              ) : (
                <div className="text-center py-8">
                  <p className="text-gray-500">No current orders.</p>
                  <p className="text-sm text-gray-400 mt-2">Go online to receive new orders.</p>
                </div>
              )}
            </div>
          )}

          {activeTab === 'completed' && (
            <div className="space-y-4">
              {completedOrders.length > 0 ? (
                completedOrders.map((order) => (
                  <div key={order._id} className="border border-gray-200 rounded-lg p-4">
                    <div className="flex justify-between items-start">
                      <div className="flex-1">
                        <div className="flex items-center justify-between mb-2">
                          <h3 className="text-lg font-medium text-gray-900">
                            Order #{order._id.slice(-6)}
                          </h3>
                          {getStatusBadge(order.status)}
                        </div>
                        
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                          <div>
                            <p className="text-sm font-medium text-gray-700">From</p>
                            <p className="text-sm text-gray-900">{order.vendorId?.storeName || 'Unknown Store'}</p>
                            <p className="text-sm text-gray-600">{order.pickupLocation?.address}</p>
                          </div>
                          <div>
                            <p className="text-sm font-medium text-gray-700">To</p>
                            <p className="text-sm text-gray-900">{order.customerId?.name || 'Customer'}</p>
                            <p className="text-sm text-gray-600">{order.deliveryLocation?.address}</p>
                          </div>
                        </div>

                        <div className="flex items-center justify-between text-sm text-gray-600">
                          <span>Delivery Fee: ₹{order.deliveryFee || 50}</span>
                          <span>Completed: {formatDate(order.updatedAt)}</span>
                        </div>

                        {order.status === 'delivered' && order.rating && (
                          <div className="mt-2 flex items-center">
                            <span className="text-sm text-gray-700 mr-2">Rating:</span>
                            <div className="flex items-center">
                              {[...Array(5)].map((_, i) => (
                                <span key={i} className="text-yellow-400">
                                  {i < order.rating ? '★' : '☆'}
                                </span>
                              ))}
                              <span className="ml-1 text-sm text-gray-600">({order.rating}/5)</span>
                            </div>
                          </div>
                        )}
                      </div>
                    </div>
                  </div>
                ))
              ) : (
                <div className="text-center py-8">
                  <p className="text-gray-500">No completed orders yet.</p>
                  <p className="text-sm text-gray-400 mt-2">Complete your first delivery to see it here.</p>
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  );
} 