import React, { useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { login, logout } from '../store';
import { useNavigate } from 'react-router-dom';
// import * as Radix from '@radix-ui/react-*'; // Uncomment and use Radix UI components as needed

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const token = useSelector(state => state.auth.user?.token);

  const handleLogin = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      const res = await fetch('http://13.203.210.247:3000/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password }),
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.message || 'Login failed');
      // data: { token, user: { email, role, ... } }
      dispatch(login({ ...data.user, token: data.token }));
      setLoading(false);
      if (data.user.role === 'admin') navigate('/admin', { replace: true });
      else if (data.user.role === 'vendor') navigate('/vendor', { replace: true });
      else navigate('/', { replace: true });
    } catch (err) {
      setLoading(false);
      setError(err.message);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-bg">
      <form onSubmit={handleLogin} className="bg-surface p-8 rounded-xl shadow-lg w-full max-w-md space-y-6 border border-border">
        <h2 className="text-3xl font-bold text-center text-primary mb-2">Sign In</h2>
        {error && <div className="text-danger text-center font-medium">{error}</div>}
        <div className="space-y-2">
          <label className="block mb-1 font-medium text-gray-700">Email</label>
          <input
            type="email"
            className="w-full border border-border rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-primary bg-bg"
            value={email}
            onChange={e => setEmail(e.target.value)}
            required
            autoFocus
          />
        </div>
        <div className="space-y-2">
          <label className="block mb-1 font-medium text-gray-700">Password</label>
          <input
            type="password"
            className="w-full border border-border rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-primary bg-bg"
            value={password}
            onChange={e => setPassword(e.target.value)}
            required
          />
        </div>
        <button
          type="submit"
          className="w-full bg-primary text-white py-2 rounded font-semibold hover:bg-primary-dark transition disabled:opacity-60"
          disabled={loading}
        >
          {loading ? 'Signing in...' : 'Sign In'}
        </button>
      </form>
    </div>
  );
} 