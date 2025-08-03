import React from 'react';
import { Outlet, NavLink, useNavigate } from 'react-router-dom';
import { useDispatch } from 'react-redux';
import { logout } from '../store';

export default function AdminLayout() {
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
        <div className="h-16 flex items-center justify-center font-bold text-xl text-primary border-b border-border">Admin Panel</div>
        <nav className="flex-1 py-4">
          <ul className="space-y-2">
            <li><NavLink to="/admin" end className={({isActive}) => isActive ? 'block px-6 py-2 bg-primary text-white rounded' : 'block px-6 py-2 text-gray-700 hover:bg-gray-100 rounded'}>Dashboard</NavLink></li>
            <li><NavLink to="/admin/users" className={({isActive}) => isActive ? 'block px-6 py-2 bg-primary text-white rounded' : 'block px-6 py-2 text-gray-700 hover:bg-gray-100 rounded'}>Users</NavLink></li>
            <li><NavLink to="/admin/vendors" className={({isActive}) => isActive ? 'block px-6 py-2 bg-primary text-white rounded' : 'block px-6 py-2 text-gray-700 hover:bg-gray-100 rounded'}>Vendors</NavLink></li>
            <li><NavLink to="/admin/riders" className={({isActive}) => isActive ? 'block px-6 py-2 bg-primary text-white rounded' : 'block px-6 py-2 text-gray-700 hover:bg-gray-100 rounded'}>Riders</NavLink></li>
            <li><NavLink to="/admin/rider-analytics" className={({isActive}) => isActive ? 'block px-6 py-2 bg-primary text-white rounded' : 'block px-6 py-2 text-gray-700 hover:bg-gray-100 rounded'}>Rider Analytics</NavLink></li>
                                  <li><NavLink to="/admin/orders" className={({isActive}) => isActive ? 'block px-6 py-2 bg-primary text-white rounded' : 'block px-6 py-2 text-gray-700 hover:bg-gray-100 rounded'}>Orders</NavLink></li>
                      <li><NavLink to="/admin/products" className={({isActive}) => isActive ? 'block px-6 py-2 bg-primary text-white rounded' : 'block px-6 py-2 text-gray-700 hover:bg-gray-100 rounded'}>Products</NavLink></li>
                      <li><NavLink to="/admin/categories" className={({isActive}) => isActive ? 'block px-6 py-2 bg-primary text-white rounded' : 'block px-6 py-2 text-gray-700 hover:bg-gray-100 rounded'}>Categories</NavLink></li>
                      <li><NavLink to="/admin/daily-essentials" className={({isActive}) => isActive ? 'block px-6 py-2 bg-primary text-white rounded' : 'block px-6 py-2 text-gray-700 hover:bg-gray-100 rounded'}>Daily Essentials</NavLink></li>
                      <li><NavLink to="/admin/featured-products" className={({isActive}) => isActive ? 'block px-6 py-2 bg-primary text-white rounded' : 'block px-6 py-2 text-gray-700 hover:bg-gray-100 rounded'}>Featured Products</NavLink></li>
                      <li><NavLink to="/admin/featured-categories" className={({isActive}) => isActive ? 'block px-6 py-2 bg-primary text-white rounded' : 'block px-6 py-2 text-gray-700 hover:bg-gray-100 rounded'}>Featured Categories</NavLink></li>
                      <li><NavLink to="/admin/coupons" className={({isActive}) => isActive ? 'block px-6 py-2 bg-primary text-white rounded' : 'block px-6 py-2 text-gray-700 hover:bg-gray-100 rounded'}>Coupons</NavLink></li>
                      <li><NavLink to="/admin/banners" className={({isActive}) => isActive ? 'block px-6 py-2 bg-primary text-white rounded' : 'block px-6 py-2 text-gray-700 hover:bg-gray-100 rounded'}>Banners</NavLink></li>
            <li><NavLink to="/admin/sales-analytics" className={({isActive}) => isActive ? 'block px-6 py-2 bg-primary text-white rounded' : 'block px-6 py-2 text-gray-700 hover:bg-gray-100 rounded'}>Sales & Analytics</NavLink></li>
            <li><NavLink to="/admin/settings" className={({isActive}) => isActive ? 'block px-6 py-2 bg-primary text-white rounded' : 'block px-6 py-2 text-gray-700 hover:bg-gray-100 rounded'}>Settings</NavLink></li>
          </ul>
        </nav>
      </aside>
      {/* Main Content */}
      <div className="flex-1 flex flex-col">
        {/* Topbar */}
        <header className="h-16 bg-surface border-b border-border flex items-center px-6 justify-between shadow-sm">
          <div className="font-semibold text-lg">Welcome, Admin</div>
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