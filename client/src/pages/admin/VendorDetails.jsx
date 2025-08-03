import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { api } from '../../api';
import Loader from '../../components/Loader';
import Skeleton from '../../components/Skeleton';

export default function VendorDetailsPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [vendor, setVendor] = useState(null);
  const [products, setProducts] = useState([]);
  const [sales, setSales] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    setLoading(true);
    setError('');
    Promise.all([
      api.get(`/admin/vendors`),
      api.get(`/admin/vendors/${id}/products`),
      api.get(`/admin/vendors/${id}/sales`),
    ]).then(([vendors, products, sales]) => {
      setVendor(vendors.find(v => v._id === id));
      setProducts(products);
      setSales(sales);
    }).catch(e => setError(e.message)).finally(() => setLoading(false));
  }, [id]);

  if (loading) return <div className="min-h-screen flex items-center justify-center"><Loader /></div>;
  if (error || !vendor) return <div className="min-h-screen flex items-center justify-center text-danger">{error || 'Vendor not found'}</div>;

  return (
    <div className="min-h-screen bg-bg flex flex-col items-center pt-10 px-4">
      <div className="w-full max-w-5xl bg-surface rounded-xl shadow-lg p-8 border border-border mb-8">
        <button onClick={() => navigate(-1)} className="mb-4 text-primary hover:underline">&larr; Back</button>
        <div className="flex flex-col md:flex-row gap-8">
          <div className="flex-1">
            <h2 className="text-3xl font-bold mb-2 text-primary">{vendor.storeName}</h2>
            <div className="mb-2 text-gray-700">Owner: <span className="font-semibold">{vendor.name}</span></div>
            <div className="mb-2 text-gray-700">Email: <span className="font-semibold">{vendor.email}</span></div>
            <div className="mb-2 text-gray-700">Rating: <span className="font-semibold">{vendor.storeRating?.toFixed(1) || '-'}</span></div>
            <div className="mb-2 text-gray-700">Reviews: <span className="font-semibold">{vendor.storeReviews || '-'}</span></div>
            <div className="mb-2 text-gray-700">Status: {vendor.isActive ? <span className="text-success font-semibold">Active</span> : <span className="text-danger font-semibold">Blocked</span>}</div>
            <div className="mb-2 text-gray-700">Tags: {vendor.storeTags?.join(', ') || '-'}</div>
            <div className="mb-2 text-gray-700">Featured: {vendor.isFeatured ? 'Yes' : 'No'}</div>
            <div className="mb-4 text-gray-700">Description: {vendor.storeDescription || '-'}</div>
          </div>
          {vendor.storeBanner && (
            <div className="flex-shrink-0 w-full md:w-64 h-40 md:h-64 rounded-lg overflow-hidden border border-border bg-gray-100 flex items-center justify-center">
              <img src={vendor.storeBanner} alt="Store Banner" className="object-cover w-full h-full" />
            </div>
          )}
        </div>
        <div className="mt-8">
          <h3 className="text-xl font-bold mb-2">Sales Performance</h3>
          {sales ? (
            <div className="flex gap-8 text-lg">
              <div>Total Sales: <span className="font-semibold">Rs {sales.totalSales?.toFixed(2) || '0.00'}</span></div>
              <div>Order Count: <span className="font-semibold">{sales.orderCount || 0}</span></div>
            </div>
          ) : <Skeleton height="2rem" width="200px" />}
        </div>
      </div>
      <div className="w-full max-w-5xl">
        <h3 className="text-2xl font-bold mb-4 text-primary">Products</h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-6">
          {products.length === 0 && <div className="col-span-full text-gray-400">No products found.</div>}
          {products.map(product => (
            <div key={product._id} className="bg-white rounded-lg shadow border border-border p-4 flex flex-col">
              <div className="h-40 w-full mb-3 rounded overflow-hidden bg-gray-100 flex items-center justify-center">
                {product.imageUrl ? (
                  <img src={product.imageUrl} alt={product.name} className="object-cover w-full h-full" />
                ) : <Skeleton height="100%" width="100%" />}
              </div>
              <div className="font-bold text-lg mb-1">{product.name}</div>
              <div className="text-gray-600 mb-1">Category: {product.category}</div>
              <div className="text-gray-600 mb-1">Price: <span className="font-semibold">Rs {product.price}</span></div>
              <div className="text-gray-600 mb-1">Available: {product.isAvailable ? <span className="text-success">Yes</span> : <span className="text-danger">No</span>}</div>
              <div className="text-gray-500 text-xs mt-auto">{product.description}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
} 