import React from 'react';
import Skeleton from './Skeleton';
import Loader from './Loader';
// import * as RadixTable from '@radix-ui/react-table'; // Uncomment if using Radix Table

export default function Table({ columns, data, loading, error }) {
  if (loading) {
    return (
      <div className="overflow-x-auto rounded-lg border border-border bg-surface">
        <table className="min-w-full divide-y divide-border">
          <thead className="bg-gray-100">
            <tr>
              {columns.map(col => (
                <th key={col.key} className="px-4 py-2 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">{col.title}</th>
              ))}
              <th className="px-4 py-2"></th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border">
            {[...Array(5)].map((_, i) => (
              <tr key={i}>
                {columns.map((col, j) => (
                  <td key={j} className="px-4 py-2"><Skeleton /></td>
                ))}
                <td className="px-4 py-2"><Skeleton width="60px" /></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    );
  }
  if (error) return <div className="text-danger text-center py-8">{error}</div>;
  return (
    <div className="overflow-x-auto rounded-lg border border-border bg-surface">
      <table className="min-w-full divide-y divide-border">
        <thead className="bg-gray-100">
          <tr>
            {columns.map(col => (
              <th key={col.key} className="px-4 py-2 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">{col.title}</th>
            ))}
            <th className="px-4 py-2"></th>
          </tr>
        </thead>
        <tbody className="divide-y divide-border">
          {data.length === 0 ? (
            <tr><td colSpan={columns.length + 1} className="text-center py-8 text-gray-400">No data</td></tr>
          ) : data.map(row => (
            <tr key={row._id || row.id} className="hover:bg-gray-50">
              {columns.map(col => (
                <td key={col.key} className="px-4 py-2 text-sm">{col.render ? col.render(row) : row[col.key]}</td>
              ))}
              <td className="px-4 py-2 text-right">{row.actions}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
} 