import React, { useEffect, useState } from 'react';
import { api } from '../../api';

export default function Profile() {
  const [profile, setProfile] = useState(null);
  const [form, setForm] = useState(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [editImage, setEditImage] = useState(false);
  const [editBanner, setEditBanner] = useState(false);

  useEffect(() => {
    setLoading(true);
    api.get('/auth/me')
      .then(data => {
        setProfile(data);
        setForm({
          storeName: data.storeName || '',
          storeDescription: data.storeDescription || '',
          storeImage: data.storeImage || '',
          storeBanner: data.storeBanner || '',
          storeTags: (data.storeTags || []).join(', '),
        });
      })
      .catch(e => setError(e.message || 'Failed to load profile'))
      .finally(() => setLoading(false));
  }, []);

  const handleChange = e => {
    const { name, value } = e.target;
    setForm(f => ({ ...f, [name]: value }));
  };

  const handleSubmit = async e => {
    e.preventDefault();
    setSaving(true);
    setError('');
    setSuccess('');
    try {
      await api.put('/auth/me', {
        storeName: form.storeName,
        storeDescription: form.storeDescription,
        storeImage: form.storeImage,
        storeBanner: form.storeBanner,
        storeTags: form.storeTags.split(',').map(t => t.trim()).filter(Boolean),
      });
      setSuccess('Profile updated');
      setEditImage(false);
      setEditBanner(false);
    } catch (err) {
      setError(err.message);
    } finally {
      setSaving(false);
    }
  };

  if (loading) return <div className="flex justify-center items-center min-h-screen"><div className="animate-spin h-10 w-10 border-4 border-primary border-t-transparent rounded-full"></div></div>;
  if (error) return <div className="text-danger flex justify-center items-center min-h-screen">{error}</div>;
  if (!form) return null;

  return (
    <div className="p-6 max-w-2xl mx-auto">
      <h1 className="text-3xl font-bold text-primary mb-6">Store Profile</h1>
      <div className="bg-surface rounded-xl shadow-lg border border-border p-6 space-y-8">
        {success && <div className="text-success mb-2 p-3 bg-success/10 rounded-md">{success}</div>}
        {error && <div className="text-danger mb-2 p-3 bg-danger/10 rounded-md">{error}</div>}
        <form onSubmit={handleSubmit} className="space-y-8">
          <div className="flex flex-col md:flex-row gap-8 items-center">
            <div className="flex flex-col items-center gap-2">
              <div className="text-sm font-semibold mb-1">Store Image</div>
              <img src={form.storeImage || '/placeholder.png'} alt="Store" className="w-24 h-24 object-cover rounded-full border border-border bg-white" onError={e => e.target.src = '/placeholder.png'} />
              {editImage ? (
                <input name="storeImage" value={form.storeImage} onChange={handleChange} className="w-48 border border-border rounded px-2 py-1 mt-1" placeholder="Store Image URL" />
              ) : (
                <button type="button" className="text-xs text-primary underline mt-1" onClick={() => setEditImage(true)}>Edit</button>
              )}
              {editImage && (
                <button type="button" className="text-xs text-gray-500 underline mt-1" onClick={() => setEditImage(false)}>Cancel</button>
              )}
            </div>
            <div className="flex flex-col items-center gap-2">
              <div className="text-sm font-semibold mb-1">Store Banner</div>
              <img src={form.storeBanner || '/placeholder.png'} alt="Banner" className="w-48 h-16 object-cover rounded border border-border bg-white" onError={e => e.target.src = '/placeholder.png'} />
              {editBanner ? (
                <input name="storeBanner" value={form.storeBanner} onChange={handleChange} className="w-48 border border-border rounded px-2 py-1 mt-1" placeholder="Store Banner URL" />
              ) : (
                <button type="button" className="text-xs text-primary underline mt-1" onClick={() => setEditBanner(true)}>Edit</button>
              )}
              {editBanner && (
                <button type="button" className="text-xs text-gray-500 underline mt-1" onClick={() => setEditBanner(false)}>Cancel</button>
              )}
            </div>
          </div>
          <div className="space-y-4">
            <div>
              <label className="block mb-1 font-medium">Store Name</label>
              <input name="storeName" value={form.storeName} onChange={handleChange} className="w-full border border-border rounded px-3 py-2" required />
            </div>
            <div>
              <label className="block mb-1 font-medium">Store Description</label>
              <textarea name="storeDescription" value={form.storeDescription} onChange={handleChange} className="w-full border border-border rounded px-3 py-2" rows={3} />
            </div>
            <div>
              <label className="block mb-1 font-medium">Store Tags (comma separated)</label>
              <input name="storeTags" value={form.storeTags} onChange={handleChange} className="w-full border border-border rounded px-3 py-2" />
            </div>
          </div>
          <div className="flex gap-2 justify-end">
            <button type="submit" className="px-4 py-2 rounded bg-primary text-white hover:bg-primary-dark" disabled={saving}>{saving ? 'Saving...' : 'Save Changes'}</button>
          </div>
        </form>
      </div>
    </div>
  );
} 