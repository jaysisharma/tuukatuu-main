import React, { useState } from 'react';
import { api } from '../../api';

export default function Settings() {
  const [oldPassword, setOldPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  const handleSubmit = async e => {
    e.preventDefault();
    setError('');
    setSuccess('');
    if (!oldPassword || !newPassword || !confirmPassword) {
      setError('All fields are required');
      return;
    }
    if (newPassword !== confirmPassword) {
      setError('New passwords do not match');
      return;
    }
    setLoading(true);
    try {
      await api.put('/auth/change-password', { oldPassword, newPassword });
      setSuccess('Password changed successfully');
      setOldPassword('');
      setNewPassword('');
      setConfirmPassword('');
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="p-6 max-w-md mx-auto">
      <h1 className="text-2xl font-bold text-primary mb-6">Settings</h1>
      {success && <div className="text-success mb-2 p-3 bg-success/10 rounded-md">{success}</div>}
      {error && <div className="text-danger mb-2 p-3 bg-danger/10 rounded-md">{error}</div>}
      <form onSubmit={handleSubmit} className="space-y-6">
        <div>
          <label className="block mb-1 font-medium">Old Password</label>
          <input type="password" value={oldPassword} onChange={e => setOldPassword(e.target.value)} className="w-full border border-border rounded px-3 py-2" required />
        </div>
        <div>
          <label className="block mb-1 font-medium">New Password</label>
          <input type="password" value={newPassword} onChange={e => setNewPassword(e.target.value)} className="w-full border border-border rounded px-3 py-2" required />
        </div>
        <div>
          <label className="block mb-1 font-medium">Confirm New Password</label>
          <input type="password" value={confirmPassword} onChange={e => setConfirmPassword(e.target.value)} className="w-full border border-border rounded px-3 py-2" required />
        </div>
        <div className="flex gap-2 justify-end">
          <button type="submit" className="px-4 py-2 rounded bg-primary text-white hover:bg-primary-dark" disabled={loading}>{loading ? 'Saving...' : 'Change Password'}</button>
        </div>
      </form>
    </div>
  );
} 