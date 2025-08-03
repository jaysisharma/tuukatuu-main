import React, { useEffect, useState } from 'react';
import { api } from '../../api';

export default function AdminDashboard() {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    setLoading(true);
    api.get('/admin/dashboard')
      .then(setStats)
      .catch(e => setError(e.message || 'Failed to load dashboard'))
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <div className="flex justify-center items-center min-h-screen"><div className="animate-spin h-10 w-10 border-4 border-primary border-t-transparent rounded-full"></div></div>;
  if (error) return <div className="flex justify-center items-center min-h-screen text-danger">{error}</div>;
  if (!stats) return null;

  const cards = [
    { label: 'Total Users', value: stats.totalUsers },
    { label: 'Vendors', value: stats.totalVendors },
    { label: 'Active Vendors', value: stats.activeVendors },
    { label: 'Featured Vendors', value: stats.featuredVendors },
    { label: 'Customers', value: stats.totalCustomers },
    { label: 'Active Customers', value: stats.activeCustomers },
    { label: 'Riders', value: stats.totalRiders },
    { label: 'Products', value: stats.totalProducts },
    { label: 'Orders', value: stats.totalOrders },
    { label: 'Coupons', value: stats.totalCoupons },
    { label: 'Banners', value: stats.totalBanners },
    { label: 'Total Sales', value: `Rs ${stats.totalSales.toLocaleString()}` },
  ];

  return (
    <div className="p-6">
      <h1 className="text-3xl font-bold mb-6 text-primary">Admin Dashboard</h1>
      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6 mb-8">
        {cards.map(card => (
          <div key={card.label} className="bg-surface rounded-xl shadow p-5 border border-border flex flex-col items-center">
            <div className="text-2xl font-bold text-primary mb-1">{card.value}</div>
            <div className="text-gray-600 text-sm text-center">{card.label}</div>
          </div>
        ))}
      </div>
      <div className="bg-surface rounded-xl shadow p-6 border border-border">
        <h2 className="text-xl font-semibold mb-4 text-primary">Recent Orders</h2>
        <div className="overflow-x-auto">
          <table className="min-w-full text-sm">
            <thead>
              <tr className="bg-gray-100">
                <th className="px-3 py-2 text-left">Order ID</th>
                <th className="px-3 py-2 text-left">Customer</th>
                <th className="px-3 py-2 text-left">Vendor</th>
                <th className="px-3 py-2 text-left">Total</th>
                <th className="px-3 py-2 text-left">Status</th>
                <th className="px-3 py-2 text-left">Date</th>
              </tr>
            </thead>
            <tbody>
              {stats.recentOrders.length === 0 && (
                <tr><td colSpan={6} className="text-center py-4 text-gray-400">No recent orders</td></tr>
              )}
              {stats.recentOrders.map(order => (
                <tr key={order._id} className="border-b border-border hover:bg-gray-50">
                  <td className="px-3 py-2 font-mono">{order._id.slice(-6).toUpperCase()}</td>
                  <td className="px-3 py-2">{order.customerId?.name || '-'}</td>
                  <td className="px-3 py-2">{order.vendorId?.storeName || '-'}</td>
                  <td className="px-3 py-2">Rs {order.total?.toLocaleString() || '-'}</td>
                  <td className="px-3 py-2">
                    <span className={`px-2 py-1 rounded text-xs ${order.status === 'delivered' ? 'bg-success text-white' : order.status === 'cancelled' ? 'bg-danger text-white' : 'bg-warning text-gray-800'}`}>{order.status}</span>
                  </td>
                  <td className="px-3 py-2">{new Date(order.createdAt).toLocaleString()}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
} 