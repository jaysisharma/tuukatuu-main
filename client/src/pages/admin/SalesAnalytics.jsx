import React, { useEffect, useState } from 'react';
import { api } from '../../api';
import { Line, Bar, Pie } from 'react-chartjs-2';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  ArcElement,
  Tooltip,
  Legend,
} from 'chart.js';

ChartJS.register(CategoryScale, LinearScale, PointElement, LineElement, BarElement, ArcElement, Tooltip, Legend);

export default function SalesAnalytics() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    setLoading(true);
    api.get('/admin/sales-analytics')
      .then(setData)
      .catch(e => setError(e.message || 'Failed to load analytics'))
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <div className="flex justify-center items-center min-h-screen"><div className="animate-spin h-10 w-10 border-4 border-primary border-t-transparent rounded-full"></div></div>;
  if (error) return <div className="flex justify-center items-center min-h-screen text-danger">{error}</div>;
  if (!data) return null;

  // Prepare chart data
  const salesByDayLabels = data.salesByDay.map(d => new Date(d.date).toLocaleDateString());
  const salesByDayData = data.salesByDay.map(d => d.total);
  const salesByMonthLabels = data.salesByMonth.map(m => m.month);
  const salesByMonthData = data.salesByMonth.map(m => m.total);
  const statusLabels = data.statusDistribution.map(s => s._id);
  const statusData = data.statusDistribution.map(s => s.count);
  const categoryLabels = data.salesByCategory.map(c => c._id || 'Uncategorized');
  const categoryData = data.salesByCategory.map(c => c.total);
  const hourLabels = Array.from({length: 24}, (_, i) => `${i}:00`);
  const hourData = Array(24).fill(0);
  data.salesByHour.forEach(h => { if (h._id !== null) hourData[h._id] = h.total; });

  return (
    <div className="p-6">
      <h1 className="text-3xl font-bold mb-6 text-primary">Sales & Analytics</h1>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div className="bg-surface rounded-xl shadow p-5 border border-border flex flex-col items-center">
          <div className="text-2xl font-bold text-primary mb-1">Rs {data.totalSales.toLocaleString()}</div>
          <div className="text-gray-600 text-sm text-center">Total Sales</div>
        </div>
        <div className="bg-surface rounded-xl shadow p-5 border border-border flex flex-col items-center">
          <div className="text-2xl font-bold text-primary mb-1">{data.totalOrders}</div>
          <div className="text-gray-600 text-sm text-center">Total Orders</div>
        </div>
        <div className="bg-surface rounded-xl shadow p-5 border border-border flex flex-col items-center">
          <div className="text-2xl font-bold text-primary mb-1">Rs {data.avgOrderValue.toLocaleString(undefined, {maximumFractionDigits:0})}</div>
          <div className="text-gray-600 text-sm text-center">Avg Order Value</div>
        </div>
      </div>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mb-8">
        <div className="bg-surface rounded-xl shadow p-6 border border-border">
          <h2 className="text-lg font-semibold mb-2 text-primary">Sales by Day (Last 30 Days)</h2>
          <Line data={{
            labels: salesByDayLabels,
            datasets: [{ label: 'Sales', data: salesByDayData, borderColor: '#2563eb', backgroundColor: 'rgba(37,99,235,0.1)' }],
          }} options={{ responsive: true, plugins: { legend: { display: false } } }} />
        </div>
        <div className="bg-surface rounded-xl shadow p-6 border border-border">
          <h2 className="text-lg font-semibold mb-2 text-primary">Sales by Month (Last 12 Months)</h2>
          <Bar data={{
            labels: salesByMonthLabels,
            datasets: [{ label: 'Sales', data: salesByMonthData, backgroundColor: '#f59e42' }],
          }} options={{ responsive: true, plugins: { legend: { display: false } } }} />
        </div>
        <div className="bg-surface rounded-xl shadow p-6 border border-border">
          <h2 className="text-lg font-semibold mb-2 text-primary">Order Status Distribution</h2>
          <Pie data={{
            labels: statusLabels,
            datasets: [{ data: statusData, backgroundColor: ['#22c55e','#f59e42','#2563eb','#ef4444','#facc15','#a3a3a3'] }],
          }} options={{ responsive: true }} />
        </div>
        <div className="bg-surface rounded-xl shadow p-6 border border-border">
          <h2 className="text-lg font-semibold mb-2 text-primary">Sales by Category</h2>
          <Bar data={{
            labels: categoryLabels,
            datasets: [{ label: 'Sales', data: categoryData, backgroundColor: '#10b981' }],
          }} options={{ responsive: true, plugins: { legend: { display: false } } }} />
        </div>
        <div className="bg-surface rounded-xl shadow p-6 border border-border col-span-1 md:col-span-2">
          <h2 className="text-lg font-semibold mb-2 text-primary">Sales by Hour</h2>
          <Bar data={{
            labels: hourLabels,
            datasets: [{ label: 'Sales', data: hourData, backgroundColor: '#2563eb' }],
          }} options={{ responsive: true, plugins: { legend: { display: false } } }} />
        </div>
      </div>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mb-8">
        <div className="bg-surface rounded-xl shadow p-6 border border-border">
          <h2 className="text-lg font-semibold mb-2 text-primary">Top 5 Vendors by Sales</h2>
          <table className="min-w-full text-sm">
            <thead><tr className="bg-gray-100"><th className="px-3 py-2 text-left">Vendor</th><th className="px-3 py-2 text-left">Email</th><th className="px-3 py-2 text-left">Sales</th><th className="px-3 py-2 text-left">Orders</th></tr></thead>
            <tbody>
              {data.topVendors.map(v => (
                <tr key={v.vendor?._id || v._id} className="border-b border-border">
                  <td className="px-3 py-2">{v.vendor?.storeName || '-'}</td>
                  <td className="px-3 py-2">{v.vendor?.email || '-'}</td>
                  <td className="px-3 py-2">Rs {v.total?.toLocaleString() || 0}</td>
                  <td className="px-3 py-2">{v.orderCount}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <div className="bg-surface rounded-xl shadow p-6 border border-border">
          <h2 className="text-lg font-semibold mb-2 text-primary">Top 5 Products by Sales</h2>
          <table className="min-w-full text-sm">
            <thead><tr className="bg-gray-100"><th className="px-3 py-2 text-left">Product</th><th className="px-3 py-2 text-left">Image</th><th className="px-3 py-2 text-left">Sales</th><th className="px-3 py-2 text-left">Qty</th></tr></thead>
            <tbody>
              {data.topProducts.map(p => (
                <tr key={p.product?._id || p._id} className="border-b border-border">
                  <td className="px-3 py-2">{p.product?.name || '-'}</td>
                  <td className="px-3 py-2">{p.product?.image && <img src={p.product.image} alt="" className="w-10 h-10 object-cover rounded" />}</td>
                  <td className="px-3 py-2">Rs {p.total?.toLocaleString() || 0}</td>
                  <td className="px-3 py-2">{p.quantity}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
} 