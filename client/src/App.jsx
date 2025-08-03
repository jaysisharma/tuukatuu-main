import React, { useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate, useLocation, useNavigate } from 'react-router-dom';
import { useSelector } from 'react-redux';
import AdminLayout from './layouts/AdminLayout';
import VendorLayout from './layouts/VendorLayout';
import RiderLayout from './layouts/RiderLayout';
import AdminDashboard from './pages/admin/AdminDashboard';
import Users from './pages/admin/Users';
import Vendors from './pages/admin/Vendors';
import Riders from './pages/admin/Riders';
import RiderDetails from './pages/admin/RiderDetails';
import RiderAnalytics from './pages/admin/RiderAnalytics';
import Orders from './pages/admin/Orders';
import Products from './pages/admin/Products';
import Categories from './pages/admin/Categories';
import DailyEssentials from './pages/admin/DailyEssentials';
import FeaturedProducts from './pages/admin/FeaturedProducts';
import FeaturedCategories from './pages/admin/FeaturedCategories';
import Coupons from './pages/admin/Coupons';
import Banners from './pages/admin/Banners';
import Settings from './pages/admin/Settings';
import VendorDashboard from './pages/vendor/VendorDashboard';
import VendorProducts from './pages/vendor/Products';
import VendorOrders from './pages/vendor/Orders';
import VendorProfile from './pages/vendor/Profile';
import VendorSettings from './pages/vendor/Settings';
import RiderDashboard from './pages/rider/RiderDashboard';
import RiderProfile from './pages/rider/RiderProfile';
import RiderOrders from './pages/rider/RiderOrders';
import RiderEarnings from './pages/rider/RiderEarnings';
import RiderSettings from './pages/rider/RiderSettings';
import Login from './pages/Login';
import NotFound from './pages/NotFound';
import VendorDetailsPage from './pages/admin/VendorDetails';
import SalesAnalytics from './pages/admin/SalesAnalytics';
import AnalyticsAndSummary from './pages/vendor/AnalyticsAndSummary';
import './App.css';

function AppRoutes() {
  const user = useSelector(state => state.auth.user);
  const location = useLocation();
  const navigate = useNavigate();

  // Prevent logged-in users from accessing /login
  useEffect(() => {
    if (user && location.pathname === '/login') {
      if (user.role === 'admin') navigate('/admin', { replace: true });
      else if (user.role === 'vendor') navigate('/vendor', { replace: true });
      else if (user.role === 'rider') navigate('/rider', { replace: true });
    }
  }, [user, location, navigate]);

  return (
    <Routes>
      <Route path="/" element={<Navigate to={user ? (user.role === 'admin' ? '/admin' : user.role === 'vendor' ? '/vendor' : '/rider') : '/login'} replace />} />
      <Route path="/login" element={user ? <Navigate to={user.role === 'admin' ? '/admin' : user.role === 'vendor' ? '/vendor' : '/rider'} /> : <Login />} />
      <Route path="/admin" element={user && user.role === 'admin' ? <AdminLayout /> : <Navigate to="/login" /> }>
        <Route index element={<AdminDashboard />} />
        <Route path="users" element={<Users />} />
        <Route path="vendors" element={<Vendors />} />
        <Route path="vendors/:id" element={<VendorDetailsPage />} />
        <Route path="riders" element={<Riders />} />
        <Route path="riders/:riderId" element={<RiderDetails />} />
        <Route path="rider-analytics" element={<RiderAnalytics />} />
                          <Route path="orders" element={<Orders />} />
                  <Route path="products" element={<Products />} />
                  <Route path="categories" element={<Categories />} />
                  <Route path="daily-essentials" element={<DailyEssentials />} />
                  <Route path="featured-products" element={<FeaturedProducts />} />
                  <Route path="featured-categories" element={<FeaturedCategories />} />
                  <Route path="coupons" element={<Coupons />} />
                  <Route path="banners" element={<Banners />} />
        <Route path="settings" element={<Settings />} />
        <Route path="sales-analytics" element={<SalesAnalytics />} />
      </Route>
      <Route path="/vendor" element={user && user.role === 'vendor' ? <VendorLayout /> : <Navigate to="/login" /> }>
        <Route index element={<VendorDashboard />} />
        <Route path="products" element={<VendorProducts />} />
        <Route path="orders" element={<VendorOrders />} />
        <Route path="profile" element={<VendorProfile />} />
        <Route path="settings" element={<VendorSettings />} />
        <Route path="analytics" element={<AnalyticsAndSummary />} />
      </Route>
      <Route path="/rider" element={user && user.role === 'rider' ? <RiderLayout /> : <Navigate to="/login" /> }>
        <Route index element={<RiderDashboard />} />
        <Route path="orders" element={<RiderOrders />} />
        <Route path="earnings" element={<RiderEarnings />} />
        <Route path="profile" element={<RiderProfile />} />
        <Route path="settings" element={<RiderSettings />} />
      </Route>
      <Route path="*" element={<NotFound />} />
    </Routes>
  );
}

function App() {
  return (
    <Router>
      <AppRoutes />
    </Router>
  );
}

export default App;
