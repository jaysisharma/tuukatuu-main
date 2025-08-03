import React, { useState, useEffect } from 'react';
import { api } from '../../api';

export default function RiderEarnings() {
  const [earnings, setEarnings] = useState(null);
  const [loading, setLoading] = useState(true);
  const [period, setPeriod] = useState('month');
  const [rider, setRider] = useState(null);

  useEffect(() => {
    fetchRiderData();
    fetchEarnings();
  }, [period]);

  const fetchRiderData = async () => {
    try {
      const response = await api.get('/riders/profile');
      setRider(response.rider);
    } catch (error) {
      console.error('Error fetching rider data:', error);
    }
  };

  const fetchEarnings = async () => {
    try {
      const response = await api.get(`/riders/earnings?period=${period}`);
      setEarnings(response.earnings);
    } catch (error) {
      console.error('Error fetching earnings:', error);
    } finally {
      setLoading(false);
    }
  };

  const formatCurrency = (amount) => {
    return `₹${(amount || 0).toLocaleString()}`;
  };

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Earnings</h1>
        <p className="text-gray-600">Track your earnings and payment history</p>
      </div>

      {/* Period Selector */}
      <div className="bg-white p-4 rounded-lg shadow">
        <div className="flex items-center justify-between">
          <h2 className="text-lg font-medium text-gray-900">Earnings Period</h2>
          <select
            value={period}
            onChange={(e) => setPeriod(e.target.value)}
            className="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
          >
            <option value="today">Today</option>
            <option value="week">This Week</option>
            <option value="month">This Month</option>
            <option value="all">All Time</option>
          </select>
        </div>
      </div>

      {/* Earnings Overview */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-white p-6 rounded-lg shadow">
          <div className="flex items-center">
            <div className="p-2 bg-green-100 rounded-lg">
              <span className="text-green-600 text-xl">💰</span>
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Total Earnings</p>
              <p className="text-2xl font-bold text-gray-900">
                {formatCurrency(earnings?.total || 0)}
              </p>
            </div>
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow">
          <div className="flex items-center">
            <div className="p-2 bg-blue-100 rounded-lg">
              <span className="text-blue-600 text-xl">📦</span>
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Orders Completed</p>
              <p className="text-2xl font-bold text-gray-900">
                {earnings?.orders || 0}
              </p>
            </div>
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow">
          <div className="flex items-center">
            <div className="p-2 bg-yellow-100 rounded-lg">
              <span className="text-yellow-600 text-xl">📊</span>
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Average Per Order</p>
              <p className="text-2xl font-bold text-gray-900">
                {formatCurrency(earnings?.orders > 0 ? earnings.total / earnings.orders : 0)}
              </p>
            </div>
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow">
          <div className="flex items-center">
            <div className="p-2 bg-purple-100 rounded-lg">
              <span className="text-purple-600 text-xl">🎯</span>
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Target</p>
              <p className="text-2xl font-bold text-gray-900">
                {formatCurrency(earnings?.target || 0)}
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Detailed Breakdown */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Earnings by Day */}
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-medium text-gray-900 mb-4">Daily Breakdown</h3>
          {earnings?.dailyStats && earnings.dailyStats.length > 0 ? (
            <div className="space-y-3">
              {earnings.dailyStats.map((day, index) => (
                <div key={index} className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
                  <div>
                    <p className="font-medium text-gray-900">{day.date}</p>
                    <p className="text-sm text-gray-600">{day.orders} orders</p>
                  </div>
                  <div className="text-right">
                    <p className="font-medium text-green-600">{formatCurrency(day.earnings)}</p>
                    <p className="text-sm text-gray-600">
                      {day.orders > 0 ? formatCurrency(day.earnings / day.orders) : '₹0'} avg
                    </p>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <p className="text-gray-500 text-center py-4">No earnings data available for this period.</p>
          )}
        </div>

        {/* Payment History */}
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-medium text-gray-900 mb-4">Payment History</h3>
          {earnings?.payments && earnings.payments.length > 0 ? (
            <div className="space-y-3">
              {earnings.payments.slice(0, 5).map((payment, index) => (
                <div key={index} className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
                  <div>
                    <p className="font-medium text-gray-900">{payment.method}</p>
                    <p className="text-sm text-gray-600">{formatDate(payment.date)}</p>
                  </div>
                  <div className="text-right">
                    <p className="font-medium text-green-600">{formatCurrency(payment.amount)}</p>
                    <p className={`text-sm ${payment.status === 'completed' ? 'text-green-600' : 'text-yellow-600'}`}>
                      {payment.status}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <p className="text-gray-500 text-center py-4">No payment history available.</p>
          )}
        </div>
      </div>

      {/* Lifetime Stats */}
      {rider && (
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-medium text-gray-900 mb-4">Lifetime Statistics</h3>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div className="text-center">
              <p className="text-3xl font-bold text-primary">
                {formatCurrency(rider.earnings.totalEarnings)}
              </p>
              <p className="text-sm text-gray-600">Total Earnings</p>
            </div>
            <div className="text-center">
              <p className="text-3xl font-bold text-primary">
                {rider.performance.completedDeliveries}
              </p>
              <p className="text-sm text-gray-600">Total Deliveries</p>
            </div>
            <div className="text-center">
              <p className="text-3xl font-bold text-primary">
                {rider.performance.completedDeliveries > 0 
                  ? formatCurrency(rider.earnings.totalEarnings / rider.performance.completedDeliveries)
                  : '₹0'
                }
              </p>
              <p className="text-sm text-gray-600">Average Per Delivery</p>
            </div>
          </div>
        </div>
      )}

      {/* Bank Details */}
      {rider?.bankDetails && (
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-medium text-gray-900 mb-4">Bank Details</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700">Account Holder</label>
              <p className="mt-1 text-sm text-gray-900">{rider.bankDetails.accountHolderName}</p>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">Bank Name</label>
              <p className="mt-1 text-sm text-gray-900">{rider.bankDetails.bankName}</p>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">Account Number</label>
              <p className="mt-1 text-sm text-gray-900">{rider.bankDetails.accountNumber}</p>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">IFSC Code</label>
              <p className="mt-1 text-sm text-gray-900">{rider.bankDetails.ifscCode}</p>
            </div>
          </div>
        </div>
      )}

      {/* Pending Payouts */}
      {earnings?.pendingAmount > 0 && (
        <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
          <div className="flex items-center">
            <div className="flex-shrink-0">
              <span className="text-yellow-600 text-xl">⚠️</span>
            </div>
            <div className="ml-3">
              <h3 className="text-sm font-medium text-yellow-800">Pending Payout</h3>
              <p className="text-sm text-yellow-700 mt-1">
                You have {formatCurrency(earnings.pendingAmount)} pending for payout. 
                Payments are processed every Monday.
              </p>
            </div>
          </div>
        </div>
      )}
    </div>
  );
} 