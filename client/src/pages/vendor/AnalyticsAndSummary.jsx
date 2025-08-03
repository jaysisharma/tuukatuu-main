import React, { useEffect, useState } from 'react';
import { api } from '../../api';
import { Line } from 'react-chartjs-2';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  Tooltip,
  Legend,
} from 'chart.js';

ChartJS.register(CategoryScale, LinearScale, PointElement, LineElement, BarElement, Tooltip, Legend);

export default function AnalyticsAndSummary() {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    setLoading(true);
    api.get('/orders/vendor/dashboard-stats')
      .then(setStats)
      .catch(e => setError(e.message || 'Failed to load analytics'))
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <div className="flex justify-center items-center min-h-screen"><div className="animate-spin h-10 w-10 border-4 border-primary border-t-transparent rounded-full"></div></div>;
  if (error) return <div className="flex justify-center items-center min-h-screen text-danger">{error}</div>;
  if (!stats) return null;

  // Sales Trends Chart Data
  const salesTrendsLabels = stats.salesTrends.map(t => new Date(t.date).toLocaleDateString('en-GB', { day: '2-digit', month: 'short' }));
  const salesTrendsData = stats.salesTrends.map(t => t.total);
  const ordersTrendsData = stats.salesTrends.map(t => t.orders);

  return (
    <div className="p-6 bg-gray-50 min-h-screen">
      <h1 className="text-3xl font-bold text-primary mb-8">Analytics & Summary</h1>
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
      {/* Sales Trends Chart */}
      <div className="bg-surface rounded-xl shadow p-6 border border-border max-w-4xl mx-auto mb-8">
        <h2 className="text-lg font-semibold mb-4 text-primary">Sales Trends (Last 14 Days)</h2>
        <Line
          data={{
            labels: salesTrendsLabels,
            datasets: [
              { label: 'Sales', data: salesTrendsData, borderColor: '#2563eb', backgroundColor: 'rgba(37,99,235,0.1)', tension: 0.4 },
              { label: 'Orders', data: ordersTrendsData, borderColor: '#f59e42', backgroundColor: 'rgba(245,158,66,0.1)', tension: 0.4 },
            ],
          }}
          options={{ responsive: true, plugins: { legend: { position: 'top' } } }}
        />
      </div>
      {/* Top Products Table */}
      <div className="bg-surface rounded-xl shadow p-6 border border-border max-w-4xl mx-auto mb-8">
        <h2 className="text-lg font-semibold mb-4 text-primary">Top Products</h2>
        <div className="overflow-x-auto">
          <table className="min-w-full text-sm">
            <thead>
              <tr className="bg-gray-100">
                <th className="px-3 py-2 text-left">Product</th>
                <th className="px-3 py-2 text-left">Image</th>
                <th className="px-3 py-2 text-left">Orders</th>
                <th className="px-3 py-2 text-left">Revenue</th>
              </tr>
            </thead>
            <tbody>
              {stats.topProducts.length === 0 && (
                <tr><td colSpan={4} className="text-center py-4 text-gray-400">No data</td></tr>
              )}
              {stats.topProducts.map(p => (
                <tr key={p.id} className="border-b border-border">
                  <td className="px-3 py-2">{p.name}</td>
                  <td className="px-3 py-2">{p.image ? <img src={p.image} alt="" className="w-10 h-10 object-cover rounded" onError={e => e.target.src = '/placeholder.png'} /> : <div className="w-10 h-10 bg-gray-200 flex items-center justify-center rounded">🛒</div>}</td>
                  <td className="px-3 py-2">{p.orders}</td>
                  <td className="px-3 py-2">₹{p.revenue.toLocaleString()}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
      {/* Payouts Summary */}
      <div className="bg-surface rounded-xl shadow p-6 border border-border max-w-4xl mx-auto mb-8">
        <h2 className="text-lg font-semibold mb-4 text-primary">Payouts Summary (Last 4 Weeks)</h2>
        <div className="overflow-x-auto">
          <table className="min-w-full text-sm">
            <thead>
              <tr className="bg-gray-100">
                <th className="px-3 py-2 text-left">Week</th>
                <th className="px-3 py-2 text-left">Orders</th>
                <th className="px-3 py-2 text-left">Earnings</th>
              </tr>
            </thead>
            <tbody>
              {stats.payoutsSummary.length === 0 && (
                <tr><td colSpan={3} className="text-center py-4 text-gray-400">No data</td></tr>
              )}
              {stats.payoutsSummary.map((p, i) => (
                <tr key={i} className="border-b border-border">
                  <td className="px-3 py-2">{p.week}</td>
                  <td className="px-3 py-2">{p.orders}</td>
                  <td className="px-3 py-2">₹{p.earnings.toLocaleString()}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
      {/* Feedback & Ratings */}
      <div className="bg-surface rounded-xl shadow p-6 border border-border max-w-4xl mx-auto mb-8">
        <h2 className="text-lg font-semibold mb-4 text-primary">Feedback & Ratings</h2>
        <div className="flex items-center gap-4 mb-4">
          <span className="text-2xl">⭐</span>
          <span className="text-2xl font-bold text-primary">{stats.avgRating}</span>
          <span className="text-gray-500">Avg. Rating</span>
        </div>
        <div className="space-y-2">
          {stats.recentReviews.map((r, i) => (
            <div key={i} className="flex items-center gap-3 bg-gray-50 rounded p-3 border border-border">
              <span className="text-lg">{'⭐'.repeat(r.rating)}</span>
              <span className="text-gray-700 flex-1">{r.comment}</span>
              <span className="text-xs text-gray-400">{new Date(r.date).toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' })}</span>
            </div>
          ))}
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