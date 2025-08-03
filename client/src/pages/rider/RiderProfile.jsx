import React, { useState, useEffect } from 'react';
import { api } from '../../api';

export default function RiderProfile() {
  const [rider, setRider] = useState(null);
  const [loading, setLoading] = useState(true);
  const [editing, setEditing] = useState(false);
  const [formData, setFormData] = useState({});
  const [errors, setErrors] = useState({});

  useEffect(() => {
    fetchRiderProfile();
  }, []);

  const fetchRiderProfile = async () => {
    try {
      const response = await api.get('/riders/profile');
      setRider(response.rider);
      setFormData({
        profile: { ...response.rider.profile },
        vehicle: { ...response.rider.vehicle },
        workPreferences: { ...response.rider.workPreferences }
      });
    } catch (error) {
      console.error('Error fetching rider profile:', error);
    } finally {
      setLoading(false);
    }
  };

  const validateForm = () => {
    const newErrors = {};
    
    if (!formData.profile?.fullName?.trim()) {
      newErrors['profile.fullName'] = 'Full name is required';
    }
    
    if (!formData.profile?.phone?.trim()) {
      newErrors['profile.phone'] = 'Phone number is required';
    } else if (!/^\d{10,}$/.test(formData.profile.phone)) {
      newErrors['profile.phone'] = 'Phone number must be at least 10 digits';
    }

    if (!formData.vehicle?.brand?.trim()) {
      newErrors['vehicle.brand'] = 'Vehicle brand is required';
    }

    if (!formData.vehicle?.model?.trim()) {
      newErrors['vehicle.model'] = 'Vehicle model is required';
    }

    if (!formData.vehicle?.licensePlate?.trim()) {
      newErrors['vehicle.licensePlate'] = 'License plate is required';
    }

    if (formData.workPreferences?.maxDistance < 1) {
      newErrors['workPreferences.maxDistance'] = 'Max distance must be at least 1 km';
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

    try {
      await api.put('/riders/profile', formData);
      alert('Profile updated successfully!');
      setEditing(false);
      fetchRiderProfile();
    } catch (error) {
      console.error('Error updating profile:', error);
      alert('Failed to update profile. Please try again.');
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
        <h2 className="text-xl font-semibold text-gray-900">Profile not found</h2>
        <p className="text-gray-600 mt-2">Please contact support if this is an error.</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Profile</h1>
          <p className="text-gray-600">Manage your personal information and preferences</p>
        </div>
        <button
          onClick={() => setEditing(!editing)}
          className="bg-primary text-white px-4 py-2 rounded-lg hover:bg-primary-dark transition"
        >
          {editing ? 'Cancel Edit' : 'Edit Profile'}
        </button>
      </div>

      <form onSubmit={handleSubmit} className="space-y-6">
        {/* Personal Information */}
        <div className="bg-white p-6 rounded-lg shadow">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Personal Information</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label htmlFor="fullName" className="block text-sm font-medium text-gray-700 mb-1">
                Full Name
              </label>
              {editing ? (
                <input
                  id="fullName"
                  type="text"
                  value={formData.profile?.fullName || ''}
                  onChange={(e) => handleChange('profile.fullName', e.target.value)}
                  className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 ${
                    errors['profile.fullName'] ? 'border-red-500' : 'border-gray-300 focus:ring-primary'
                  }`}
                />
              ) : (
                <p className="text-sm text-gray-900">{rider.profile.fullName}</p>
              )}
              {errors['profile.fullName'] && (
                <p className="text-red-500 text-xs mt-1">{errors['profile.fullName']}</p>
              )}
            </div>

            <div>
              <label htmlFor="phone" className="block text-sm font-medium text-gray-700 mb-1">
                Phone Number
              </label>
              {editing ? (
                <input
                  id="phone"
                  type="tel"
                  value={formData.profile?.phone || ''}
                  onChange={(e) => handleChange('profile.phone', e.target.value)}
                  className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 ${
                    errors['profile.phone'] ? 'border-red-500' : 'border-gray-300 focus:ring-primary'
                  }`}
                />
              ) : (
                <p className="text-sm text-gray-900">{rider.profile.phone}</p>
              )}
              {errors['profile.phone'] && (
                <p className="text-red-500 text-xs mt-1">{errors['profile.phone']}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Email</label>
              <p className="text-sm text-gray-900">{rider.profile.email}</p>
              <p className="text-xs text-gray-500 mt-1">Email cannot be changed</p>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Gender</label>
              {editing ? (
                <select
                  value={formData.profile?.gender || 'male'}
                  onChange={(e) => handleChange('profile.gender', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
                >
                  <option value="male">Male</option>
                  <option value="female">Female</option>
                  <option value="other">Other</option>
                </select>
              ) : (
                <p className="text-sm text-gray-900 capitalize">{rider.profile.gender}</p>
              )}
            </div>
          </div>
        </div>

        {/* Vehicle Information */}
        <div className="bg-white p-6 rounded-lg shadow">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Vehicle Information</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Vehicle Type</label>
              {editing ? (
                <select
                  value={formData.vehicle?.type || 'bike'}
                  onChange={(e) => handleChange('vehicle.type', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
                >
                  <option value="bike">Bike</option>
                  <option value="scooter">Scooter</option>
                  <option value="car">Car</option>
                  <option value="bicycle">Bicycle</option>
                </select>
              ) : (
                <div className="flex items-center">
                  <span className="text-lg mr-2">{getVehicleIcon(rider.vehicle.type)}</span>
                  <span className="text-sm text-gray-900 capitalize">{rider.vehicle.type}</span>
                </div>
              )}
            </div>

            <div>
              <label htmlFor="vehicleBrand" className="block text-sm font-medium text-gray-700 mb-1">
                Brand
              </label>
              {editing ? (
                <input
                  id="vehicleBrand"
                  type="text"
                  value={formData.vehicle?.brand || ''}
                  onChange={(e) => handleChange('vehicle.brand', e.target.value)}
                  className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 ${
                    errors['vehicle.brand'] ? 'border-red-500' : 'border-gray-300 focus:ring-primary'
                  }`}
                />
              ) : (
                <p className="text-sm text-gray-900">{rider.vehicle.brand}</p>
              )}
              {errors['vehicle.brand'] && (
                <p className="text-red-500 text-xs mt-1">{errors['vehicle.brand']}</p>
              )}
            </div>

            <div>
              <label htmlFor="vehicleModel" className="block text-sm font-medium text-gray-700 mb-1">
                Model
              </label>
              {editing ? (
                <input
                  id="vehicleModel"
                  type="text"
                  value={formData.vehicle?.model || ''}
                  onChange={(e) => handleChange('vehicle.model', e.target.value)}
                  className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 ${
                    errors['vehicle.model'] ? 'border-red-500' : 'border-gray-300 focus:ring-primary'
                  }`}
                />
              ) : (
                <p className="text-sm text-gray-900">{rider.vehicle.model}</p>
              )}
              {errors['vehicle.model'] && (
                <p className="text-red-500 text-xs mt-1">{errors['vehicle.model']}</p>
              )}
            </div>

            <div>
              <label htmlFor="licensePlate" className="block text-sm font-medium text-gray-700 mb-1">
                License Plate
              </label>
              {editing ? (
                <input
                  id="licensePlate"
                  type="text"
                  value={formData.vehicle?.licensePlate || ''}
                  onChange={(e) => handleChange('vehicle.licensePlate', e.target.value)}
                  className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 ${
                    errors['vehicle.licensePlate'] ? 'border-red-500' : 'border-gray-300 focus:ring-primary'
                  }`}
                />
              ) : (
                <p className="text-sm text-gray-900">{rider.vehicle.licensePlate}</p>
              )}
              {errors['vehicle.licensePlate'] && (
                <p className="text-red-500 text-xs mt-1">{errors['vehicle.licensePlate']}</p>
              )}
            </div>

            <div>
              <label htmlFor="vehicleColor" className="block text-sm font-medium text-gray-700 mb-1">
                Color
              </label>
              {editing ? (
                <input
                  id="vehicleColor"
                  type="text"
                  value={formData.vehicle?.color || ''}
                  onChange={(e) => handleChange('vehicle.color', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
                />
              ) : (
                <p className="text-sm text-gray-900 capitalize">{rider.vehicle.color}</p>
              )}
            </div>

            <div>
              <label htmlFor="vehicleYear" className="block text-sm font-medium text-gray-700 mb-1">
                Year
              </label>
              {editing ? (
                <input
                  id="vehicleYear"
                  type="number"
                  min="1900"
                  max={new Date().getFullYear() + 1}
                  value={formData.vehicle?.year || ''}
                  onChange={(e) => handleChange('vehicle.year', parseInt(e.target.value))}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
                />
              ) : (
                <p className="text-sm text-gray-900">{rider.vehicle.year}</p>
              )}
            </div>
          </div>
        </div>

        {/* Work Preferences */}
        <div className="bg-white p-6 rounded-lg shadow">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Work Preferences</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label htmlFor="maxDistance" className="block text-sm font-medium text-gray-700 mb-1">
                Maximum Distance (km)
              </label>
              {editing ? (
                <input
                  id="maxDistance"
                  type="number"
                  min="1"
                  max="50"
                  value={formData.workPreferences?.maxDistance || 10}
                  onChange={(e) => handleChange('workPreferences.maxDistance', parseInt(e.target.value))}
                  className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 ${
                    errors['workPreferences.maxDistance'] ? 'border-red-500' : 'border-gray-300 focus:ring-primary'
                  }`}
                />
              ) : (
                <p className="text-sm text-gray-900">{rider.workPreferences.maxDistance} km</p>
              )}
              {errors['workPreferences.maxDistance'] && (
                <p className="text-red-500 text-xs mt-1">{errors['workPreferences.maxDistance']}</p>
              )}
            </div>

            <div>
              <label htmlFor="workingHoursStart" className="block text-sm font-medium text-gray-700 mb-1">
                Working Hours Start
              </label>
              {editing ? (
                <input
                  id="workingHoursStart"
                  type="time"
                  value={formData.workPreferences?.workingHours?.start || '09:00'}
                  onChange={(e) => handleChange('workPreferences.workingHours.start', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
                />
              ) : (
                <p className="text-sm text-gray-900">{rider.workPreferences.workingHours?.start}</p>
              )}
            </div>

            <div>
              <label htmlFor="workingHoursEnd" className="block text-sm font-medium text-gray-700 mb-1">
                Working Hours End
              </label>
              {editing ? (
                <input
                  id="workingHoursEnd"
                  type="time"
                  value={formData.workPreferences?.workingHours?.end || '18:00'}
                  onChange={(e) => handleChange('workPreferences.workingHours.end', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
                />
              ) : (
                <p className="text-sm text-gray-900">{rider.workPreferences.workingHours?.end}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Availability</label>
              {editing ? (
                <div className="flex items-center">
                  <input
                    id="isAvailable"
                    type="checkbox"
                    checked={formData.workPreferences?.isAvailable || false}
                    onChange={(e) => handleChange('workPreferences.isAvailable', e.target.checked)}
                    className="h-4 w-4 text-primary focus:ring-primary border-gray-300 rounded"
                  />
                  <label htmlFor="isAvailable" className="ml-2 text-sm text-gray-900">
                    Available for deliveries
                  </label>
                </div>
              ) : (
                <p className="text-sm text-gray-900">
                  {rider.workPreferences.isAvailable ? 'Available' : 'Not Available'}
                </p>
              )}
            </div>
          </div>
        </div>

        {/* Emergency Contact */}
        <div className="bg-white p-6 rounded-lg shadow">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Emergency Contact</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
              <label htmlFor="emergencyName" className="block text-sm font-medium text-gray-700 mb-1">
                Contact Name
              </label>
              {editing ? (
                <input
                  id="emergencyName"
                  type="text"
                  value={formData.profile?.emergencyContact?.name || ''}
                  onChange={(e) => handleChange('profile.emergencyContact.name', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
                />
              ) : (
                <p className="text-sm text-gray-900">{rider.profile.emergencyContact?.name || 'Not provided'}</p>
              )}
            </div>

            <div>
              <label htmlFor="emergencyPhone" className="block text-sm font-medium text-gray-700 mb-1">
                Contact Phone
              </label>
              {editing ? (
                <input
                  id="emergencyPhone"
                  type="tel"
                  value={formData.profile?.emergencyContact?.phone || ''}
                  onChange={(e) => handleChange('profile.emergencyContact.phone', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
                />
              ) : (
                <p className="text-sm text-gray-900">{rider.profile.emergencyContact?.phone || 'Not provided'}</p>
              )}
            </div>

            <div>
              <label htmlFor="emergencyRelationship" className="block text-sm font-medium text-gray-700 mb-1">
                Relationship
              </label>
              {editing ? (
                <input
                  id="emergencyRelationship"
                  type="text"
                  value={formData.profile?.emergencyContact?.relationship || ''}
                  onChange={(e) => handleChange('profile.emergencyContact.relationship', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
                />
              ) : (
                <p className="text-sm text-gray-900">{rider.profile.emergencyContact?.relationship || 'Not provided'}</p>
              )}
            </div>
          </div>
        </div>

        {/* Submit Button */}
        {editing && (
          <div className="flex justify-end space-x-3">
            <button
              type="button"
              onClick={() => setEditing(false)}
              className="px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="px-4 py-2 bg-primary text-white rounded-md hover:bg-primary-dark"
            >
              Save Changes
            </button>
          </div>
        )}
      </form>
    </div>
  );
} 