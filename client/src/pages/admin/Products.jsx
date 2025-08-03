import React, { useEffect, useState, useRef } from 'react';
import { api } from '../../api';
import Table from '../../components/Table';
import Loader from '../../components/Loader';
import Skeleton from '../../components/Skeleton';
import * as Dialog from '@radix-ui/react-dialog';

export default function Products() {
  const [products, setProducts] = useState([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [selectedProduct, setSelectedProduct] = useState(null);
  const [detailsOpen, setDetailsOpen] = useState(false);
  const [actionLoading, setActionLoading] = useState(false);
  const [dialogType, setDialogType] = useState(null); // 'edit' | 'delete' | 'view'
  const [search, setSearch] = useState('');
  const [vendorFilter, setVendorFilter] = useState('');
  const [vendors, setVendors] = useState([]);
  const [page, setPage] = useState(1);
  const pageSize = 20;
  const searchTimeout = useRef();

  const fetchProducts = async (opts = {}) => {
    setLoading(true);
    setError('');
    try {
      const { products, total } = await api.get(`/products?search=${encodeURIComponent(opts.search ?? search)}&vendorId=${encodeURIComponent(opts.vendorId ?? vendorFilter)}&page=${opts.page ?? page}&limit=${pageSize}`);
      setProducts(products);
      setTotal(total);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const fetchVendors = async () => {
    try {
      const data = await api.get('/admin/vendors');
      setVendors(data);
    } catch {}
  };

  useEffect(() => { fetchVendors(); }, []);
  useEffect(() => { fetchProducts({ page: 1 }); setPage(1); }, [vendorFilter]);
  useEffect(() => { if (searchTimeout.current) clearTimeout(searchTimeout.current); searchTimeout.current = setTimeout(() => { fetchProducts({ page: 1 }); setPage(1); }, 400); return () => clearTimeout(searchTimeout.current); }, [search]);
  useEffect(() => { fetchProducts(); }, [page]);

  const columns = [
    { key: 'imageUrl', title: '', render: p => p.imageUrl ? <img src={p.imageUrl} alt={p.name} className="w-10 h-10 rounded object-cover" /> : <Skeleton width="40px" height="40px" /> },
    { key: 'name', title: 'Name' },
    { key: 'category', title: 'Category' },
    { key: 'price', title: 'Price', render: p => `Rs ${p.price}` },
    { key: 'vendorId', title: 'Vendor', render: p => p.vendorId?.storeName || '-' },
    { key: 'isAvailable', title: 'Available', render: p => p.isAvailable ? <span className="text-success">Yes</span> : <span className="text-danger">No</span> },
    { key: 'createdAt', title: 'Created', render: p => new Date(p.createdAt).toLocaleDateString() },
    { key: 'actions', title: 'Actions', render: p => (
      <div className="flex gap-2">
        <button className="text-xs bg-primary text-white px-2 py-1 rounded" onClick={() => { setSelectedProduct(p); setDialogType('view'); setDetailsOpen(true); }}>View</button>
        <button className="text-xs bg-warning text-white px-2 py-1 rounded" onClick={() => { setSelectedProduct(p); setDialogType('edit'); setDetailsOpen(true); }}>Edit</button>
        <button className="text-xs bg-danger text-white px-2 py-1 rounded" onClick={() => { setSelectedProduct(p); setDialogType('delete'); setDetailsOpen(true); }}>Delete</button>
      </div>
    )},
  ];

  const data = products.map(p => ({ ...p }));
  const totalPages = Math.ceil(total / pageSize);

  return (
    <div className="min-h-screen bg-bg flex items-start justify-center pt-10">
      <div className="max-w-6xl w-full bg-surface rounded-xl shadow-lg p-8 border border-border">
        <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-6">
          <h1 className="text-3xl font-bold text-primary">Products</h1>
          <div className="flex gap-2 items-center w-full md:w-auto">
            <input
              type="text"
              className="flex-1 border border-border rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-primary bg-bg"
              placeholder="Search by name or category..."
              value={search}
              onChange={e => setSearch(e.target.value)}
            />
            <select
              className="border border-border rounded px-3 py-2 bg-bg focus:outline-none focus:ring-2 focus:ring-primary"
              value={vendorFilter}
              onChange={e => setVendorFilter(e.target.value)}
            >
              <option value="">All Vendors</option>
              {vendors.map(v => <option key={v._id} value={v._id}>{v.storeName}</option>)}
            </select>
          </div>
        </div>
        <Table columns={columns} data={data} loading={loading} error={error} />
        <div className="flex justify-center mt-6 gap-2">
          <button className="px-3 py-1 rounded bg-gray-200" onClick={() => setPage(p => Math.max(1, p - 1))} disabled={page === 1}>Prev</button>
          {[...Array(totalPages)].map((_, i) => (
            <button key={i} className={`px-3 py-1 rounded ${page === i + 1 ? 'bg-primary text-white' : 'bg-gray-100'}`} onClick={() => setPage(i + 1)}>{i + 1}</button>
          ))}
          <button className="px-3 py-1 rounded bg-gray-200" onClick={() => setPage(p => Math.min(totalPages, p + 1))} disabled={page === totalPages}>Next</button>
        </div>
        <Dialog.Root open={detailsOpen} onOpenChange={setDetailsOpen}>
          <Dialog.Portal>
            <Dialog.Overlay className="fixed inset-0 bg-black/30 z-40" />
            <Dialog.Content className="fixed z-50 left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 bg-surface p-8 rounded-xl shadow-lg border border-border w-full max-w-2xl">
              {dialogType === 'view' && selectedProduct && <ProductDetails product={selectedProduct} />}
              {dialogType === 'edit' && selectedProduct && <ProductForm product={selectedProduct} onClose={() => { setDetailsOpen(false); fetchProducts(); }} />}
              {dialogType === 'delete' && selectedProduct && <DeleteProductConfirm product={selectedProduct} onClose={() => { setDetailsOpen(false); fetchProducts(); }} />}
              <Dialog.Close asChild>
                <button className="absolute top-4 right-4 text-gray-400 hover:text-primary text-2xl">&times;</button>
              </Dialog.Close>
            </Dialog.Content>
          </Dialog.Portal>
        </Dialog.Root>
      </div>
    </div>
  );
}

function ProductDetails({ product }) {
  return (
    <div>
      <h2 className="text-2xl font-bold mb-2 text-primary">{product.name}</h2>
      <div className="mb-2 text-gray-700">Category: <span className="font-semibold">{product.category}</span></div>
      <div className="mb-2 text-gray-700">Price: <span className="font-semibold">Rs {product.price}</span></div>
      <div className="mb-2 text-gray-700">Vendor: <span className="font-semibold">{product.vendorId?.storeName || '-'}</span></div>
      <div className="mb-2 text-gray-700">Available: {product.isAvailable ? <span className="text-success">Yes</span> : <span className="text-danger">No</span>}</div>
      <div className="mb-2 text-gray-700">Created: {new Date(product.createdAt).toLocaleString()}</div>
      <div className="mb-4 text-gray-700">Description: {product.description || '-'}</div>
      {product.imageUrl && <img src={product.imageUrl} alt={product.name} className="w-64 h-64 object-cover rounded border border-border" />}
    </div>
  );
}

function ProductForm({ product, onClose }) {
  // TODO: Implement edit form with backend integration
  return (
    <div>
      <h2 className="text-2xl font-bold mb-4 text-primary">Edit Product</h2>
      <div className="text-gray-400">Form coming soon...</div>
      <button className="mt-4 bg-gray-200 px-4 py-2 rounded" onClick={onClose}>Close</button>
    </div>
  );
}

function DeleteProductConfirm({ product, onClose }) {
  const [loading, setLoading] = useState(false);
  const handleDelete = async () => {
    setLoading(true);
    try {
      await api.del(`/products/${product._id}`);
      onClose();
    } catch (err) {
      alert(err.message);
    } finally {
      setLoading(false);
    }
  };
  return (
    <div>
      <h2 className="text-2xl font-bold mb-4 text-danger">Delete Product</h2>
      <div className="mb-4">Are you sure you want to delete <span className="font-semibold">{product.name}</span>?</div>
      <div className="flex gap-2 justify-end">
        <button className="px-4 py-2 rounded bg-gray-200 hover:bg-gray-300" onClick={onClose} disabled={loading}>Cancel</button>
        <button className="px-4 py-2 rounded bg-danger text-white hover:bg-danger-dark" onClick={handleDelete} disabled={loading}>{loading ? 'Deleting...' : 'Delete'}</button>
      </div>
    </div>
  );
} 