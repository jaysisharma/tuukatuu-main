import React from 'react';
import { Link } from 'react-router-dom';
export default function NotFound() {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-gray-50">
      <h1 className="text-5xl font-bold text-primary mb-4">404</h1>
      <p className="text-lg text-gray-600 mb-6">Page not found.</p>
      <Link to="/login" className="text-primary underline">Go to Login</Link>
    </div>
  );
} 