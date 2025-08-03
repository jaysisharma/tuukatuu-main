import React, { useEffect, useState } from 'react';
import { api } from '../../api';
import Table from '../../components/Table';
import Loader from '../../components/Loader';
import Skeleton from '../../components/Skeleton';
import * as Dialog from '@radix-ui/react-dialog';

export default function Coupons() {
  const [coupons, setCoupons] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [selectedCoupon, setSelectedCoupon] = useState(null);
  const [detailsOpen, setDetailsOpen] = useState(false);
  const [dialogType, setDialogType] = useState(null); // 'create' | 'edit' | 'delete' | 'view'

  const fetchCoupons = async () => {
    setLoading(true);
    setError('');
    try {
      const data = await api.get('/coupons');
      setCoupons(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchCoupons(); }, []);

  const columns = [
    { key: 'code', title: 'Code' },
    { key: 'discount', title: 'Discount', render: c => c.type === 'amount' ? `Rs ${c.discount}` : `${c.discount}%` },
   
    { key: 'description', title: 'Description' },
    { key: 'expiryDate', title: 'Expiry', render: c => c.expiryDate ? new Date(c.expiryDate).toLocaleDateString() : '-' },
    { key: 'isActive', title: 'Status', render: c => c.isActive ? <span className="text-success font-semibold">Active</span> : <span className="text-danger font-semibold">Inactive</span> },
    { key: 'createdAt', title: 'Created', render: c => new Date(c.createdAt).toLocaleDateString() },
    { key: 'actions', title: 'Actions', render: c => (
      <div className="flex gap-2">
        <button className="text-xs bg-primary text-white px-2 py-1 rounded" onClick={() => { setSelectedCoupon(c); setDialogType('view'); setDetailsOpen(true); }}>View</button>
        <button className="text-xs bg-warning text-white px-2 py-1 rounded" onClick={() => { setSelectedCoupon(c); setDialogType('edit'); setDetailsOpen(true); }}>Edit</button>
        <button className="text-xs bg-danger text-white px-2 py-1 rounded" onClick={() => { setSelectedCoupon(c); setDialogType('delete'); setDetailsOpen(true); }}>Delete</button>
      </div>
    )},
  ];

  const data = coupons.map(c => ({ ...c }));

  return (
    <div className="min-h-screen bg-bg flex items-start justify-center pt-10">
      <div className="max-w-4xl w-full bg-surface rounded-xl shadow-lg p-8 border border-border">
        <div className="flex justify-between items-center mb-6">
          <h1 className="text-3xl font-bold text-primary">Coupons</h1>
          <button className="bg-primary text-white px-4 py-2 rounded font-semibold hover:bg-primary-dark transition" onClick={() => { setSelectedCoupon(null); setDialogType('create'); setDetailsOpen(true); }}>Add Coupon</button>
        </div>
        <Table columns={columns} data={data} loading={loading} error={error} />
        <Dialog.Root open={detailsOpen} onOpenChange={setDetailsOpen}>
          <Dialog.Portal>
            <Dialog.Overlay className="fixed inset-0 bg-black/30 z-40" />
            <Dialog.Content className="fixed z-50 left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 bg-surface p-8 rounded-xl shadow-lg border border-border w-full max-w-xl">
              {dialogType === 'view' && selectedCoupon && <CouponDetails coupon={selectedCoupon} />}
              {(dialogType === 'edit' || dialogType === 'create') && <CouponForm coupon={dialogType === 'edit' ? selectedCoupon : null} onClose={() => { setDetailsOpen(false); fetchCoupons(); }} />}
              {dialogType === 'delete' && selectedCoupon && <DeleteCouponConfirm coupon={selectedCoupon} onClose={() => { setDetailsOpen(false); fetchCoupons(); }} />}
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

function CouponDetails({ coupon }) {
  return (
    <div>
      <h2 className="text-2xl font-bold mb-2 text-primary">{coupon.code}</h2>
      <div className="mb-2 text-gray-700">Discount: <span className="font-semibold">{coupon.type === 'amount' ? `Rs ${coupon.discount}` : `${coupon.discount}%`}</span></div>
      
      <div className="mb-2 text-gray-700">Description: {coupon.description || '-'}</div>
      <div className="mb-2 text-gray-700">Expiry: {coupon.expiryDate ? new Date(coupon.expiryDate).toLocaleString() : '-'}</div>
      <div className="mb-2 text-gray-700">Status: {coupon.isActive ? <span className="text-success font-semibold">Active</span> : <span className="text-danger font-semibold">Inactive</span>}</div>
      <div className="mb-2 text-gray-700">Created: {new Date(coupon.createdAt).toLocaleString()}</div>
    </div>
  );
}

function CouponForm({ coupon, onClose }) {
  const [form, setForm] = useState({
    code: coupon?.code || '',
    discount: coupon?.discount || '',
    type: coupon?.type || 'percent',
    description: coupon?.description || '',
    expiryDate: coupon?.expiryDate ? coupon.expiryDate.slice(0, 10) : '',
    isActive: coupon?.isActive ?? true,
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
      if (coupon) {
        await api.put(`/coupons/${coupon._id}`, form);
      } else {
        await api.post('/coupons', form);
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
      <h2 className="text-2xl font-bold mb-2 text-primary">{coupon ? 'Edit' : 'Add'} Coupon</h2>
      {error && <div className="text-danger mb-2">{error}</div>}
      <div>
        <label className="block mb-1 font-medium">Code</label>
        <input name="code" value={form.code} onChange={handleChange} className="w-full border border-border rounded px-3 py-2" required disabled={!!coupon} />
      </div>
      <div className="flex gap-2">
        <div className="flex-1">
          <label className="block mb-1 font-medium">Discount</label>
          <input name="discount" type="number" value={form.discount} onChange={handleChange} className="w-full border border-border rounded px-3 py-2" required min={1} />
        </div>
        <div>
          <label className="block mb-1 font-medium">Type</label>
          <select name="type" value={form.type} onChange={handleChange} className="border border-border rounded px-3 py-2" required>
            <option value="percent">Percent (%)</option>
            <option value="amount">Amount (Rs)</option>
          </select>
        </div>
      </div>
      <div>
        <label className="block mb-1 font-medium">Description</label>
        <input name="description" value={form.description} onChange={handleChange} className="w-full border border-border rounded px-3 py-2" />
      </div>
      <div>
        <label className="block mb-1 font-medium">Expiry Date</label>
        <input name="expiryDate" type="date" value={form.expiryDate} onChange={handleChange} className="w-full border border-border rounded px-3 py-2" required />
      </div>
      <div className="flex items-center gap-2">
        <input name="isActive" type="checkbox" checked={form.isActive} onChange={handleChange} id="isActive" />
        <label htmlFor="isActive">Active</label>
      </div>
      <div className="flex gap-2 justify-end mt-4">
        <button type="button" className="px-4 py-2 rounded bg-gray-200 hover:bg-gray-300" onClick={onClose} disabled={loading}>Cancel</button>
        <button type="submit" className="px-4 py-2 rounded bg-primary text-white hover:bg-primary-dark" disabled={loading}>{loading ? 'Saving...' : (coupon ? 'Update' : 'Create')}</button>
      </div>
    </form>
  );
}

function DeleteCouponConfirm({ coupon, onClose }) {
  const [loading, setLoading] = useState(false);
  const handleDelete = async () => {
    setLoading(true);
    try {
      await api.del(`/coupons/${coupon._id}`);
      onClose();
    } catch (err) {
      alert(err.message);
    } finally {
      setLoading(false);
    }
  };
  return (
    <div>
      <h2 className="text-2xl font-bold mb-4 text-danger">Delete Coupon</h2>
      <div className="mb-4">Are you sure you want to delete <span className="font-semibold">{coupon.code}</span>?</div>
      <div className="flex gap-2 justify-end">
        <button className="px-4 py-2 rounded bg-gray-200 hover:bg-gray-300" onClick={onClose} disabled={loading}>Cancel</button>
        <button className="px-4 py-2 rounded bg-danger text-white hover:bg-danger-dark" onClick={handleDelete} disabled={loading}>{loading ? 'Deleting...' : 'Delete'}</button>
      </div>
    </div>
  );
} 