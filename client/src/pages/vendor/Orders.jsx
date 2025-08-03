import React, { useEffect, useState } from 'react';
import { api } from '../../api';
import toast, { Toaster } from 'react-hot-toast';

const VENDOR_STATUSES = [
  { key: 'pending', label: 'Pending' },
  { key: 'accepted', label: 'Accepted' },
  { key: 'preparing', label: 'Preparing' },
  { key: 'handed_over', label: 'Handed Over' },
  { key: 'rejected', label: 'Rejected' },
];
const ALL_STATUSES = [
  { key: 'pending', label: 'Pending' },
  { key: 'accepted', label: 'Accepted' },
  { key: 'preparing', label: 'Preparing' },
  { key: 'handed_over', label: 'Handed Over' },
  { key: 'picked_up', label: 'Picked Up' },
  { key: 'on_the_way', label: 'On The Way' },
  { key: 'delivered', label: 'Delivered' },
  { key: 'cancelled', label: 'Cancelled' },
  { key: 'rejected', label: 'Rejected' },
];

const STATUS_COLORS = {
  pending: 'bg-gray-300 text-gray-800',
  accepted: 'bg-blue-200 text-blue-800',
  preparing: 'bg-yellow-200 text-yellow-800',
  handed_over: 'bg-purple-200 text-purple-800',
  picked_up: 'bg-indigo-200 text-indigo-800',
  on_the_way: 'bg-cyan-200 text-cyan-800',
  delivered: 'bg-green-200 text-green-800',
  cancelled: 'bg-red-200 text-red-800',
  rejected: 'bg-red-400 text-white',
};

function formatDate(dateStr) {
  const d = new Date(dateStr);
  return d.toLocaleString('en-GB', {
    day: '2-digit', month: 'short', year: 'numeric',
    hour: 'numeric', minute: '2-digit', hour12: true
  }).replace(',', '');
}

function Stepper({ status }) {
  const currentIdx = ALL_STATUSES.findIndex(s => s.key === status);
  return (
    <div className="flex items-center gap-2 flex-wrap">
      {ALL_STATUSES.map((s, idx) => (
        <React.Fragment key={s.key}>
          <div className={`flex flex-col items-center gap-1 min-w-[70px]`}>
            <span className={`px-3 py-1 rounded-full text-xs font-semibold capitalize ${STATUS_COLORS[s.key]} ${idx === currentIdx ? 'ring-2 ring-primary' : ''}`}>{s.label}</span>
          </div>
          {idx < ALL_STATUSES.length - 1 && <span className="text-gray-300">→</span>}
        </React.Fragment>
      ))}
    </div>
  );
}

function OrderDetailModal({ order, onClose }) {
  const [showAll, setShowAll] = useState(false);
  const itemsToShow = showAll ? order.items : order.items.slice(0, 3);
  const hasMore = order.items.length > 3;

  // Fallback calculation for summary fields if missing
  const calcItemTotal = order.items.reduce((sum, item) => sum + (item.price * item.quantity), 0);
  const itemTotal = order.itemTotal ?? calcItemTotal;
  const tax = order.tax ?? Math.round(itemTotal * 0.05);
  const deliveryFee = order.deliveryFee ?? (itemTotal < 400 ? 40 : 0);
  const tip = order.tip ?? 0;
  const total = order.total ?? (itemTotal + tax + deliveryFee + tip);

  return (
    <div className="fixed inset-0  bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-surface rounded-2xl shadow-2xl p-8 border border-border w-full max-w-2xl relative animate-fadeIn">
        <button className="absolute top-2 right-2 text-gray-400 hover:text-danger text-2xl" onClick={onClose}>&times;</button>
        <h2 className="text-2xl font-bold mb-4 text-primary">Order Details</h2>
        <div className="mb-6 flex flex-col md:flex-row gap-6">
          <div className="flex-1 space-y-2">
            <div className="font-semibold">Order ID: <span className="font-mono">{order._id.slice(-6).toUpperCase()}</span></div>
            <div>Status: <span className={`font-semibold capitalize px-2 py-1 rounded ${STATUS_COLORS[order.status]}`}>{order.status.replace(/_/g, ' ')}</span></div>
            <div>Date: {formatDate(order.createdAt)}</div>
            {order.status === 'rejected' && order.rejectionReason && (
              <div className="text-danger font-semibold">Rejection Reason: {order.rejectionReason}</div>
            )}
            {order.specialInstructions && (
              <div className="text-primary font-medium">Special Instructions: <span className="text-gray-700">{order.specialInstructions}</span></div>
            )}
          </div>
          <div className="flex-1">
            {order.riderId && (
              <div className="mb-2">
                <h3 className="font-semibold mb-1">Delivery Partner</h3>
                <div>Name: {order.riderId.name || '-'}</div>
                {order.riderId.contact && <div>Contact: {order.riderId.contact}</div>}
                {order.eta && <div>ETA: {order.eta}</div>}
              </div>
            )}
          </div>
        </div>
        <div className="mb-6">
          <h3 className="font-semibold mb-2">Order Items</h3>
          <div className="overflow-x-auto">
            <table className="min-w-full text-sm border border-border rounded-xl">
              <thead>
                <tr className="bg-gray-100">
                  <th className="px-3 py-2 text-left">Product</th>
                  <th className="px-3 py-2 text-left">Image</th>
                  <th className="px-3 py-2 text-left">Qty</th>
                  <th className="px-3 py-2 text-left">Price</th>
                  <th className="px-3 py-2 text-left">Subtotal</th>
                </tr>
              </thead>
              <tbody>
                {itemsToShow.map(item => (
                  <tr key={item.product} className="border-b border-border">
                    <td className="px-3 py-2">{item.name}</td>
                    <td className="px-3 py-2">{item.image ? <img src={item.image} alt="" className="w-10 h-10 object-cover rounded" onError={e => e.target.src = '/placeholder.png'} /> : <div className="w-10 h-10 bg-gray-200 flex items-center justify-center rounded">🛒</div>}</td>
                    <td className="px-3 py-2">{item.quantity}</td>
                    <td className="px-3 py-2">Rs {item.price}</td>
                    <td className="px-3 py-2">Rs {item.price * item.quantity}</td>
                  </tr>
                ))}
              </tbody>
            </table>
            {hasMore && (
              <button className="mt-2 text-primary underline text-xs" onClick={() => setShowAll(s => !s)}>{showAll ? 'Show Less' : `Show All (${order.items.length})`}</button>
            )}
          </div>
        </div>
        <div className="mb-6 flex flex-col md:flex-row gap-6">
          <div className="flex-1">
            <h3 className="font-semibold mb-2">Order Summary</h3>
            <div className="flex flex-col gap-1">
              <div className="flex justify-between"><span>Subtotal:</span><span>Rs {itemTotal.toLocaleString()}</span></div>
              <div className="flex justify-between"><span>Tax:</span><span>Rs {tax.toLocaleString()}</span></div>
              <div className="flex justify-between"><span>Delivery Fee:</span><span>Rs {deliveryFee.toLocaleString()}</span></div>
              <div className="flex justify-between"><span>Tip:</span><span>Rs {tip.toLocaleString()}</span></div>
              <div className="flex justify-between font-bold text-primary mt-2"><span>Total:</span><span>Rs {total.toLocaleString()}</span></div>
            </div>
          </div>
          <div className="flex-1 flex flex-col justify-end items-end">
            {/* Only show current status badge, no stepper */}
            <span className={`px-3 py-1 rounded-full text-xs font-semibold capitalize ${STATUS_COLORS[order.status]}`}>{order.status.replace(/_/g, ' ')}</span>
          </div>
        </div>
      </div>
    </div>
  );
}

function RejectModal({ onSubmit, onCancel, loading }) {
  const [reason, setReason] = useState('');
  const [error, setError] = useState('');
  const handleSubmit = (e) => {
    e.preventDefault();
    if (!reason || reason.length < 3) {
      setError('Please provide a valid reason (at least 3 characters).');
      return;
    }
    onSubmit(reason);
  };
  return (
    <div className="fixed inset-0  bg-opacity-30 flex items-center justify-center z-50">
      <form onSubmit={handleSubmit} className="bg-surface rounded-xl shadow-lg p-8 border border-border w-full max-w-md relative animate-fadeIn">
        <button className="absolute top-2 right-2 text-gray-400 hover:text-danger text-2xl" onClick={onCancel} type="button">&times;</button>
        <h2 className="text-xl font-bold mb-4 text-danger">Reject Order</h2>
        {error && <div className="text-danger mb-2">{error}</div>}
        <label className="block mb-2 font-medium">Reason for rejection</label>
        <textarea className="w-full border border-border rounded px-3 py-2 mb-4" value={reason} onChange={e => setReason(e.target.value)} rows={3} required minLength={3} />
        <div className="flex gap-2 justify-end">
          <button type="button" className="px-4 py-2 rounded bg-gray-200 hover:bg-gray-300" onClick={onCancel} disabled={loading}>Cancel</button>
          <button type="submit" className="px-4 py-2 rounded bg-danger text-white hover:bg-danger-dark" disabled={loading}>{loading ? 'Rejecting...' : 'Reject'}</button>
        </div>
      </form>
    </div>
  );
}

export default function Orders() {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [selectedOrder, setSelectedOrder] = useState(null);
  const [success, setSuccess] = useState('');
  const [updatingId, setUpdatingId] = useState(null);
  const [rejectingOrder, setRejectingOrder] = useState(null);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');

  const fetchOrders = () => {
    setLoading(true);
    api.get('/orders/vendor/my')
      .then(setOrders)
      .catch(e => toast.error(e.message || 'Failed to load orders'))
      .finally(() => setLoading(false));
  };

  useEffect(() => { fetchOrders(); }, []);

  // Filtered orders
  const filteredOrders = orders.filter(order => {
    const matchesStatus = statusFilter === 'all' ? true : order.status === statusFilter;
    const matchesSearch =
      search.trim() === '' ||
      order._id.toLowerCase().includes(search.trim().toLowerCase()) ||
      order.items.some(item => item.name && item.name.toLowerCase().includes(search.trim().toLowerCase()));
    return matchesStatus && matchesSearch;
  });

  const handleStatusUpdate = async (orderId, nextStatus, rejectionReason) => {
    setUpdatingId(orderId);
    try {
      await api.put(`/orders/${orderId}/status`, nextStatus === 'rejected' ? { status: nextStatus, rejectionReason } : { status: nextStatus });
      toast.success('Order status updated');
      fetchOrders();
    } catch (err) {
      toast.error(err.message);
    } finally {
      setUpdatingId(null);
      setRejectingOrder(null);
    }
  };

  const getNextVendorStatusOptions = (currentStatus) => {
    if (currentStatus === 'pending') return [
      { key: 'accepted', label: 'Accept' },
      { key: 'rejected', label: 'Reject' },
    ];
    if (currentStatus === 'accepted') return [
      { key: 'preparing', label: 'Start Preparing' },
    ];
    if (currentStatus === 'preparing') return [
      { key: 'handed_over', label: 'Hand Over' },
    ];
    return [];
  };

  return (
    <div className="p-6 bg-transparent ">
      <Toaster position="top-right" />
      <h1 className="text-2xl font-bold text-primary mb-6">Orders</h1>
      <div className="flex flex-col md:flex-row md:items-center gap-3 mb-4">
        <input
          type="text"
          placeholder="Search by Order ID or Product Name..."
          value={search}
          onChange={e => setSearch(e.target.value)}
          className="border border-border rounded px-3 py-2 w-full md:w-64"
        />
        <select
          value={statusFilter}
          onChange={e => setStatusFilter(e.target.value)}
          className="border border-border rounded px-3 py-2 w-full md:w-48"
        > <option value="all">All</option>
          <option value="pending">Pending</option>
          <option value="accepted">Accepted</option>
          <option value="preparing">Preparing</option>
          <option value="handed_over">Handed Over</option>
          <option value="picked_up">Picked Up</option>
          <option value="on_the_way">On The Way</option>
          <option value="delivered">Delivered</option>
          <option value="cancelled">Cancelled</option>
          <option value="rejected">Rejected</option>
         
        </select>
      </div>
      {loading ? (
        <div className="flex justify-center items-center py-12"><div className="animate-spin h-8 w-8 border-4 border-primary border-t-transparent rounded-full"></div></div>
      ) : (
        <div className="overflow-x-auto rounded-xl shadow border border-border bg-surface">
          <table className="min-w-full text-sm">
            <thead>
              <tr className="bg-gray-100">
                <th className="px-3 py-2 text-left">Order ID</th>
                <th className="px-3 py-2 text-left">Total</th>
                <th className="px-3 py-2 text-left">Current Status</th>
                <th className="px-3 py-2 text-left">Date</th>
                <th className="px-3 py-2 text-left">Change Status</th>
                <th className="px-3 py-2 text-left">Details</th>
              </tr>
            </thead>
            <tbody>
              {filteredOrders.length === 0 && (
                <tr><td colSpan={6} className="text-center py-4 text-gray-400">No orders</td></tr>
              )}
              {filteredOrders.map(order => {
                const options = getNextVendorStatusOptions(order.status);
                const canUpdate = options.length > 0;
                return (
                  <tr key={order._id} className="border-b border-border hover:bg-gray-50 transition-all">
                    <td className="px-3 py-2 font-mono">{order._id.slice(-6).toUpperCase()}</td>
                    <td className="px-3 py-2">Rs {order.total?.toLocaleString() || '-'}</td>
                    <td className="px-3 py-2">
                      <span className={`px-2 py-1 rounded text-xs capitalize font-medium ${STATUS_COLORS[order.status]}`}>{order.status.replace(/_/g, ' ')}</span>
                    </td>
                    <td className="px-3 py-2">{new Date(order.createdAt).toLocaleString()}</td>
                    <td className="px-3 py-2">
                      {canUpdate ? (
                        <select
                          value=""
                          onChange={e => {
                            if (e.target.value === 'rejected') setRejectingOrder(order._id);
                            else handleStatusUpdate(order._id, e.target.value);
                          }}
                          disabled={updatingId === order._id}
                          className="border border-border rounded px-3 py-1 bg-white disabled:bg-gray-100 disabled:cursor-not-allowed"
                        >
                          <option value="" disabled>Change status</option>
                          {options.map(opt => (
                            <option key={opt.key} value={opt.key}>{opt.label}</option>
                          ))}
                        </select>
                      ) : (
                        <span className="text-gray-400 text-xs">-</span>
                      )}
                    </td>
                    <td className="px-3 py-2">
                      <button className="text-xs bg-primary text-white px-2 py-1 rounded shadow hover:bg-primary-dark transition" onClick={() => setSelectedOrder(order)}>View</button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}
      {selectedOrder && (
        <OrderDetailModal order={selectedOrder} onClose={() => setSelectedOrder(null)} />
      )}
      {rejectingOrder && (
        <RejectModal
          loading={updatingId === rejectingOrder}
          onCancel={() => setRejectingOrder(null)}
          onSubmit={reason => handleStatusUpdate(rejectingOrder, 'rejected', reason)}
        />
      )}
    </div>
  );
} 