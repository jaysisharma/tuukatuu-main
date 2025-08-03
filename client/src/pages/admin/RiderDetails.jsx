import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { api } from '../../api';

export default function RiderDetails() {
  const { riderId } = useParams();
  const navigate = useNavigate();
  const [rider, setRider] = useState(null);
  const [performance, setPerformance] = useState(null);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('overview');
  const [showEditModal, setShowEditModal] = useState(false);

  useEffect(() => {
    fetchRiderDetails();
    fetchRiderPerformance();
  }, [riderId]);

  const fetchRiderDetails = async () => {
    try {
      const response = await api.get(`/admin/riders/${riderId}`);
      setRider(response.rider);
    } catch (error) {
      console.error('Error fetching rider details:', error);
    } finally {
      setLoading(false);
    }
  };

  const fetchRiderPerformance = async () => {
    try {
      const response = await api.get(`/admin/riders/${riderId}/performance`);
      setPerformance(response.performance);
    } catch (error) {
      console.error('Error fetching rider performance:', error);
    }
  };

  const handleApprove = async (isApproved) => {
    try {
      await api.patch(`/admin/riders/${riderId}/approve`, { isApproved });
      fetchRiderDetails();
    } catch (error) {
      console.error('Error approving rider:', error);
    }
  };

  const handleBlock = async (isBlocked) => {
    try {
      await api.patch(`/admin/riders/${riderId}/block`, { isBlocked });
      fetchRiderDetails();
    } catch (error) {
      console.error('Error blocking rider:', error);
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
        <h2 className="text-xl font-semibold text-gray-900">Rider not found</h2>
        <button
          onClick={() => navigate('/admin/riders')}
          className="mt-4 text-primary hover:text-primary-dark"
        >
          ← Back to Riders
        </button>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-start">
        <div>
          <div className="flex items-center space-x-3">
            <button
              onClick={() => navigate('/admin/riders')}
              className="text-gray-500 hover:text-gray-700"
            >
              ← Back
            </button>
            <h1 className="text-2xl font-bold text-gray-900">Rider Details</h1>
          </div>
          <p className="text-gray-600 mt-1">{rider.profile.fullName}</p>
        </div>
        <div className="flex space-x-3">
          {!rider.verification.isApproved && (
            <button
              onClick={() => handleApprove(true)}
              className="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 transition"
            >
              Approve Rider
            </button>
          )}
          <button
            onClick={() => handleBlock(rider.status !== 'offline')}
            className={`px-4 py-2 rounded-lg transition ${
              rider.status === 'offline'
                ? 'bg-green-600 text-white hover:bg-green-700'
                : 'bg-red-600 text-white hover:bg-red-700'
            }`}
          >
            {rider.status === 'offline' ? 'Unblock' : 'Block'}
          </button>
          <button
            onClick={() => setShowEditModal(true)}
            className="bg-primary text-white px-4 py-2 rounded-lg hover:bg-primary-dark transition"
          >
            Edit Rider
          </button>
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
              <p className="text-sm font-medium text-gray-600">Earnings</p>
              <p className="text-2xl font-bold text-gray-900">₹{(rider.earnings.totalEarnings || 0).toLocaleString()}</p>
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

      {/* Tabs */}
      <div className="bg-white rounded-lg shadow">
        <div className="border-b border-gray-200">
          <nav className="-mb-px flex space-x-8 px-6">
            {['overview', 'performance', 'documents', 'earnings'].map((tab) => (
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
              {/* Basic Information */}
              <div>
                <h3 className="text-lg font-medium text-gray-900 mb-4">Basic Information</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Full Name</label>
                    <p className="mt-1 text-sm text-gray-900">{rider.profile.fullName}</p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Email</label>
                    <p className="mt-1 text-sm text-gray-900">{rider.profile.email}</p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Phone</label>
                    <p className="mt-1 text-sm text-gray-900">{rider.profile.phone}</p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Status</label>
                    <div className="mt-1">{getStatusBadge(rider.status)}</div>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Approval Status</label>
                    <div className="mt-1">
                      {rider.verification.isApproved ? (
                        <span className="px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">
                          Approved
                        </span>
                      ) : (
                        <span className="px-2 py-1 rounded-full text-xs font-medium bg-red-100 text-red-800">
                          Pending Approval
                        </span>
                      )}
                    </div>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Joined Date</label>
                    <p className="mt-1 text-sm text-gray-900">
                      {new Date(rider.createdAt).toLocaleDateString()}
                    </p>
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
                    <label className="block text-sm font-medium text-gray-700">Year</label>
                    <p className="mt-1 text-sm text-gray-900">{rider.vehicle.year}</p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Color</label>
                    <p className="mt-1 text-sm text-gray-900 capitalize">{rider.vehicle.color}</p>
                  </div>
                  {rider.vehicle.licensePlate && (
                    <div>
                      <label className="block text-sm font-medium text-gray-700">License Plate</label>
                      <p className="mt-1 text-sm text-gray-900">{rider.vehicle.licensePlate}</p>
                    </div>
                  )}
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

          {activeTab === 'performance' && performance && (
            <div className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div className="bg-gray-50 p-4 rounded-lg">
                  <h4 className="font-medium text-gray-900">Total Orders</h4>
                  <p className="text-2xl font-bold text-primary">{performance.totalOrders || 0}</p>
                </div>
                <div className="bg-gray-50 p-4 rounded-lg">
                  <h4 className="font-medium text-gray-900">Total Earnings</h4>
                  <p className="text-2xl font-bold text-primary">₹{(performance.totalEarnings || 0).toLocaleString()}</p>
                </div>
                <div className="bg-gray-50 p-4 rounded-lg">
                  <h4 className="font-medium text-gray-900">Average Order Value</h4>
                  <p className="text-2xl font-bold text-primary">₹{(performance.avgOrderValue || 0).toFixed(0)}</p>
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div className="bg-gray-50 p-4 rounded-lg">
                  <h4 className="font-medium text-gray-900">Completion Rate</h4>
                  <p className="text-2xl font-bold text-primary">{performance.completionRate || 0}%</p>
                </div>
                <div className="bg-gray-50 p-4 rounded-lg">
                  <h4 className="font-medium text-gray-900">Average Rating</h4>
                  <p className="text-2xl font-bold text-primary">{performance.averageRating || 0}</p>
                </div>
                <div className="bg-gray-50 p-4 rounded-lg">
                  <h4 className="font-medium text-gray-900">On-Time Rate</h4>
                  <p className="text-2xl font-bold text-primary">{performance.onTimeRate || 0}%</p>
                </div>
              </div>

              {performance.dailyStats?.length > 0 && (
                <div>
                  <h4 className="font-medium text-gray-900 mb-4">Daily Performance</h4>
                  <div className="overflow-x-auto">
                    <table className="min-w-full divide-y divide-gray-200">
                      <thead className="bg-gray-50">
                        <tr>
                          <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Date</th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Orders</th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Earnings</th>
                        </tr>
                      </thead>
                      <tbody className="bg-white divide-y divide-gray-200">
                        {performance.dailyStats.map((stat, index) => (
                          <tr key={index}>
                            <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{stat.date}</td>
                            <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{stat.orders}</td>
                            <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">₹{stat.earnings}</td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}
            </div>
          )}

          {activeTab === 'documents' && (
            <div className="space-y-6">
              <div>
                <h3 className="text-lg font-medium text-gray-900 mb-4">Driving License</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <label className="block text-sm font-medium text-gray-700">License Number</label>
                    <p className="mt-1 text-sm text-gray-900">{rider.documents.drivingLicense.number}</p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Expiry Date</label>
                    <p className="mt-1 text-sm text-gray-900">
                      {new Date(rider.documents.drivingLicense.expiryDate).toLocaleDateString()}
                    </p>
                  </div>
                </div>
              </div>

              {rider.documents.vehicleRegistration && (
                <div>
                  <h3 className="text-lg font-medium text-gray-900 mb-4">Vehicle Registration</h3>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                      <label className="block text-sm font-medium text-gray-700">Registration Number</label>
                      <p className="mt-1 text-sm text-gray-900">{rider.documents.vehicleRegistration.number}</p>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700">Expiry Date</label>
                      <p className="mt-1 text-sm text-gray-900">
                        {new Date(rider.documents.vehicleRegistration.expiryDate).toLocaleDateString()}
                      </p>
                    </div>
                  </div>
                </div>
              )}

              {rider.documents.insurance && (
                <div>
                  <h3 className="text-lg font-medium text-gray-900 mb-4">Insurance</h3>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                      <label className="block text-sm font-medium text-gray-700">Insurance Number</label>
                      <p className="mt-1 text-sm text-gray-900">{rider.documents.insurance.number}</p>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700">Expiry Date</label>
                      <p className="mt-1 text-sm text-gray-900">
                        {new Date(rider.documents.insurance.expiryDate).toLocaleDateString()}
                      </p>
                    </div>
                  </div>
                </div>
              )}
            </div>
          )}

          {activeTab === 'earnings' && (
            <div className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div className="bg-gray-50 p-4 rounded-lg">
                  <h4 className="font-medium text-gray-900">Total Earnings</h4>
                  <p className="text-2xl font-bold text-primary">₹{(rider.earnings.totalEarnings || 0).toLocaleString()}</p>
                </div>
                <div className="bg-gray-50 p-4 rounded-lg">
                  <h4 className="font-medium text-gray-900">Weekly Earnings</h4>
                  <p className="text-2xl font-bold text-primary">₹{(rider.earnings.thisWeek || 0).toLocaleString()}</p>
                </div>
                <div className="bg-gray-50 p-4 rounded-lg">
                  <h4 className="font-medium text-gray-900">Monthly Earnings</h4>
                  <p className="text-2xl font-bold text-primary">₹{(rider.earnings.thisMonth || 0).toLocaleString()}</p>
                </div>
              </div>

              {rider.bankDetails && (
                <div>
                  <h3 className="text-lg font-medium text-gray-900 mb-4">Bank Details</h3>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                      <label className="block text-sm font-medium text-gray-700">Account Holder</label>
                      <p className="mt-1 text-sm text-gray-900">{rider.bankDetails.accountHolderName}</p>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700">Bank Name</label>
                      <p className="mt-1 text-sm text-gray-900">{rider.bankDetails.bankName}</p>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700">Account Number</label>
                      <p className="mt-1 text-sm text-gray-900">{rider.bankDetails.accountNumber}</p>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700">IFSC Code</label>
                      <p className="mt-1 text-sm text-gray-900">{rider.bankDetails.ifscCode}</p>
                    </div>
                  </div>
                </div>
              )}
            </div>
          )}
        </div>
      </div>

      {/* Edit Modal */}
      {showEditModal && (
        <EditRiderModal
          rider={rider}
          onClose={() => setShowEditModal(false)}
          onSuccess={() => {
            setShowEditModal(false);
            fetchRiderDetails();
          }}
        />
      )}
    </div>
  );
}

// Edit Rider Modal Component
function EditRiderModal({ rider, onClose, onSuccess }) {
  const [formData, setFormData] = useState({
    profile: { ...rider.profile },
    vehicle: { ...rider.vehicle },
    documents: { ...rider.documents },
    workPreferences: { ...rider.workPreferences }
  });
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);

    try {
      await api.put(`/admin/riders/${rider._id}`, formData);
      onSuccess();
    } catch (error) {
      console.error('Error updating rider:', error);
      alert('Error updating rider. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (path, value) => {
    const keys = path.split('.');
    setFormData(prev => {
      const newData = { ...prev };
      let current = newData;
      for (let i = 0; i < keys.length - 1; i++) {
        current = current[keys[i]];
      }
      current[keys[keys.length - 1]] = value;
      return newData;
    });
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-xl font-bold">Edit Rider</h2>
          <button onClick={onClose} className="text-gray-500 hover:text-gray-700">
            ✕
          </button>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Basic Information */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Full Name</label>
              <input
                type="text"
                required
                value={formData.profile.fullName}
                onChange={(e) => handleChange('profile.fullName', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Phone</label>
              <input
                type="tel"
                required
                value={formData.profile.phone}
                onChange={(e) => handleChange('profile.phone', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
              />
            </div>
          </div>

          {/* Vehicle Information */}
          <div className="border-t pt-6">
            <h3 className="text-lg font-medium mb-4">Vehicle Information</h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Vehicle Type</label>
                <select
                  value={formData.vehicle.type}
                  onChange={(e) => handleChange('vehicle.type', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
                >
                  <option value="bike">Bike</option>
                  <option value="scooter">Scooter</option>
                  <option value="car">Car</option>
                  <option value="bicycle">Bicycle</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Brand</label>
                <input
                  type="text"
                  value={formData.vehicle.brand}
                  onChange={(e) => handleChange('vehicle.brand', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Model</label>
                <input
                  type="text"
                  value={formData.vehicle.model}
                  onChange={(e) => handleChange('vehicle.model', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
                />
              </div>
            </div>
          </div>

          {/* Work Preferences */}
          <div className="border-t pt-6">
            <h3 className="text-lg font-medium mb-4">Work Preferences</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Max Distance (km)</label>
                <input
                  type="number"
                  value={formData.workPreferences.maxDistance}
                  onChange={(e) => handleChange('workPreferences.maxDistance', parseInt(e.target.value))}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Working Hours Start</label>
                <input
                  type="time"
                  value={formData.workPreferences.workingHours?.start}
                  onChange={(e) => handleChange('workPreferences.workingHours.start', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
                />
              </div>
            </div>
          </div>

          {/* Actions */}
          <div className="flex justify-end space-x-3 pt-6 border-t">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={loading}
              className="px-4 py-2 bg-primary text-white rounded-md hover:bg-primary-dark disabled:opacity-50"
            >
              {loading ? 'Updating...' : 'Update Rider'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
} 