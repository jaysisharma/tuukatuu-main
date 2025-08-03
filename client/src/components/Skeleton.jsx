import React from 'react';
export default function Skeleton({ width = '100%', height = '1.5rem', className = '' }) {
  return (
    <div
      className={`bg-gray-200 rounded animate-pulse ${className}`}
      style={{ width, height }}
      aria-busy="true"
    />
  );
} 