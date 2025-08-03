import React from 'react';
import { Outlet, NavLink, useNavigate } from 'react-router-dom';
import { useDispatch } from 'react-redux';
import { logout } from '../store';

export default function VendorLayout() {
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const handleLogout = () => {
    dispatch(logout());
    navigate('/login', { replace: true });
  };
  return (
    <div className="flex min-h-screen bg-bg">
      {/* Sidebar */}
      <aside className="w-64 bg-surface border-r border-border flex flex-col shadow-md">
        <div className="h-16 flex items-center justify-center font-bold text-xl text-primary border-b border-border">Vendor Panel</div>
        <nav className="flex-1 py-4">
          <ul className="space-y-2">
            <li><NavLink to="/vendor" end className={({isActive}) => isActive ? 'block px-6 py-2 bg-primary text-white rounded' : 'block px-6 py-2 text-gray-700 hover:bg-gray-100 rounded'}>Dashboard</NavLink></li>
            <li><NavLink to="/vendor/products" className={({isActive}) => isActive ? 'block px-6 py-2 bg-primary text-white rounded' : 'block px-6 py-2 text-gray-700 hover:bg-gray-100 rounded'}>My Products</NavLink></li>
            <li><NavLink to="/vendor/orders" className={({isActive}) => isActive ? 'block px-6 py-2 bg-primary text-white rounded' : 'block px-6 py-2 text-gray-700 hover:bg-gray-100 rounded'}>Orders</NavLink></li>
            <li><NavLink to="/vendor/profile" className={({isActive}) => isActive ? 'block px-6 py-2 bg-primary text-white rounded' : 'block px-6 py-2 text-gray-700 hover:bg-gray-100 rounded'}>Store Profile</NavLink></li>
            <li><NavLink to="/vendor/settings" className={({isActive}) => isActive ? 'block px-6 py-2 bg-primary text-white rounded' : 'block px-6 py-2 text-gray-700 hover:bg-gray-100 rounded'}>Settings</NavLink></li>
            <li><NavLink to="/vendor/analytics" className={({isActive}) => isActive ? 'block px-6 py-2 bg-primary text-white rounded' : 'block px-6 py-2 text-gray-700 hover:bg-gray-100 rounded'}>Analytics & Summary</NavLink></li>
          </ul>
        </nav>
      </aside>
      {/* Main Content */}
      <div className="flex-1 flex flex-col">
        {/* Topbar */}
        <header className="h-16 bg-surface border-b border-border flex items-center px-6 justify-between shadow-sm">
          <div className="font-semibold text-lg">Welcome, Vendor</div>
          <div className="flex items-center gap-4">
            {/* Add profile/avatar, notifications, etc. */}
            <button onClick={handleLogout} className="rounded-full bg-primary text-white px-4 py-1 hover:bg-primary-dark transition">Logout</button>
          </div>
        </header>
        <main className="flex-1 p-6">
          <Outlet />
        </main>
      </div>
    </div>
  );
} 