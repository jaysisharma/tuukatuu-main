import React, { useEffect, useState } from 'react';
import { api } from '../../api';

export default function VendorDashboard() {
  const [stats, setStats] = useState(null);
  const [profile, setProfile] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    setLoading(true);
    Promise.all([
      api.get('/auth/me'),
      api.get('/orders/vendor/dashboard-stats'),
    ])
      .then(([profileData, statsData]) => {
        setProfile(profileData);
        setStats(statsData);
      })
      .catch(e => setError(e.message || 'Failed to load dashboard'))
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <div className="flex justify-center items-center min-h-screen"><div className="animate-spin h-10 w-10 border-4 border-primary border-t-transparent rounded-full"></div></div>;
  if (error) return <div className="flex justify-center items-center min-h-screen text-danger">{error}</div>;
  if (!stats || !profile) return null;

  return (
    <div className="p-0 md:p-6 bg-gray-50 min-h-screen">
      {/* Banner and Store Info */}
      <div className="relative mb-8">
        <img
          src={profile.storeBanner || '/placeholder.png'}
          alt="Store Banner"
          className="w-full h-40 md:h-56 object-cover rounded-t-xl border-b border-border bg-white"
          onError={e => e.target.src = '/placeholder.png'}
        />
        <div className="absolute left-1/2 -bottom-12 md:-bottom-16 transform -translate-x-1/2 flex flex-col items-center w-full">
          <img
            src={profile.storeImage || '/placeholder.png'}
            alt="Store"
            className="w-24 h-24 md:w-32 md:h-32 object-cover rounded-full border-4 border-surface shadow-lg bg-white"
            onError={e => e.target.src = '/placeholder.png'}
          />
        </div>
      </div>
      <div className="flex flex-col items-center mt-16 mb-8">
        <h1 className="text-3xl font-bold text-primary mb-1">{profile.storeName}</h1>
        <div className="text-gray-600 mb-2 text-center max-w-xl">{profile.storeDescription}</div>
        <div className="flex flex-wrap gap-2 justify-center">
          {(profile.storeTags || []).map((tag, i) => (
            <span key={i} className="px-3 py-1 rounded-full bg-primary/10 text-primary text-xs font-medium">{tag}</span>
          ))}
        </div>
      </div>
      {/* Performance Metrics */}
      <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-4 gap-6 mb-8 max-w-6xl mx-auto">
        <div className="bg-surface rounded-xl shadow p-5 border border-border flex flex-col items-center">
          <div className="text-xl font-bold text-primary mb-1">₹{Math.round(stats.avgOrderValue)}</div>
          <div className="text-gray-600 text-sm text-center">Avg. Order Value</div>
        </div>
        <div className="bg-surface rounded-xl shadow p-5 border border-border flex flex-col items-center">
          <div className="text-xl font-bold text-primary mb-1">{stats.ordersToday}</div>
          <div className="text-gray-600 text-sm text-center">Orders Today</div>
        </div>
        <div className="bg-surface rounded-xl shadow p-5 border border-border flex flex-col items-center">
          <div className="text-xl font-bold text-primary mb-1">{stats.ordersThisWeek}</div>
          <div className="text-gray-600 text-sm text-center">Orders This Week</div>
        </div>
        <div className="bg-surface rounded-xl shadow p-5 border border-border flex flex-col items-center">
          <div className="text-xl font-bold text-primary mb-1">{stats.newCustomers}</div>
          <div className="text-gray-600 text-sm text-center">New Customers</div>
        </div>
        <div className="bg-surface rounded-xl shadow p-5 border border-border flex flex-col items-center">
          <div className="text-xl font-bold text-primary mb-1">{stats.returningCustomers}</div>
          <div className="text-gray-600 text-sm text-center">Returning Customers</div>
        </div>
        <div className="bg-surface rounded-xl shadow p-5 border border-border flex flex-col items-center">
          <div className="text-xl font-bold text-primary mb-1">{stats.mostActiveTimeSlots.map(t => `${t.hour}:00`).join(', ')}</div>
          <div className="text-gray-600 text-sm text-center">Most Active Time Slots</div>
        </div>
        <div className="bg-surface rounded-xl shadow p-5 border border-border flex flex-col items-center">
          <div className="text-xl font-bold text-danger mb-1">{stats.lowStockProducts.length}</div>
          <div className="text-gray-600 text-sm text-center">Low Stock Products</div>
        </div>
      </div>
      {/* Recent Orders Table */}
      <div className="bg-surface rounded-xl shadow p-6 border border-border max-w-4xl mx-auto mb-8">
        <h2 className="text-xl font-semibold mb-4 text-primary">Recent Orders</h2>
        <div className="overflow-x-auto">
          <table className="min-w-full text-sm">
            <thead>
              <tr className="bg-gray-100">
                <th className="px-3 py-2 text-left">Order ID</th>
                <th className="px-3 py-2 text-left">Total</th>
                <th className="px-3 py-2 text-left">Status</th>
                <th className="px-3 py-2 text-left">Date</th>
              </tr>
            </thead>
            <tbody>
              {stats.recentOrders && stats.recentOrders.length === 0 && (
                <tr><td colSpan={4} className="text-center py-4 text-gray-400">No recent orders</td></tr>
              )}
              {stats.recentOrders && stats.recentOrders.map(order => (
                <tr key={order._id} className="border-b border-border hover:bg-gray-50">
                  <td className="px-3 py-2 font-mono text-primary underline cursor-pointer" onClick={() => window.location.href = `/vendor/orders?order=${order._id}`}>{order._id.slice(-6).toUpperCase()}</td>
                  <td className="px-3 py-2">Rs {order.total?.toLocaleString() || '-'}</td>
                  <td className={`px-3 py-2`}><span className={`px-2 py-1 rounded text-xs capitalize font-medium ${order.status === 'delivered' ? 'bg-green-200 text-green-800' : order.status === 'cancelled' ? 'bg-red-200 text-red-800' : order.status === 'rejected' ? 'bg-red-400 text-white' : 'bg-gray-300 text-gray-800'}`}>{order.status.replace(/_/g, ' ')}</span></td>
                  <td className="px-3 py-2">{new Date(order.createdAt).toLocaleString()}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
      {/* Low Stock Alerts */}
      {stats.lowStockProducts.length > 0 && (
        <div className="bg-danger/10 border-l-4 border-danger p-4 rounded-xl max-w-4xl mx-auto mb-8">
          <h2 className="text-lg font-semibold text-danger mb-2">Low Stock Alerts</h2>
          <ul className="list-disc pl-6 text-danger">
            {stats.lowStockProducts.map(p => (
              <li key={p._id}>{p.name} (Stock: {p.stock})</li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
} 