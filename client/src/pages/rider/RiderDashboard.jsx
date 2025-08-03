import React, { useState, useEffect } from 'react';
import { api } from '../../api';
import { useSelector } from 'react-redux';

export default function RiderDashboard() {
  const user = useSelector(state => state.auth.user);
  const [rider, setRider] = useState(null);
  const [availableOrders, setAvailableOrders] = useState([]);
  const [currentOrder, setCurrentOrder] = useState(null);
  const [loading, setLoading] = useState(true);
  const [earnings, setEarnings] = useState(null);
  const [performance, setPerformance] = useState(null);
  const [activeTab, setActiveTab] = useState('overview');

  useEffect(() => {
    fetchRiderData();
    fetchAvailableOrders();
    fetchEarnings();
    fetchPerformance();
  }, []);

  const fetchRiderData = async () => {
    try {
      const response = await api.get('/riders/profile');
      setRider(response.rider);
    } catch (error) {
      console.error('Error fetching rider data:', error);
    } finally {
      setLoading(false);
    }
  };

  const fetchAvailableOrders = async () => {
    try {
      const response = await api.get('/riders/orders/available');
      setAvailableOrders(response.orders || []);
    } catch (error) {
      console.error('Error fetching available orders:', error);
    }
  };

  const fetchEarnings = async () => {
    try {
      const response = await api.get('/riders/earnings');
      setEarnings(response.earnings);
    } catch (error) {
      console.error('Error fetching earnings:', error);
    }
  };

  const fetchPerformance = async () => {
    try {
      const response = await api.get('/riders/performance');
      setPerformance(response.performance);
    } catch (error) {
      console.error('Error fetching performance:', error);
    }
  };

  const updateStatus = async (newStatus) => {
    try {
      await api.put('/riders/status', { status: newStatus });
      fetchRiderData();
    } catch (error) {
      console.error('Error updating status:', error);
      alert('Failed to update status. Please try again.');
    }
  };

  const acceptOrder = async (orderId) => {
    try {
      await api.post('/riders/orders/accept', { orderId });
      alert('Order accepted successfully!');
      fetchAvailableOrders();
      fetchRiderData();
    } catch (error) {
      console.error('Error accepting order:', error);
      alert('Failed to accept order. Please try again.');
    }
  };

  const updateOrderStatus = async (orderId, status) => {
    try {
      await api.put('/riders/orders/status', { orderId, status });
      alert(`Order status updated to ${status}!`);
      fetchRiderData();
    } catch (error) {
      console.error('Error updating order status:', error);
      alert('Failed to update order status. Please try again.');
    }
  };

  const getStatusBadge = (status) => {
    const statusConfig = {
      online: { color: 'bg-green-100 text-green-800', label: 'Online' },
      offline: { color: 'bg-gray-100 text-gray-800', label: 'Offline' },
      busy: { color: 'bg-yellow-100 text-yellow-800', label: 'Busy' },
      on_delivery: { color: 'bg-blue-100 text-blue-800', label: 'On Delivery' }
    };
    const config = statusConfig[status] || { color: 'bg-gray-100 text-gray-800', label: status };
    return <span className={`px-3 py-1 rounded-full text-sm font-medium ${config.color}`}>{config.label}</span>;
  };

  const getVehicleIcon = (type) => {
    const icons = {
      bike: '🏍️',
      scooter: '🛵',
      car: '🚗',
      bicycle: '🚲'
    };
    return icons[type] || '🚗';
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
      </div>
    );
  }

  if (!rider) {
    return (
      <div className="text-center py-12">
        <h2 className="text-xl font-semibold text-gray-900">Rider profile not found</h2>
        <p className="text-gray-600 mt-2">Please contact support if this is an error.</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header with Status Control */}
      <div className="bg-white p-6 rounded-lg shadow">
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Welcome, {rider.profile.fullName}!</h1>
            <p className="text-gray-600">Manage your deliveries and earnings</p>
          </div>
          <div className="flex items-center space-x-4">
            <div className="text-right">
              <p className="text-sm text-gray-600">Current Status</p>
              {getStatusBadge(rider.status)}
            </div>
            <div className="flex space-x-2">
              <button
                onClick={() => updateStatus('online')}
                disabled={rider.status === 'online'}
                className={`px-4 py-2 rounded-lg font-medium transition ${
                  rider.status === 'online'
                    ? 'bg-green-100 text-green-800 cursor-not-allowed'
                    : 'bg-green-600 text-white hover:bg-green-700'
                }`}
              >
                Go Online
              </button>
              <button
                onClick={() => updateStatus('offline')}
                disabled={rider.status === 'offline'}
                className={`px-4 py-2 rounded-lg font-medium transition ${
                  rider.status === 'offline'
                    ? 'bg-gray-100 text-gray-800 cursor-not-allowed'
                    : 'bg-gray-600 text-white hover:bg-gray-700'
                }`}
              >
                Go Offline
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Quick Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-white p-6 rounded-lg shadow">
          <div className="flex items-center">
            <div className="p-2 bg-blue-100 rounded-lg">
              <span className="text-blue-600 text-xl">⭐</span>
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Rating</p>
              <p className="text-2xl font-bold text-gray-900">{(rider.performance.averageRating || 0).toFixed(1)}</p>
            </div>
          </div>
        </div>
        <div className="bg-white p-6 rounded-lg shadow">
          <div className="flex items-center">
            <div className="p-2 bg-green-100 rounded-lg">
              <span className="text-green-600 text-xl">📦</span>
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Deliveries</p>
              <p className="text-2xl font-bold text-gray-900">{rider.performance.completedDeliveries || 0}</p>
            </div>
          </div>
        </div>
        <div className="bg-white p-6 rounded-lg shadow">
          <div className="flex items-center">
            <div className="p-2 bg-yellow-100 rounded-lg">
              <span className="text-yellow-600 text-xl">💰</span>
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Today's Earnings</p>
              <p className="text-2xl font-bold text-gray-900">₹{(earnings?.today?.total || 0).toLocaleString()}</p>
            </div>
          </div>
        </div>
        <div className="bg-white p-6 rounded-lg shadow">
          <div className="flex items-center">
            <div className="p-2 bg-purple-100 rounded-lg">
              <span className="text-purple-600 text-xl">⏱️</span>
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">On-Time Rate</p>
              <p className="text-2xl font-bold text-gray-900">
                {rider.performance.completedDeliveries > 0
                  ? Math.round(((rider.performance.onTimeDeliveries || 0) / rider.performance.completedDeliveries) * 100)
                  : 0}%
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Current Assignment */}
      {rider.currentAssignment?.orderId && (
        <div className="bg-white p-6 rounded-lg shadow">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Current Assignment</h2>
          <div className="bg-blue-50 p-4 rounded-lg">
            <div className="flex justify-between items-start">
              <div>
                <p className="font-medium text-gray-900">Order #{rider.currentAssignment.orderId}</p>
                <p className="text-sm text-gray-600">
                  Pickup: {rider.currentAssignment.pickupLocation?.address}
                </p>
                <p className="text-sm text-gray-600">
                  Delivery: {rider.currentAssignment.deliveryLocation?.address}
                </p>
              </div>
              <div className="flex space-x-2">
                <button
                  onClick={() => updateOrderStatus(rider.currentAssignment.orderId, 'on_the_way')}
                  className="px-3 py-1 bg-blue-600 text-white rounded text-sm hover:bg-blue-700"
                >
                  Start Delivery
                </button>
                <button
                  onClick={() => updateOrderStatus(rider.currentAssignment.orderId, 'delivered')}
                  className="px-3 py-1 bg-green-600 text-white rounded text-sm hover:bg-green-700"
                >
                  Mark Delivered
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Tabs */}
      <div className="bg-white rounded-lg shadow">
        <div className="border-b border-gray-200">
          <nav className="-mb-px flex space-x-8 px-6">
            {['overview', 'orders', 'earnings', 'performance'].map((tab) => (
              <button
                key={tab}
                onClick={() => setActiveTab(tab)}
                className={`py-4 px-1 border-b-2 font-medium text-sm capitalize ${
                  activeTab === tab
                    ? 'border-primary text-primary'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                {tab}
              </button>
            ))}
          </nav>
        </div>

        <div className="p-6">
          {activeTab === 'overview' && (
            <div className="space-y-6">
              {/* Profile Information */}
              <div>
                <h3 className="text-lg font-medium text-gray-900 mb-4">Profile Information</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Full Name</label>
                    <p className="mt-1 text-sm text-gray-900">{rider.profile.fullName}</p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Phone</label>
                    <p className="mt-1 text-sm text-gray-900">{rider.profile.phone}</p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Email</label>
                    <p className="mt-1 text-sm text-gray-900">{rider.profile.email}</p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Status</label>
                    <div className="mt-1">{getStatusBadge(rider.status)}</div>
                  </div>
                </div>
              </div>

              {/* Vehicle Information */}
              <div>
                <h3 className="text-lg font-medium text-gray-900 mb-4">Vehicle Information</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Vehicle Type</label>
                    <div className="mt-1 flex items-center">
                      <span className="text-lg mr-2">{getVehicleIcon(rider.vehicle.type)}</span>
                      <span className="text-sm text-gray-900 capitalize">{rider.vehicle.type}</span>
                    </div>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Brand & Model</label>
                    <p className="mt-1 text-sm text-gray-900">
                      {rider.vehicle.brand} {rider.vehicle.model}
                    </p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">License Plate</label>
                    <p className="mt-1 text-sm text-gray-900">{rider.vehicle.licensePlate}</p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Color</label>
                    <p className="mt-1 text-sm text-gray-900 capitalize">{rider.vehicle.color}</p>
                  </div>
                </div>
              </div>

              {/* Work Preferences */}
              <div>
                <h3 className="text-lg font-medium text-gray-900 mb-4">Work Preferences</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Availability</label>
                    <p className="mt-1 text-sm text-gray-900">
                      {rider.workPreferences.isAvailable ? 'Available' : 'Not Available'}
                    </p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Working Hours</label>
                    <p className="mt-1 text-sm text-gray-900">
                      {rider.workPreferences.workingHours?.start} - {rider.workPreferences.workingHours?.end}
                    </p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Max Distance</label>
                    <p className="mt-1 text-sm text-gray-900">{rider.workPreferences.maxDistance} km</p>
                  </div>
                  {rider.workPreferences.preferredAreas?.length > 0 && (
                    <div>
                      <label className="block text-sm font-medium text-gray-700">Preferred Areas</label>
                      <p className="mt-1 text-sm text-gray-900">
                        {rider.workPreferences.preferredAreas.join(', ')}
                      </p>
                    </div>
                  )}
                </div>
              </div>
            </div>
          )}

          {activeTab === 'orders' && (
            <div className="space-y-4">
              <div className="flex justify-between items-center">
                <h3 className="text-lg font-medium text-gray-900">Available Orders</h3>
                <button
                  onClick={fetchAvailableOrders}
                  className="px-3 py-1 bg-primary text-white rounded text-sm hover:bg-primary-dark"
                >
                  Refresh
                </button>
              </div>
              
              {availableOrders.length > 0 ? (
                <div className="space-y-4">
                  {availableOrders.map((order) => (
                    <div key={order._id} className="border border-gray-200 rounded-lg p-4">
                      <div className="flex justify-between items-start">
                        <div>
                          <p className="font-medium text-gray-900">Order #{order._id.slice(-6)}</p>
                          <p className="text-sm text-gray-600">
                            From: {order.vendorId?.storeName || 'Unknown Store'}
                          </p>
                          <p className="text-sm text-gray-600">
                            To: {order.customerId?.name || 'Customer'}
                          </p>
                          <p className="text-sm text-gray-600">
                            Pickup: {order.pickupLocation?.address}
                          </p>
                          <p className="text-sm text-gray-600">
                            Delivery: {order.deliveryLocation?.address}
                          </p>
                          <p className="text-sm font-medium text-green-600">
                            Delivery Fee: ₹{order.deliveryFee || 50}
                          </p>
                        </div>
                        <button
                          onClick={() => acceptOrder(order._id)}
                          disabled={rider.status !== 'online'}
                          className={`px-4 py-2 rounded-lg font-medium transition ${
                            rider.status === 'online'
                              ? 'bg-primary text-white hover:bg-primary-dark'
                              : 'bg-gray-300 text-gray-500 cursor-not-allowed'
                          }`}
                        >
                          Accept Order
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="text-center py-8">
                  <p className="text-gray-500">No available orders at the moment.</p>
                  <p className="text-sm text-gray-400 mt-2">Make sure you're online to receive orders.</p>
                </div>
              )}
            </div>
          )}

          {activeTab === 'earnings' && earnings && (
            <div className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div className="bg-gray-50 p-4 rounded-lg">
                  <h4 className="font-medium text-gray-900">Today's Earnings</h4>
                  <p className="text-2xl font-bold text-primary">₹{(earnings.today?.total || 0).toLocaleString()}</p>
                  <p className="text-sm text-gray-600">{earnings.today?.orders || 0} orders</p>
                </div>
                <div className="bg-gray-50 p-4 rounded-lg">
                  <h4 className="font-medium text-gray-900">This Week</h4>
                  <p className="text-2xl font-bold text-primary">₹{(earnings.week?.total || 0).toLocaleString()}</p>
                  <p className="text-sm text-gray-600">{earnings.week?.orders || 0} orders</p>
                </div>
                <div className="bg-gray-50 p-4 rounded-lg">
                  <h4 className="font-medium text-gray-900">This Month</h4>
                  <p className="text-2xl font-bold text-primary">₹{(earnings.month?.total || 0).toLocaleString()}</p>
                  <p className="text-sm text-gray-600">{earnings.month?.orders || 0} orders</p>
                </div>
              </div>

              <div className="bg-gray-50 p-4 rounded-lg">
                <h4 className="font-medium text-gray-900 mb-4">Total Earnings</h4>
                <p className="text-3xl font-bold text-primary">₹{(rider.earnings.totalEarnings || 0).toLocaleString()}</p>
                <p className="text-sm text-gray-600 mt-2">Lifetime earnings from all deliveries</p>
              </div>
            </div>
          )}

          {activeTab === 'performance' && performance && (
            <div className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div className="bg-gray-50 p-4 rounded-lg">
                  <h4 className="font-medium text-gray-900">Total Deliveries</h4>
                  <p className="text-2xl font-bold text-primary">{performance.totalDeliveries || 0}</p>
                </div>
                <div className="bg-gray-50 p-4 rounded-lg">
                  <h4 className="font-medium text-gray-900">Completion Rate</h4>
                  <p className="text-2xl font-bold text-primary">{performance.completionRate || 0}%</p>
                </div>
                <div className="bg-gray-50 p-4 rounded-lg">
                  <h4 className="font-medium text-gray-900">Average Rating</h4>
                  <p className="text-2xl font-bold text-primary">{performance.averageRating || 0}</p>
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="bg-gray-50 p-4 rounded-lg">
                  <h4 className="font-medium text-gray-900">On-Time Deliveries</h4>
                  <p className="text-2xl font-bold text-primary">{performance.onTimeDeliveries || 0}</p>
                  <p className="text-sm text-gray-600">Out of {performance.completedDeliveries || 0} completed</p>
                </div>
                <div className="bg-gray-50 p-4 rounded-lg">
                  <h4 className="font-medium text-gray-900">On-Time Rate</h4>
                  <p className="text-2xl font-bold text-primary">{performance.onTimeRate || 0}%</p>
                  <p className="text-sm text-gray-600">Percentage of on-time deliveries</p>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
} 