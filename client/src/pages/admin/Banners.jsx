import React, { useEffect, useState } from 'react';
import { api } from '../../api';
import Table from '../../components/Table';
import Loader from '../../components/Loader';
import Skeleton from '../../components/Skeleton';
import * as Dialog from '@radix-ui/react-dialog';

export default function Banners() {
  const [banners, setBanners] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [selectedBanner, setSelectedBanner] = useState(null);
  const [detailsOpen, setDetailsOpen] = useState(false);
  const [dialogType, setDialogType] = useState(null); // 'create' | 'edit' | 'delete' | 'view'

  const fetchBanners = async () => {
    setLoading(true);
    setError('');
    try {
      const data = await api.get('/banners');
      setBanners(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchBanners(); }, []);

  const columns = [
    { key: 'imageUrl', title: '', render: b => b.imageUrl ? <img src={b.imageUrl} alt={b.title} className="w-16 h-10 rounded object-cover" /> : <Skeleton width="64px" height="40px" /> },
    { key: 'title', title: 'Title' },
    { key: 'subtitle', title: 'Subtitle' },
    { key: 'link', title: 'Link', render: b => b.link ? <a href={b.link} className="text-primary underline" target="_blank" rel="noopener noreferrer">{b.link}</a> : '-' },
    { key: 'isActive', title: 'Status', render: b => b.isActive ? <span className="text-success font-semibold">Active</span> : <span className="text-danger font-semibold">Inactive</span> },
    { key: 'createdAt', title: 'Created', render: b => new Date(b.createdAt).toLocaleDateString() },
    { key: 'actions', title: 'Actions', render: b => (
      <div className="flex gap-2">
        <button className="text-xs bg-primary text-white px-2 py-1 rounded" onClick={() => { setSelectedBanner(b); setDialogType('view'); setDetailsOpen(true); }}>View</button>
        <button className="text-xs bg-warning text-white px-2 py-1 rounded" onClick={() => { setSelectedBanner(b); setDialogType('edit'); setDetailsOpen(true); }}>Edit</button>
        <button className="text-xs bg-danger text-white px-2 py-1 rounded" onClick={() => { setSelectedBanner(b); setDialogType('delete'); setDetailsOpen(true); }}>Delete</button>
      </div>
    )},
  ];

  const data = banners.map(b => ({ ...b }));

  return (
    <div className="min-h-screen bg-bg flex items-start justify-center pt-10">
      <div className="max-w-4xl w-full bg-surface rounded-xl shadow-lg p-8 border border-border">
        <div className="flex justify-between items-center mb-6">
          <h1 className="text-3xl font-bold text-primary">Banners</h1>
          <button className="bg-primary text-white px-4 py-2 rounded font-semibold hover:bg-primary-dark transition" onClick={() => { setSelectedBanner(null); setDialogType('create'); setDetailsOpen(true); }}>Add Banner</button>
        </div>
        <Table columns={columns} data={data} loading={loading} error={error} />
        <Dialog.Root open={detailsOpen} onOpenChange={setDetailsOpen}>
          <Dialog.Portal>
            <Dialog.Overlay className="fixed inset-0 bg-black/30 z-40" />
            <Dialog.Content className="fixed z-50 left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 bg-surface p-8 rounded-xl shadow-lg border border-border w-full max-w-xl">
              {dialogType === 'view' && selectedBanner && <BannerDetails banner={selectedBanner} />}
              {(dialogType === 'edit' || dialogType === 'create') && <BannerForm banner={dialogType === 'edit' ? selectedBanner : null} onClose={() => { setDetailsOpen(false); fetchBanners(); }} />}
              {dialogType === 'delete' && selectedBanner && <DeleteBannerConfirm banner={selectedBanner} onClose={() => { setDetailsOpen(false); fetchBanners(); }} />}
              <Dialog.Close asChild>
                <button className="absolute top-4 right-4 text-gray-400 hover:text-primary text-2xl">&times;</button>
              </Dialog.Close>
            </Dialog.Content>
          </Dialog.Portal>
        </Dialog.Root>
      </div>
    </div>
  );
}

function BannerDetails({ banner }) {
  return (
    <div>
      <h2 className="text-2xl font-bold mb-2 text-primary">{banner.title}</h2>
      <div className="mb-2 text-gray-700">Subtitle: {banner.subtitle || '-'}</div>
      <div className="mb-2 text-gray-700">Link: {banner.link ? <a href={banner.link} className="text-primary underline" target="_blank" rel="noopener noreferrer">{banner.link}</a> : '-'}</div>
      <div className="mb-2 text-gray-700">Status: {banner.isActive ? <span className="text-success font-semibold">Active</span> : <span className="text-danger font-semibold">Inactive</span>}</div>
      <div className="mb-2 text-gray-700">Created: {new Date(banner.createdAt).toLocaleString()}</div>
      {banner.imageUrl && <img src={banner.imageUrl} alt={banner.title} className="w-full max-w-md h-48 object-cover rounded border border-border mt-4" />}
    </div>
  );
}

function BannerForm({ banner, onClose }) {
  const [form, setForm] = useState({
    title: banner?.title || '',
    subtitle: banner?.subtitle || '',
    imageUrl: banner?.imageUrl || '',
    link: banner?.link || '',
    isActive: banner?.isActive ?? true,
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
      if (banner) {
        await api.put(`/banners/${banner._id}`, form);
      } else {
        await api.post('/banners', form);
      }
      onClose();
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <h2 className="text-2xl font-bold mb-2 text-primary">{banner ? 'Edit' : 'Add'} Banner</h2>
      {error && <div className="text-danger mb-2">{error}</div>}
      <div>
        <label className="block mb-1 font-medium">Title</label>
        <input name="title" value={form.title} onChange={handleChange} className="w-full border border-border rounded px-3 py-2" required />
      </div>
      <div>
        <label className="block mb-1 font-medium">Subtitle</label>
        <input name="subtitle" value={form.subtitle} onChange={handleChange} className="w-full border border-border rounded px-3 py-2" />
      </div>
      <div>
        <label className="block mb-1 font-medium">Image URL</label>
        <input name="imageUrl" value={form.imageUrl} onChange={handleChange} className="w-full border border-border rounded px-3 py-2" required />
      </div>
      <div>
        <label className="block mb-1 font-medium">Link</label>
        <input name="link" value={form.link} onChange={handleChange} className="w-full border border-border rounded px-3 py-2" />
      </div>
      <div className="flex items-center gap-2">
        <input name="isActive" type="checkbox" checked={form.isActive} onChange={handleChange} id="isActive" />
        <label htmlFor="isActive">Active</label>
      </div>
      <div className="flex gap-2 justify-end mt-4">
        <button type="button" className="px-4 py-2 rounded bg-gray-200 hover:bg-gray-300" onClick={onClose} disabled={loading}>Cancel</button>
        <button type="submit" className="px-4 py-2 rounded bg-primary text-white hover:bg-primary-dark" disabled={loading}>{loading ? 'Saving...' : (banner ? 'Update' : 'Create')}</button>
      </div>
    </form>
  );
}

function DeleteBannerConfirm({ banner, onClose }) {
  const [loading, setLoading] = useState(false);
  const handleDelete = async () => {
    setLoading(true);
    try {
      await api.del(`/banners/${banner._id}`);
      onClose();
    } catch (err) {
      alert(err.message);
    } finally {
      setLoading(false);
    }
  };
  return (
    <div>
      <h2 className="text-2xl font-bold mb-4 text-danger">Delete Banner</h2>
      <div className="mb-4">Are you sure you want to delete <span className="font-semibold">{banner.title}</span>?</div>
      <div className="flex gap-2 justify-end">
        <button className="px-4 py-2 rounded bg-gray-200 hover:bg-gray-300" onClick={onClose} disabled={loading}>Cancel</button>
        <button className="px-4 py-2 rounded bg-danger text-white hover:bg-danger-dark" onClick={handleDelete} disabled={loading}>{loading ? 'Deleting...' : 'Delete'}</button>
      </div>
    </div>
  );
} 