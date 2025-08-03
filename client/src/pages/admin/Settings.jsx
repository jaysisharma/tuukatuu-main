import React, { useState } from 'react';
import { api } from '../../api';
import Loader from '../../components/Loader';
import * as Toast from '@radix-ui/react-toast';

export default function Settings() {
  const [profile, setProfile] = useState({ name: '', email: '' });
  const [profileLoading, setProfileLoading] = useState(false);
  const [profileError, setProfileError] = useState('');
  const [profileSuccess, setProfileSuccess] = useState(false);

  const [password, setPassword] = useState({ oldPassword: '', newPassword: '', confirm: '' });
  const [passwordLoading, setPasswordLoading] = useState(false);
  const [passwordError, setPasswordError] = useState('');
  const [passwordSuccess, setPasswordSuccess] = useState(false);

  // Fetch current profile on mount
  React.useEffect(() => {
    setProfileLoading(true);
    api.get('/auth/me').then(data => {
      setProfile({ name: data.name, email: data.email });
    }).catch(() => {}).finally(() => setProfileLoading(false));
  }, []);

  const handleProfileChange = e => {
    const { name, value } = e.target;
    setProfile(p => ({ ...p, [name]: value }));
  };

  const handleProfileSubmit = async e => {
    e.preventDefault();
    setProfileLoading(true);
    setProfileError('');
    setProfileSuccess(false);
    try {
      await api.put('/auth/me', profile);
      setProfileSuccess(true);
    } catch (err) {
      setProfileError(err.message);
    } finally {
      setProfileLoading(false);
    }
  };

  const handlePasswordChange = e => {
    const { name, value } = e.target;
    setPassword(p => ({ ...p, [name]: value }));
  };

  const handlePasswordSubmit = async e => {
    e.preventDefault();
    setPasswordLoading(true);
    setPasswordError('');
    setPasswordSuccess(false);
    if (password.newPassword !== password.confirm) {
      setPasswordError('Passwords do not match');
      setPasswordLoading(false);
      return;
    }
    try {
      await api.put('/auth/change-password', { oldPassword: password.oldPassword, newPassword: password.newPassword });
      setPasswordSuccess(true);
      setPassword({ oldPassword: '', newPassword: '', confirm: '' });
    } catch (err) {
      setPasswordError(err.message);
    } finally {
      setPasswordLoading(false);
    }
  };

  return (
    <Toast.Provider swipeDirection="right">
      <div className="min-h-screen bg-bg flex items-start justify-center pt-10">
        <div className="max-w-xl w-full bg-surface rounded-xl shadow-lg p-8 border border-border">
          <h1 className="text-3xl font-bold mb-6 text-primary">Settings</h1>
          <form onSubmit={handleProfileSubmit} className="mb-10 space-y-4">
            <h2 className="text-xl font-bold mb-2">Profile</h2>
            <div>
              <label className="block mb-1 font-medium">Name</label>
              <input name="name" value={profile.name} onChange={handleProfileChange} className="w-full border border-border rounded px-3 py-2" required />
            </div>
            <div>
              <label className="block mb-1 font-medium">Email</label>
              <input name="email" value={profile.email} onChange={handleProfileChange} className="w-full border border-border rounded px-3 py-2" required type="email" />
            </div>
            <div className="flex gap-2 justify-end mt-4">
              <button type="submit" className="px-4 py-2 rounded bg-primary text-white hover:bg-primary-dark" disabled={profileLoading}>{profileLoading ? <Loader className="h-5 w-5" /> : 'Update Profile'}</button>
            </div>
            {profileError && <div className="text-danger mt-2">{profileError}</div>}
          </form>
          <form onSubmit={handlePasswordSubmit} className="space-y-4">
            <h2 className="text-xl font-bold mb-2">Change Password</h2>
            <div>
              <label className="block mb-1 font-medium">Old Password</label>
              <input name="oldPassword" value={password.oldPassword} onChange={handlePasswordChange} className="w-full border border-border rounded px-3 py-2" required type="password" />
            </div>
            <div>
              <label className="block mb-1 font-medium">New Password</label>
              <input name="newPassword" value={password.newPassword} onChange={handlePasswordChange} className="w-full border border-border rounded px-3 py-2" required type="password" />
            </div>
            <div>
              <label className="block mb-1 font-medium">Confirm New Password</label>
              <input name="confirm" value={password.confirm} onChange={handlePasswordChange} className="w-full border border-border rounded px-3 py-2" required type="password" />
            </div>
            <div className="flex gap-2 justify-end mt-4">
              <button type="submit" className="px-4 py-2 rounded bg-primary text-white hover:bg-primary-dark" disabled={passwordLoading}>{passwordLoading ? <Loader className="h-5 w-5" /> : 'Change Password'}</button>
            </div>
            {passwordError && <div className="text-danger mt-2">{passwordError}</div>}
          </form>
        </div>
        <Toast.Root open={profileSuccess || passwordSuccess} onOpenChange={v => { setProfileSuccess(false); setPasswordSuccess(false); }} className="fixed bottom-6 right-6 bg-surface border border-border rounded shadow-lg px-6 py-3 text-sm font-medium text-gray-900 z-50">
          {profileSuccess ? 'Profile updated successfully!' : passwordSuccess ? 'Password changed successfully!' : ''}
        </Toast.Root>
        <Toast.Viewport className="fixed bottom-0 right-0 flex flex-col p-6 gap-2 w-96 max-w-full z-50" />
      </div>
    </Toast.Provider>
  );
} 