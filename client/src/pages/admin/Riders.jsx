import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { api } from '../../api'; // Assuming 'api' is configured correctly for API calls
import PropTypes from 'prop-types'; // Import PropTypes for prop validation

export default function Riders() {
  const [riders, setRiders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [approvalFilter, setApprovalFilter] = useState('');
  const [pagination, setPagination] = useState({ page: 1, limit: 10, total: 0, pages: 1 });
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [selectedRider, setSelectedRider] = useState(null); // For potential future view/edit modal

  useEffect(() => {
    fetchRiders();
  }, [pagination.page, search, statusFilter, approvalFilter]);

  const fetchRiders = async () => {
    try {
      setLoading(true);
      const params = new URLSearchParams({
        page: pagination.page,
        limit: pagination.limit,
        ...(search && { search }),
        ...(statusFilter && { status: statusFilter }),
        // Ensure approvalFilter sends 'true' or 'false' strings
        ...(approvalFilter !== '' && { isApproved: approvalFilter })
      });

      const response = await api.get(`/admin/riders?${params}`);
      setRiders(response.riders);
      setPagination(prev => ({ ...prev, ...response.pagination }));
    } catch (error) {
      console.error('Error fetching riders:', error);
      // Optionally display a user-friendly error message
      alert('Failed to load riders. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleApprove = async (riderId, isApproved) => {
    if (!window.confirm(`Are you sure you want to ${isApproved ? 'approve' : 'unapprove'} this rider?`)) return;

    try {
      await api.patch(`/admin/riders/${riderId}/approve`, { isApproved });
      fetchRiders();
      alert(`Rider ${isApproved ? 'approved' : 'unapproved'} successfully!`);
    } catch (error) {
      console.error('Error approving rider:', error);
      alert('Failed to update rider approval status. Please try again.');
    }
  };

  const handleBlock = async (riderId, currentRiderStatus) => {
    const shouldBlock = currentRiderStatus !== 'offline'; // If current is not offline, we want to block (true)
    const actionText = shouldBlock ? 'block' : 'unblock';

    if (!window.confirm(`Are you sure you want to ${actionText} this rider?`)) return;

    try {
      await api.patch(`/admin/riders/${riderId}/block`, { isBlocked: shouldBlock });
      fetchRiders();
      alert(`Rider ${actionText}ed successfully!`);
    } catch (error) {
      console.error('Error blocking rider:', error);
      alert('Failed to update rider block status. Please try again.');
    }
  };

  const handleDelete = async (riderId) => {
    if (!window.confirm('Are you sure you want to delete this rider? This action cannot be undone.')) return;
    
    try {
      await api.delete(`/admin/riders/${riderId}`);
      fetchRiders();
      alert('Rider deleted successfully!');
    } catch (error) {
      console.error('Error deleting rider:', error);
      // More specific error message if backend provides it
      const errorMessage = error.response?.data?.message || 'Failed to delete rider. Please try again.';
      alert(errorMessage);
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
    return <span className={`px-2 py-1 rounded-full text-xs font-medium ${config.color}`}>{config.label}</span>;
  };

  const getApprovalBadge = (isApproved) => {
    return isApproved ? 
      <span className="px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">Approved</span> :
      <span className="px-2 py-1 rounded-full text-xs font-medium bg-red-100 text-red-800">Pending</span>;
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

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Riders Management</h1>
          <p className="text-gray-600">Manage delivery riders and their accounts</p>
        </div>
        <button
          onClick={() => setShowCreateModal(true)}
          className="bg-primary text-white px-4 py-2 rounded-lg hover:bg-primary-dark transition"
        >
          Add New Rider
        </button>
      </div>

      {/* Filters */}
      <div className="bg-white p-4 rounded-lg shadow">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div>
            <label htmlFor="search-input" className="block text-sm font-medium text-gray-700 mb-1">Search</label>
            <input
              id="search-input"
              type="text"
              placeholder="Search riders..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
            />
          </div>
          <div>
            <label htmlFor="status-filter" className="block text-sm font-medium text-gray-700 mb-1">Status</label>
            <select
              id="status-filter"
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
            >
              <option value="">All Status</option>
              <option value="online">Online</option>
              <option value="offline">Offline</option>
              <option value="busy">Busy</option>
              <option value="on_delivery">On Delivery</option>
            </select>
          </div>
          <div>
            <label htmlFor="approval-filter" className="block text-sm font-medium text-gray-700 mb-1">Approval</label>
            <select
              id="approval-filter"
              value={approvalFilter}
              onChange={(e) => setApprovalFilter(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
            >
              <option value="">All</option>
              <option value="true">Approved</option>
              <option value="false">Pending</option>
            </select>
          </div>
          <div className="flex items-end">
            <button
              onClick={() => {
                setSearch('');
                setStatusFilter('');
                setApprovalFilter('');
                setPagination(prev => ({ ...prev, page: 1 })); // Reset to first page on clear filters
              }}
              className="w-full px-3 py-2 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200 transition"
            >
              Clear Filters
            </button>
          </div>
        </div>
      </div>

      {/* Riders List */}
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Rider</th>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Vehicle</th>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Approval</th>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Performance</th>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Earnings</th>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {riders.length > 0 ? (
                riders.map((rider) => (
                  <tr key={rider._id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <div className="flex-shrink-0 h-10 w-10">
                          <div className="h-10 w-10 rounded-full bg-gray-300 flex items-center justify-center">
                            <span className="text-sm font-medium text-gray-700">
                              {rider.profile.fullName.charAt(0).toUpperCase()}
                            </span>
                          </div>
                        </div>
                        <div className="ml-4">
                          <div className="text-sm font-medium text-gray-900">{rider.profile.fullName}</div>
                          <div className="text-sm text-gray-500">{rider.profile.phone}</div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <span className="text-lg mr-2">{getVehicleIcon(rider.vehicle.type)}</span>
                        <div>
                          <div className="text-sm font-medium text-gray-900">
                            {rider.vehicle.brand} {rider.vehicle.model}
                          </div>
                          <div className="text-sm text-gray-500">{rider.vehicle.type}</div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      {getStatusBadge(rider.status)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      {getApprovalBadge(rider.verification.isApproved)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-gray-900">
                        <div>⭐ {(rider.performance.averageRating || 0).toFixed(1)}</div>
                        <div className="text-gray-500">{rider.performance.completedDeliveries || 0} deliveries</div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-gray-900">
                        <div>₹{(rider.earnings.totalEarnings || 0).toLocaleString()}</div>
                        <div className="text-gray-500">Total</div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                      <div className="flex space-x-2">
                        <Link
                          to={`/admin/riders/${rider._id}`}
                          className="text-primary hover:text-primary-dark"
                        >
                          View
                        </Link>
                        {/* Approve/Unapprove button */}
                        <button
                          onClick={() => handleApprove(rider._id, !rider.verification.isApproved)}
                          className={rider.verification.isApproved ? 'text-orange-600 hover:text-orange-900' : 'text-green-600 hover:text-green-900'}
                        >
                          {rider.verification.isApproved ? 'Unapprove' : 'Approve'}
                        </button>
                        {/* Block/Unblock button (fixed logic) */}
                        <button
                          onClick={() => handleBlock(rider._id, rider.status)}
                          className={rider.status === 'offline' ? 'text-green-600 hover:text-green-900' : 'text-red-600 hover:text-red-900'}
                        >
                          {rider.status === 'offline' ? 'Unblock' : 'Block'}
                        </button>
                        <button
                          onClick={() => handleDelete(rider._id)}
                          className="text-red-600 hover:text-red-900"
                        >
                          Delete
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan="7" className="px-6 py-4 text-center text-gray-500">No riders found.</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        {pagination.pages > 1 && (
          <div className="bg-white px-4 py-3 flex items-center justify-between border-t border-gray-200 sm:px-6">
            <div className="flex-1 flex justify-between sm:hidden">
              <button
                onClick={() => setPagination(prev => ({ ...prev, page: prev.page - 1 }))}
                disabled={pagination.page === 1}
                className="relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50"
              >
                Previous
              </button>
              <button
                onClick={() => setPagination(prev => ({ ...prev, page: prev.page + 1 }))}
                disabled={pagination.page === pagination.pages}
                className="ml-3 relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50"
              >
                Next
              </button>
            </div>
            <div className="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
              <div>
                <p className="text-sm text-gray-700">
                  Showing <span className="font-medium">{(pagination.page - 1) * pagination.limit + 1}</span> to{' '}
                  <span className="font-medium">
                    {Math.min(pagination.page * pagination.limit, pagination.total)}
                  </span>{' '}
                  of <span className="font-medium">{pagination.total}</span> results
                </p>
              </div>
              <div>
                <nav className="relative z-0 inline-flex rounded-md shadow-sm -space-x-px" aria-label="Pagination">
                  {Array.from({ length: pagination.pages }, (_, i) => i + 1).map((page) => (
                    <button
                      key={page}
                      onClick={() => setPagination(prev => ({ ...prev, page }))}
                      aria-current={page === pagination.page ? 'page' : undefined}
                      className={`relative inline-flex items-center px-4 py-2 border text-sm font-medium ${
                        page === pagination.page
                          ? 'z-10 bg-primary border-primary text-white'
                          : 'bg-white border-gray-300 text-gray-500 hover:bg-gray-50'
                      }`}
                    >
                      {page}
                    </button>
                  ))}
                </nav>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Create Rider Modal */}
      {showCreateModal && (
        <CreateRiderModal
          onClose={() => setShowCreateModal(false)}
          onSuccess={() => {
            setShowCreateModal(false);
            fetchRiders(); // Re-fetch riders to show the newly created one
          }}
        />
      )}
    </div>
  );
}

// Create Rider Modal Component (Updated with validation and all required fields)
function CreateRiderModal({ onClose, onSuccess }) {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    password: '',
    profile: {
      fullName: '', // Will be set from 'name'
      gender: 'male',
      emergencyContact: {
        name: '',
        phone: '',
        relationship: ''
      }
    },
    vehicle: {
      type: 'bike',
      brand: '',
      model: '',
      year: new Date().getFullYear(),
      color: '',
      licensePlate: ''
    },
    documents: {
      drivingLicense: {
        number: '',
        expiryDate: ''
      }
    },
    workPreferences: {
      isAvailable: true,
      workingHours: {
        start: '09:00',
        end: '18:00'
      },
      preferredAreas: [],
      maxDistance: 10
    }
  });

  const [loading, setLoading] = useState(false);
  const [errors, setErrors] = useState({}); // State to hold validation errors

  const validateForm = () => {
    const newErrors = {};
    if (!formData.name.trim()) newErrors.name = 'Full Name is required.';
    if (!formData.email.trim()) newErrors.email = 'Email is required.';
    else if (!/\S+@\S+\.\S+/.test(formData.email)) newErrors.email = 'Email is invalid.';
    if (!formData.phone.trim()) newErrors.phone = 'Phone number is required.';
    else if (!/^\d{10,}$/.test(formData.phone)) newErrors.phone = 'Phone number is invalid (min 10 digits).'; // Basic phone validation
    if (!formData.password.trim()) newErrors.password = 'Password is required.';
    else if (formData.password.trim().length < 6) newErrors.password = 'Password must be at least 6 characters.'; // Example password validation

    if (!formData.vehicle.brand.trim()) newErrors['vehicle.brand'] = 'Vehicle Brand is required.';
    if (!formData.vehicle.model.trim()) newErrors['vehicle.model'] = 'Vehicle Model is required.';
    if (!formData.vehicle.licensePlate.trim()) newErrors['vehicle.licensePlate'] = 'License Plate is required.';

    if (!formData.documents.drivingLicense.number.trim()) newErrors['documents.drivingLicense.number'] = 'Driving License Number is required.';
    else if (!/^DL\d{13}$/.test(formData.documents.drivingLicense.number)) newErrors['documents.drivingLicense.number'] = 'Format: DL followed by 13 digits.';
    
    if (!formData.documents.drivingLicense.expiryDate.trim()) newErrors['documents.drivingLicense.expiryDate'] = 'Driving License Expiry Date is required.';
    else if (new Date(formData.documents.drivingLicense.expiryDate) < new Date()) {
      newErrors['documents.drivingLicense.expiryDate'] = 'Expiry date cannot be in the past.';
    }


    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!validateForm()) {
      alert('Please correct the errors in the form.');
      return;
    }

    setLoading(true);

    try {
      // Prepare the data in the correct format for the backend
      const riderData = {
        name: formData.name,
        email: formData.email,
        phone: formData.phone,
        password: formData.password,
        profile: {
          ...formData.profile,
          fullName: formData.name, // Use the name field for fullName
          email: formData.email,
          phone: formData.phone
        },
        vehicle: {
          ...formData.vehicle,
          type: formData.vehicle.type || 'bike'
        },
        documents: {
          drivingLicense: {
            number: formData.documents.drivingLicense.number,
            expiryDate: formData.documents.drivingLicense.expiryDate
          }
        },
        workPreferences: {
          ...formData.workPreferences,
          isAvailable: true
        }
      };

      console.log('Sending rider data:', riderData);
      const response = await api.post('/admin/riders', riderData);
      console.log('Response:', response);
      onSuccess();
    } catch (error) {
      console.error('Error creating rider:', error);
      const errorMessage = error.response?.data?.message || error.message || 'Error creating rider. Please try again.';
      alert(errorMessage);
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
    // Clear error for the field being changed
    setErrors(prevErrors => {
      const newErrors = { ...prevErrors };
      delete newErrors[path];
      return newErrors;
    });
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-xl font-bold">Create New Rider</h2>
          <button onClick={onClose} className="text-gray-500 hover:text-gray-700" aria-label="Close modal">
            ✕
          </button>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Basic Information */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label htmlFor="fullName" className="block text-sm font-medium text-gray-700 mb-1">Full Name</label>
              <input
                type="text"
                id="fullName"
                required
                value={formData.name}
                onChange={(e) => handleChange('name', e.target.value)}
                className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 ${errors.name ? 'border-red-500' : 'border-gray-300 focus:ring-primary'}`}
              />
              {errors.name && <p className="text-red-500 text-xs mt-1">{errors.name}</p>}
            </div>
            <div>
              <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-1">Email</label>
              <input
                type="email"
                id="email"
                required
                value={formData.email}
                onChange={(e) => handleChange('email', e.target.value)}
                className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 ${errors.email ? 'border-red-500' : 'border-gray-300 focus:ring-primary'}`}
              />
              {errors.email && <p className="text-red-500 text-xs mt-1">{errors.email}</p>}
            </div>
            <div>
              <label htmlFor="phone" className="block text-sm font-medium text-gray-700 mb-1">Phone</label>
              <input
                type="tel"
                id="phone"
                required
                value={formData.phone}
                onChange={(e) => handleChange('phone', e.target.value)}
                className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 ${errors.phone ? 'border-red-500' : 'border-gray-300 focus:ring-primary'}`}
              />
              {errors.phone && <p className="text-red-500 text-xs mt-1">{errors.phone}</p>}
            </div>
            <div>
              <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-1">Password</label>
              <input
                type="password"
                id="password"
                required
                value={formData.password}
                onChange={(e) => handleChange('password', e.target.value)}
                className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 ${errors.password ? 'border-red-500' : 'border-gray-300 focus:ring-primary'}`}
              />
              {errors.password && <p className="text-red-500 text-xs mt-1">{errors.password}</p>}
            </div>
          </div>

          {/* Vehicle Information */}
          <div className="border-t pt-6">
            <h3 className="text-lg font-medium mb-4">Vehicle Information</h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div>
                <label htmlFor="vehicleType" className="block text-sm font-medium text-gray-700 mb-1">Vehicle Type</label>
                <select
                  id="vehicleType"
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
                <label htmlFor="vehicleBrand" className="block text-sm font-medium text-gray-700 mb-1">Brand</label>
                <input
                  type="text"
                  id="vehicleBrand"
                  required
                  value={formData.vehicle.brand}
                  onChange={(e) => handleChange('vehicle.brand', e.target.value)}
                  className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 ${errors['vehicle.brand'] ? 'border-red-500' : 'border-gray-300 focus:ring-primary'}`}
                />
                {errors['vehicle.brand'] && <p className="text-red-500 text-xs mt-1">{errors['vehicle.brand']}</p>}
              </div>
              <div>
                <label htmlFor="vehicleModel" className="block text-sm font-medium text-gray-700 mb-1">Model</label>
                <input
                  type="text"
                  id="vehicleModel"
                  required
                  value={formData.vehicle.model}
                  onChange={(e) => handleChange('vehicle.model', e.target.value)}
                  className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 ${errors['vehicle.model'] ? 'border-red-500' : 'border-gray-300 focus:ring-primary'}`}
                />
                {errors['vehicle.model'] && <p className="text-red-500 text-xs mt-1">{errors['vehicle.model']}</p>}
              </div>
              <div>
                <label htmlFor="licensePlate" className="block text-sm font-medium text-gray-700 mb-1">License Plate</label>
                <input
                  type="text"
                  id="licensePlate"
                  required
                  value={formData.vehicle.licensePlate}
                  onChange={(e) => handleChange('vehicle.licensePlate', e.target.value)}
                  className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 ${errors['vehicle.licensePlate'] ? 'border-red-500' : 'border-gray-300 focus:ring-primary'}`}
                />
                {errors['vehicle.licensePlate'] && <p className="text-red-500 text-xs mt-1">{errors['vehicle.licensePlate']}</p>}
              </div>
            </div>
          </div>

          {/* Documents */}
          <div className="border-t pt-6">
            <h3 className="text-lg font-medium mb-4">Documents</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label htmlFor="drivingLicenseNumber" className="block text-sm font-medium text-gray-700 mb-1">Driving License Number</label>
                <input
                  type="text"
                  id="drivingLicenseNumber"
                  required
                  placeholder="DL1234567890123"
                  value={formData.documents.drivingLicense.number}
                  onChange={(e) => handleChange('documents.drivingLicense.number', e.target.value)}
                  className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 ${errors['documents.drivingLicense.number'] ? 'border-red-500' : 'border-gray-300 focus:ring-primary'}`}
                />
                {errors['documents.drivingLicense.number'] && <p className="text-red-500 text-xs mt-1">{errors['documents.drivingLicense.number']}</p>}
                <p className="text-xs text-gray-500 mt-1">Format: DL followed by 13 digits (e.g., DL1234567890123)</p>
              </div>
              <div>
                <label htmlFor="drivingLicenseExpiryDate" className="block text-sm font-medium text-gray-700 mb-1">Expiry Date</label>
                <input
                  type="date"
                  id="drivingLicenseExpiryDate"
                  required
                  value={formData.documents.drivingLicense.expiryDate}
                  onChange={(e) => handleChange('documents.drivingLicense.expiryDate', e.target.value)}
                  className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 ${errors['documents.drivingLicense.expiryDate'] ? 'border-red-500' : 'border-gray-300 focus:ring-primary'}`}
                />
                {errors['documents.drivingLicense.expiryDate'] && <p className="text-red-500 text-xs mt-1">{errors['documents.drivingLicense.expiryDate']}</p>}
                <p className="text-xs text-gray-500 mt-1">License expiry date</p>
              </div>
            </div>
          </div>

          {/* Actions */}
          <div className="flex justify-end space-x-3 pt-6 border-t">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50"
              disabled={loading} // Disable cancel during submission
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={loading}
              className="px-4 py-2 bg-primary text-white rounded-md hover:bg-primary-dark disabled:opacity-50"
            >
              {loading ? 'Creating...' : 'Create Rider'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

CreateRiderModal.propTypes = {
  onClose: PropTypes.func.isRequired,
  onSuccess: PropTypes.func.isRequired,
};