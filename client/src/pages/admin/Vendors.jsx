import React, { useEffect, useState } from 'react';
import { api } from '../../api';
import Table from '../../components/Table';
import Skeleton from '../../components/Skeleton';
import Loader from '../../components/Loader';
import * as Dialog from '@radix-ui/react-dialog';
import { Link } from 'react-router-dom';
import * as Toast from '@radix-ui/react-toast';

export default function Vendors() {
  const [vendors, setVendors] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [selectedVendor, setSelectedVendor] = useState(null);
  const [detailsOpen, setDetailsOpen] = useState(false);
  const [dialogType, setDialogType] = useState('view'); // 'create', 'edit', 'view'
  const [toastOpen, setToastOpen] = useState(false);
  const [toastMsg, setToastMsg] = useState('');

  const fetchVendors = async () => {
    setLoading(true);
    setError('');
    try {
      const data = await api.get('/admin/vendors');
      setVendors(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchVendors(); }, []);

  const columns = [
    { key: 'storeName', title: 'Store Name' },
    { key: 'name', title: 'Owner' },
    { key: 'email', title: 'Email' },
    { key: 'storeRating', title: 'Rating', render: v => v.storeRating?.toFixed(1) || '-' },
    { key: 'storeReviews', title: 'Reviews', render: v => v.storeReviews || '-' },
    { key: 'isActive', title: 'Status', render: v => v.isActive ? <span className="text-success font-semibold">Active</span> : <span className="text-danger font-semibold">Blocked</span> },
    { key: 'isFeatured', title: 'Featured', render: v => (
      <button
        className={`text-xs px-2 py-1 rounded ${v.isFeatured ? 'bg-success text-white' : 'bg-gray-200 text-gray-700'}`}
        onClick={async () => {
          await api.patch(`/admin/vendors/${v._id}`, { isFeatured: !v.isFeatured });
          fetchVendors();
        }}
      >
        {v.isFeatured ? 'Yes' : 'No'}
      </button>
    ) },
    { key: 'actions', title: 'Actions', render: v => (
      <Link to={`/admin/vendors/${v._id}`} className="text-xs bg-primary text-white px-2 py-1 rounded">View</Link>
    )},
  ];

  const data = vendors.map(v => ({ ...v }));

  return (
    <Toast.Provider swipeDirection="right">
      <div className="min-h-screen bg-bg flex items-start justify-center pt-10">
        <div className="max-w-6xl w-full bg-surface rounded-xl shadow-lg p-8 border border-border">
          <div className="flex justify-between items-center mb-6">
            <h1 className="text-3xl font-bold text-primary">Vendors</h1>
            <button className="bg-primary text-white px-4 py-2 rounded font-semibold hover:bg-primary-dark transition" onClick={() => { setSelectedVendor(null); setDialogType('create'); setDetailsOpen(true); }}>Add Vendor</button>
          </div>
          <Table columns={columns} data={data} loading={loading} error={error} />
          <Dialog.Root open={detailsOpen} onOpenChange={setDetailsOpen}>
            <Dialog.Portal>
              <Dialog.Overlay className="fixed inset-0 bg-black/30 z-40" />
              <Dialog.Content className="fixed z-50 left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 bg-surface p-8 rounded-xl shadow-lg border border-border w-full max-w-2xl">
                {dialogType === 'create' && <VendorForm onClose={() => { setDetailsOpen(false); fetchVendors(); setToastMsg('Vendor created successfully!'); setToastOpen(true); }} />}
                {/* ... existing details ... */}
                <Dialog.Close asChild>
                  <button className="absolute top-4 right-4 text-gray-400 hover:text-primary text-2xl">&times;</button>
                </Dialog.Close>
              </Dialog.Content>
            </Dialog.Portal>
          </Dialog.Root>
        </div>
        <Toast.Root open={toastOpen} onOpenChange={setToastOpen} className="fixed bottom-6 right-6 bg-surface border border-border rounded shadow-lg px-6 py-3 text-sm font-medium text-gray-900 z-50">
          {toastMsg}
        </Toast.Root>
        <Toast.Viewport className="fixed bottom-0 right-0 flex flex-col p-6 gap-2 w-96 max-w-full z-50" />
      </div>
    </Toast.Provider>
  );
}

function VendorForm({ onClose }) {
  const [form, setForm] = useState({
    name: '',
    email: '',
    phone: '',
    password: '',
    storeName: '',
    storeDescription: '',
    storeImage: '',
    storeBanner: '',
    storeTags: '',
    isFeatured: false,
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleChange = e => {
    const { name, value, type, checked } = e.target;
    setForm(f => ({ ...f, [name]: type === 'checkbox' ? checked : value }));
  };

  const handleSubmit = async e => {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      await api.post('/admin/users', {
        ...form,
        role: 'vendor',
        storeTags: form.storeTags.split(',').map(t => t.trim()).filter(Boolean),
      });
      onClose();
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <h2 className="text-2xl font-bold mb-2 text-primary">Add Vendor</h2>
      {error && <div className="text-danger mb-2">{error}</div>}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block mb-1 font-medium">Name</label>
          <input name="name" value={form.name} onChange={handleChange} className="w-full border border-border rounded px-3 py-2" required />
        </div>
        <div>
          <label className="block mb-1 font-medium">Email</label>
          <input name="email" value={form.email} onChange={handleChange} className="w-full border border-border rounded px-3 py-2" required type="email" />
        </div>
        <div>
          <label className="block mb-1 font-medium">Phone</label>
          <input name="phone" value={form.phone} onChange={handleChange} className="w-full border border-border rounded px-3 py-2" required />
        </div>
        <div>
          <label className="block mb-1 font-medium">Password</label>
          <input name="password" value={form.password} onChange={handleChange} className="w-full border border-border rounded px-3 py-2" required type="password" />
        </div>
        <div>
          <label className="block mb-1 font-medium">Store Name</label>
          <input name="storeName" value={form.storeName} onChange={handleChange} className="w-full border border-border rounded px-3 py-2" required />
        </div>
        <div>
          <label className="block mb-1 font-medium">Store Description</label>
          <input name="storeDescription" value={form.storeDescription} onChange={handleChange} className="w-full border border-border rounded px-3 py-2" />
        </div>
        <div>
          <label className="block mb-1 font-medium">Store Image (Logo URL)</label>
          <input name="storeImage" value={form.storeImage} onChange={handleChange} className="w-full border border-border rounded px-3 py-2" />
        </div>
        <div>
          <label className="block mb-1 font-medium">Store Banner (URL)</label>
          <input name="storeBanner" value={form.storeBanner} onChange={handleChange} className="w-full border border-border rounded px-3 py-2" />
        </div>
        <div className="md:col-span-2">
          <label className="block mb-1 font-medium">Store Tags (comma separated)</label>
          <input name="storeTags" value={form.storeTags} onChange={handleChange} className="w-full border border-border rounded px-3 py-2" />
        </div>
        <div className="flex items-center gap-2 md:col-span-2">
          <input name="isFeatured" type="checkbox" checked={form.isFeatured} onChange={handleChange} id="isFeatured" />
          <label htmlFor="isFeatured">Featured</label>
        </div>
      </div>
      <div className="flex gap-2 justify-end mt-4">
        <button type="button" className="px-4 py-2 rounded bg-gray-200 hover:bg-gray-300" onClick={onClose} disabled={loading}>Cancel</button>
        <button type="submit" className="px-4 py-2 rounded bg-primary text-white hover:bg-primary-dark" disabled={loading}>{loading ? 'Saving...' : 'Create'}</button>
      </div>
    </form>
  );
} 