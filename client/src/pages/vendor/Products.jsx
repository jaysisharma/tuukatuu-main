import React, { useEffect, useState } from 'react';
import { api } from '../../api';

function Toast({ message, type, onClose }) {
  useEffect(() => {
    if (!message) return;
    const timer = setTimeout(onClose, 2500);
    return () => clearTimeout(timer);
  }, [message, onClose]);
  if (!message) return null;
  return (
    <div className={`fixed top-6 right-6 z-50 px-6 py-3 rounded shadow-lg text-white font-semibold ${type === 'error' ? 'bg-danger' : 'bg-success'}`}>{message}</div>
  );
}

function ProductForm({ initial, onSave, onCancel }) {
  const [form, setForm] = useState(initial || {
    name: '', price: '', stock: '', imageUrl: '', category: '', description: '', unit: '', deliveryTime: '', deliveryFee: '', isAvailable: true
  });
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');
  const isEdit = !!initial;

  const handleChange = e => {
    const { name, value, type, checked } = e.target;
    setForm(f => ({ ...f, [name]: type === 'checkbox' ? checked : value }));
  };

  const handleSubmit = async e => {
    e.preventDefault();
    setSaving(true);
    setError('');
    try {
      if (isEdit) {
        await api.put(`/products/${initial._id}`, form);
      } else {
        await api.post('/products', form);
      }
      onSave();
    } catch (err) {
      setError(err.message);
    } finally {
      setSaving(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      {error && <div className="text-danger mb-2">{error}</div>}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block mb-1 font-medium">Name</label>
          <input name="name" value={form.name} onChange={handleChange} className="w-full border border-border rounded px-3 py-2" required />
        </div>
        <div>
          <label className="block mb-1 font-medium">Price</label>
          <input name="price" value={form.price} onChange={handleChange} className="w-full border border-border rounded px-3 py-2" required type="number" min="0" />
        </div>
        <div>
          <label className="block mb-1 font-medium">Stock</label>
          <input name="stock" value={form.stock} onChange={handleChange} className="w-full border border-border rounded px-3 py-2" required type="number" min="0" />
        </div>
        <div>
          <label className="block mb-1 font-medium">Category</label>
          <input name="category" value={form.category} onChange={handleChange} className="w-full border border-border rounded px-3 py-2" />
        </div>
        <div>
          <label className="block mb-1 font-medium">Image URL</label>
          <input name="imageUrl" value={form.imageUrl} onChange={handleChange} className="w-full border border-border rounded px-3 py-2" required />
        </div>
        <div>
          <label className="block mb-1 font-medium">Unit</label>
          <input name="unit" value={form.unit} onChange={handleChange} className="w-full border border-border rounded px-3 py-2" />
        </div>
        <div>
          <label className="block mb-1 font-medium">Delivery Time</label>
          <input name="deliveryTime" value={form.deliveryTime} onChange={handleChange} className="w-full border border-border rounded px-3 py-2" />
        </div>
        <div>
          <label className="block mb-1 font-medium">Delivery Fee</label>
          <input name="deliveryFee" value={form.deliveryFee} onChange={handleChange} className="w-full border border-border rounded px-3 py-2" type="number" min="0" />
        </div>
        <div className="md:col-span-2">
          <label className="block mb-1 font-medium">Description</label>
          <textarea name="description" value={form.description} onChange={handleChange} className="w-full border border-border rounded px-3 py-2" rows={2} />
        </div>
        <div className="flex items-center gap-2 md:col-span-2">
          <input name="isAvailable" type="checkbox" checked={form.isAvailable} onChange={handleChange} id="isAvailable" />
          <label htmlFor="isAvailable">Available</label>
        </div>
      </div>
      <div className="flex gap-2 justify-end mt-4">
        <button type="button" className="px-4 py-2 rounded bg-gray-200 hover:bg-gray-300" onClick={onCancel} disabled={saving}>Cancel</button>
        <button type="submit" className="px-4 py-2 rounded bg-primary text-white hover:bg-primary-dark" disabled={saving}>{saving ? (isEdit ? 'Saving...' : 'Creating...') : (isEdit ? 'Save' : 'Create')}</button>
      </div>
    </form>
  );
}

function ProductDetailModal({ product, onClose }) {
  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-surface rounded-2xl shadow-2xl p-8 border border-border w-full max-w-lg relative animate-fadeIn">
        <button className="absolute top-2 right-2 text-gray-400 hover:text-danger text-2xl" onClick={onClose}>&times;</button>
        <div className="flex flex-col items-center mb-4">
          <img src={product.imageUrl || '/placeholder.png'} alt="Product" className="w-32 h-32 object-cover rounded-xl border border-border mb-2" onError={e => e.target.src = '/placeholder.png'} />
          <h2 className="text-2xl font-bold text-primary mb-1">{product.name}</h2>
          <div className="text-gray-600 mb-2">{product.category}</div>
          <div className="text-lg font-semibold mb-2">₹{product.price}</div>
          <div className="text-xs text-gray-500 mb-2">{product.unit} • {product.deliveryTime} • Delivery Fee: ₹{product.deliveryFee}</div>
          <div className="text-sm text-gray-700 mb-2 text-center">{product.description}</div>
          <div className="flex gap-2 mt-2">
            <span className={`px-3 py-1 rounded-full text-xs font-semibold ${product.isAvailable ? 'bg-green-200 text-green-800' : 'bg-red-200 text-red-800'}`}>{product.isAvailable ? 'Available' : 'Unavailable'}</span>
            <span className="px-3 py-1 rounded-full text-xs bg-gray-100 text-gray-700">Stock: {product.stock ?? '-'}</span>
          </div>
        </div>
      </div>
    </div>
  );
}

export default function Products() {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [showForm, setShowForm] = useState(false);
  const [editProduct, setEditProduct] = useState(null);
  const [success, setSuccess] = useState('');
  const [detailProduct, setDetailProduct] = useState(null);

  const fetchProducts = () => {
    setLoading(true);
    api.get('/products/my')
      .then(setProducts)
      .catch(e => setError(e.message || 'Failed to load products'))
      .finally(() => setLoading(false));
  };

  useEffect(() => { fetchProducts(); }, []);

  const handleDelete = async (id) => {
    if (!window.confirm('Delete this product?')) return;
    try {
      await api.del(`/products/${id}`);
      setSuccess('Product deleted');
      fetchProducts();
    } catch (err) {
      setError(err.message);
    }
  };

  const handleStatusChange = async (product) => {
    try {
      await api.put(`/products/${product._id}`, { isAvailable: !product.isAvailable });
      setSuccess(`Product marked as ${!product.isAvailable ? 'available' : 'unavailable'}`);
      fetchProducts();
    } catch (err) {
      setError(err.message);
    }
  };

  return (
    <div className="p-6">
      <Toast message={success || error} type={error ? 'error' : 'success'} onClose={() => { setSuccess(''); setError(''); }} />
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold text-primary">My Products</h1>
        <button className="bg-primary text-white px-4 py-2 rounded" onClick={() => { setEditProduct(null); setShowForm(true); }}>Add Product</button>
      </div>
      {loading ? (
        <div className="flex justify-center items-center py-12"><div className="animate-spin h-8 w-8 border-4 border-primary border-t-transparent rounded-full"></div></div>
      ) : (
        <div className="overflow-x-auto">
          <table className="min-w-full text-sm">
            <thead>
              <tr className="bg-gray-100">
                <th className="px-3 py-2 text-left">Image</th>
                <th className="px-3 py-2 text-left">Name</th>
                <th className="px-3 py-2 text-left">Price</th>
                <th className="px-3 py-2 text-left">Stock</th>
                <th className="px-3 py-2 text-left">Category</th>
                <th className="px-3 py-2 text-left">Status</th>
                <th className="px-3 py-2 text-left">Actions</th>
              </tr>
            </thead>
            <tbody>
              {products.length === 0 && (
                <tr><td colSpan={7} className="text-center py-4 text-gray-400">No products</td></tr>
              )}
              {products.map(p => (
                <tr key={p._id} className="border-b border-border">
                  <td className="px-3 py-2 cursor-pointer" onClick={() => setDetailProduct(p)}>{p.imageUrl ? <img src={p.imageUrl} alt="" className="w-12 h-12 object-cover rounded" onError={e => e.target.src = '/placeholder.png'} /> : <div className="w-12 h-12 bg-gray-200 flex items-center justify-center rounded">🛒</div>}</td>
                  <td className="px-3 py-2 cursor-pointer" onClick={() => setDetailProduct(p)}>{p.name}</td>
                  <td className="px-3 py-2">₹{p.price}</td>
                  <td className="px-3 py-2">{p.stock ?? '-'}</td>
                  <td className="px-3 py-2">{p.category}</td>
                  <td className="px-3 py-2">
                    <span className={`px-2 py-1 rounded text-xs font-medium ${p.isAvailable ? 'bg-green-200 text-green-800' : 'bg-red-200 text-red-800'}`}>{p.isAvailable ? 'Available' : 'Unavailable'}</span>
                    <label className="inline-flex items-center ml-2 cursor-pointer">
                      <input type="checkbox" checked={p.isAvailable} onChange={e => handleStatusChange(p)} className="sr-only peer" />
                      <div className="w-10 h-5 bg-gray-200 rounded-full peer peer-checked:bg-green-400 transition-all relative">
                        <div className={`absolute left-1 top-1 w-3 h-3 bg-white rounded-full shadow transition-all ${p.isAvailable ? 'translate-x-5' : ''}`}></div>
                      </div>
                    </label>
                  </td>
                  <td className="px-3 py-2 flex gap-2">
                    <button className="text-xs bg-primary text-white px-2 py-1 rounded" onClick={() => { setEditProduct(p); setShowForm(true); }}>Edit</button>
                    <button className="text-xs bg-danger text-white px-2 py-1 rounded" onClick={() => handleDelete(p._id)}>Delete</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
      {showForm && (
        <div className="fixed inset-0 bg-black bg-opacity-30 flex items-center justify-center z-50">
          <div className="bg-surface rounded-xl shadow-lg p-8 border border-border w-full max-w-lg relative">
            <button className="absolute top-2 right-2 text-gray-400 hover:text-danger text-2xl" onClick={() => setShowForm(false)}>&times;</button>
            <ProductForm initial={editProduct} onSave={() => { setShowForm(false); fetchProducts(); setSuccess(editProduct ? 'Product updated' : 'Product created'); }} onCancel={() => setShowForm(false)} />
          </div>
        </div>
      )}
      {detailProduct && (
        <ProductDetailModal product={detailProduct} onClose={() => setDetailProduct(null)} />
      )}
    </div>
  );
} 