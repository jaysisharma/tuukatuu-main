import React, { useEffect, useState } from 'react';
import { api } from '../../api';
import Table from '../../components/Table';
import Loader from '../../components/Loader';
import Skeleton from '../../components/Skeleton';
import * as Dialog from '@radix-ui/react-dialog';

const STATUS_OPTIONS = ['pending', 'accepted', 'preparing', 'on_the_way', 'delivered', 'cancelled'];

export default function Orders() {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [selectedOrder, setSelectedOrder] = useState(null);
  const [detailsOpen, setDetailsOpen] = useState(false);
  const [statusLoading, setStatusLoading] = useState(false);

  const fetchOrders = async () => {
    setLoading(true);
    setError('');
    try {
      const data = await api.get('/orders');
      setOrders(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchOrders(); }, []);

  const columns = [
    { key: 'createdAt', title: 'Date', render: o => new Date(o.createdAt).toLocaleString() },
    { key: 'customerId', title: 'Customer', render: o => o.customerId?.name || '-' },
    { key: 'vendorId', title: 'Vendor', render: o => o.vendorId?.storeName || '-' },
    { key: 'items', title: 'Products', render: o => (
      <div className="flex flex-col gap-1">
        {o.items.slice(0, 2).map((item, i) => (
          <div key={i} className="flex items-center gap-2">
            {item.image && <img src={item.image} alt="" className="w-6 h-6 rounded object-cover" />}
            <span>{item.name}</span>
            <span className="text-xs text-gray-400">x{item.quantity}</span>
          </div>
        ))}
        {o.items.length > 2 && <span className="text-xs text-gray-400">+{o.items.length - 2} more</span>}
      </div>
    ) },
    { key: 'total', title: 'Total', render: o => `Rs ${o.total?.toFixed(2)}` },
    { key: 'status', title: 'Status', render: o => <span className="capitalize font-semibold text-primary">{o.status}</span> },
    { key: 'actions', title: 'Actions', render: o => (
      <button className="text-xs bg-primary text-white px-2 py-1 rounded" onClick={() => { setSelectedOrder(o); setDetailsOpen(true); }}>View</button>
    )},
  ];

  const data = orders.map(o => ({ ...o }));

  return (
    <div className="min-h-screen bg-bg flex items-start justify-center pt-10">
      <div className="max-w-6xl w-full bg-surface rounded-xl shadow-lg p-8 border border-border">
        <h1 className="text-3xl font-bold mb-6 text-primary">Orders</h1>
        <Table columns={columns} data={data} loading={loading} error={error} />
        <Dialog.Root open={detailsOpen} onOpenChange={setDetailsOpen}>
          <Dialog.Portal>
            <Dialog.Overlay className="fixed inset-0 bg-black/30 z-40" />
            <Dialog.Content className="fixed z-50 left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 bg-surface p-8 rounded-xl shadow-lg border border-border w-full max-w-2xl">
              {selectedOrder ? (
                <OrderDetails order={selectedOrder} />
              ) : <Loader />}
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

function OrderDetails({ order }) {
  return (
    <div>
      <h2 className="text-2xl font-bold mb-2 text-primary">Order Details</h2>
      <div className="mb-2 text-gray-700">Order ID: <span className="font-mono">{order._id}</span></div>
      <div className="mb-2 text-gray-700">Date: {new Date(order.createdAt).toLocaleString()}</div>
      <div className="mb-2 text-gray-700">Customer: <span className="font-semibold">{order.customerId?.name || '-'}</span></div>
      <div className="mb-2 text-gray-700">Vendor: <span className="font-semibold">{order.vendorId?.storeName || '-'}</span></div>
      <div className="mb-2 text-gray-700">Status: <span className="capitalize font-semibold text-primary">{order.status}</span></div>
      <div className="mb-4 text-gray-700">Total: <span className="font-semibold">Rs {order.total?.toFixed(2)}</span></div>
      <div className="mb-4">
        <h3 className="text-lg font-bold mb-2">Products</h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          {order.items.map((item, i) => (
            <div key={i} className="bg-white rounded-lg shadow border border-border p-4 flex gap-3 items-center">
              {item.image && <img src={item.image} alt={item.name} className="w-16 h-16 rounded object-cover" />}
              <div>
                <div className="font-bold">{item.name}</div>
                <div className="text-gray-600 text-sm">Qty: {item.quantity}</div>
                <div className="text-gray-600 text-sm">Price: Rs {item.price}</div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
} 