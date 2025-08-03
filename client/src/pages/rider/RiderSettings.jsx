import React, { useState, useEffect } from 'react';
import { api } from '../../api';

export default function RiderSettings() {
  const [rider, setRider] = useState(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [settings, setSettings] = useState({
    notifications: {
      newOrders: true,
      orderUpdates: true,
      earnings: true,
      system: true
    },
    autoAccept: false,
    maxOrdersAtOnce: 1,
    workPreferences: {
      isAvailable: true,
      workingHours: {
        start: '09:00',
        end: '18:00'
      },
      maxDistance: 10
    }
  });

  useEffect(() => {
    fetchRiderSettings();
  }, []);

  const fetchRiderSettings = async () => {
    try {
      const response = await api.get('/riders/profile');
      setRider(response.rider);
      if (response.rider.settings) {
        setSettings(prev => ({
          ...prev,
          ...response.rider.settings,
          workPreferences: response.rider.workPreferences
        }));
      }
    } catch (error) {
      console.error('Error fetching rider settings:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSettingChange = (path, value) => {
    const keys = path.split('.');
    setSettings(prev => {
      const newSettings = { ...prev };
      let current = newSettings;
      for (let i = 0; i < keys.length - 1; i++) {
        current = current[keys[i]];
      }
      current[keys[keys.length - 1]] = value;
      return newSettings;
    });
  };

  const handleSaveSettings = async () => {
    setSaving(true);
    try {
      await api.put('/riders/profile', {
        settings: settings,
        workPreferences: settings.workPreferences
      });
      alert('Settings saved successfully!');
    } catch (error) {
      console.error('Error saving settings:', error);
      alert('Failed to save settings. Please try again.');
    } finally {
      setSaving(false);
    }
  };

  const handleChangePassword = async (e) => {
    e.preventDefault();
    const formData = new FormData(e.target);
    const currentPassword = formData.get('currentPassword');
    const newPassword = formData.get('newPassword');
    const confirmPassword = formData.get('confirmPassword');

    if (newPassword !== confirmPassword) {
      alert('New passwords do not match!');
      return;
    }

    if (newPassword.length < 6) {
      alert('Password must be at least 6 characters long!');
      return;
    }

    try {
      await api.put('/riders/change-password', {
        currentPassword,
        newPassword
      });
      alert('Password changed successfully!');
      e.target.reset();
    } catch (error) {
      console.error('Error changing password:', error);
      alert('Failed to change password. Please check your current password.');
    }
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
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Settings</h1>
        <p className="text-gray-600">Configure your preferences and account settings</p>
      </div>

      {/* Notifications Settings */}
      <div className="bg-white p-6 rounded-lg shadow">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Notification Preferences</h2>
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="font-medium text-gray-900">New Order Notifications</p>
              <p className="text-sm text-gray-600">Get notified when new orders are available</p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                checked={settings.notifications.newOrders}
                onChange={(e) => handleSettingChange('notifications.newOrders', e.target.checked)}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-primary/20 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary"></div>
            </label>
          </div>

          <div className="flex items-center justify-between">
            <div>
              <p className="font-medium text-gray-900">Order Update Notifications</p>
              <p className="text-sm text-gray-600">Get notified about order status changes</p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                checked={settings.notifications.orderUpdates}
                onChange={(e) => handleSettingChange('notifications.orderUpdates', e.target.checked)}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-primary/20 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary"></div>
            </label>
          </div>

          <div className="flex items-center justify-between">
            <div>
              <p className="font-medium text-gray-900">Earnings Notifications</p>
              <p className="text-sm text-gray-600">Get notified about earnings and payments</p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                checked={settings.notifications.earnings}
                onChange={(e) => handleSettingChange('notifications.earnings', e.target.checked)}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-primary/20 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary"></div>
            </label>
          </div>

          <div className="flex items-center justify-between">
            <div>
              <p className="font-medium text-gray-900">System Notifications</p>
              <p className="text-sm text-gray-600">Get notified about app updates and maintenance</p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                checked={settings.notifications.system}
                onChange={(e) => handleSettingChange('notifications.system', e.target.checked)}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-primary/20 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary"></div>
            </label>
          </div>
        </div>
      </div>

      {/* Work Preferences */}
      <div className="bg-white p-6 rounded-lg shadow">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Work Preferences</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Auto-Accept Orders
            </label>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                checked={settings.autoAccept}
                onChange={(e) => handleSettingChange('autoAccept', e.target.checked)}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-primary/20 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary"></div>
            </label>
            <p className="text-xs text-gray-500 mt-1">Automatically accept orders when available</p>
          </div>

          <div>
            <label htmlFor="maxOrders" className="block text-sm font-medium text-gray-700 mb-2">
              Maximum Orders at Once
            </label>
            <select
              id="maxOrders"
              value={settings.maxOrdersAtOnce}
              onChange={(e) => handleSettingChange('maxOrdersAtOnce', parseInt(e.target.value))}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
            >
              <option value={1}>1 Order</option>
              <option value={2}>2 Orders</option>
              <option value={3}>3 Orders</option>
              <option value={4}>4 Orders</option>
              <option value={5}>5 Orders</option>
            </select>
          </div>

          <div>
            <label htmlFor="workingHoursStart" className="block text-sm font-medium text-gray-700 mb-2">
              Working Hours Start
            </label>
            <input
              id="workingHoursStart"
              type="time"
              value={settings.workPreferences.workingHours.start}
              onChange={(e) => handleSettingChange('workPreferences.workingHours.start', e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
            />
          </div>

          <div>
            <label htmlFor="workingHoursEnd" className="block text-sm font-medium text-gray-700 mb-2">
              Working Hours End
            </label>
            <input
              id="workingHoursEnd"
              type="time"
              value={settings.workPreferences.workingHours.end}
              onChange={(e) => handleSettingChange('workPreferences.workingHours.end', e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
            />
          </div>

          <div>
            <label htmlFor="maxDistance" className="block text-sm font-medium text-gray-700 mb-2">
              Maximum Distance (km)
            </label>
            <input
              id="maxDistance"
              type="number"
              min="1"
              max="50"
              value={settings.workPreferences.maxDistance}
              onChange={(e) => handleSettingChange('workPreferences.maxDistance', parseInt(e.target.value))}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
            />
          </div>
        </div>
      </div>

      {/* Change Password */}
      <div className="bg-white p-6 rounded-lg shadow">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Change Password</h2>
        <form onSubmit={handleChangePassword} className="space-y-4">
          <div>
            <label htmlFor="currentPassword" className="block text-sm font-medium text-gray-700 mb-2">
              Current Password
            </label>
            <input
              id="currentPassword"
              name="currentPassword"
              type="password"
              required
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
            />
          </div>
          <div>
            <label htmlFor="newPassword" className="block text-sm font-medium text-gray-700 mb-2">
              New Password
            </label>
            <input
              id="newPassword"
              name="newPassword"
              type="password"
              required
              minLength="6"
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
            />
          </div>
          <div>
            <label htmlFor="confirmPassword" className="block text-sm font-medium text-gray-700 mb-2">
              Confirm New Password
            </label>
            <input
              id="confirmPassword"
              name="confirmPassword"
              type="password"
              required
              minLength="6"
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
            />
          </div>
          <button
            type="submit"
            className="px-4 py-2 bg-primary text-white rounded-md hover:bg-primary-dark"
          >
            Change Password
          </button>
        </form>
      </div>

      {/* Account Information */}
      <div className="bg-white p-6 rounded-lg shadow">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Account Information</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label className="block text-sm font-medium text-gray-700">Account ID</label>
            <p className="mt-1 text-sm text-gray-900">{rider?._id}</p>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700">Member Since</label>
            <p className="mt-1 text-sm text-gray-900">
              {rider ? new Date(rider.createdAt).toLocaleDateString() : 'N/A'}
            </p>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700">Verification Status</label>
            <p className="mt-1 text-sm text-gray-900">
              {rider?.verification?.isApproved ? 'Verified' : 'Pending Verification'}
            </p>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700">Last Active</label>
            <p className="mt-1 text-sm text-gray-900">
              {rider ? new Date(rider.updatedAt).toLocaleDateString() : 'N/A'}
            </p>
          </div>
        </div>
      </div>

      {/* Save Button */}
      <div className="flex justify-end">
        <button
          onClick={handleSaveSettings}
          disabled={saving}
          className="px-6 py-2 bg-primary text-white rounded-md hover:bg-primary-dark disabled:opacity-50"
        >
          {saving ? 'Saving...' : 'Save Settings'}
        </button>
      </div>
    </div>
  );
} 