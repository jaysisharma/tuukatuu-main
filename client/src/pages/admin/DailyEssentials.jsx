import React, { useState, useEffect } from 'react';
import { api } from '../../api';
import { toast } from 'react-hot-toast';
import { 
  Plus, 
  Search, 
  Grid, 
  List, 
  CheckCircle,
  Circle,
  Package,
  Star,
  StarOff,
  Filter
} from 'lucide-react';

const DailyEssentials = () => {
  const [products, setProducts] = useState([]);
  const [dailyEssentials, setDailyEssentials] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [filter, setFilter] = useState('all');
  const [viewMode, setViewMode] = useState('grid');
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [updatingProduct, setUpdatingProduct] = useState(null);

  useEffect(() => {
    loadProducts();
    loadDailyEssentials();
  }, [currentPage, searchTerm]);

  const loadProducts = async () => {
    try {
      setLoading(true);
      console.log('Loading products from /admin/products...');
      const response = await api.get(`/admin/products?page=${currentPage}&limit=50&search=${searchTerm}`);
      console.log('Products response:', response);
      setProducts(response.products || []);
      setTotalPages(response.pagination?.totalPages || response.pagination?.pages || 1);
    } catch (error) {
      console.error('Error loading products:', error);
      toast.error('Failed to load products');
      // Set empty products array to prevent crashes
      setProducts([]);
      setTotalPages(1);
    } finally {
      setLoading(false);
    }
  };

  const loadDailyEssentials = async () => {
    try {
      console.log('Loading daily essentials from /daily-essentials...');
      const response = await api.get('/daily-essentials');
      console.log('Daily essentials response:', response);
      setDailyEssentials(response.data || []);
    } catch (error) {
      console.error('Failed to load daily essentials:', error);
      // Set empty array to prevent crashes
      setDailyEssentials([]);
    }
  };

  const handleToggleDailyEssential = async (productId, currentStatus) => {
    try {
      setUpdatingProduct(productId);
      
      // Use the toggle endpoint which handles both add and remove
      await api.patch('/daily-essentials/admin/toggle', { productId });
      
      const message = currentStatus ? 'Product removed from daily essentials' : 'Product added to daily essentials';
      toast.success(message);
      
      // Reload data
      loadProducts();
      loadDailyEssentials();
    } catch (error) {
      toast.error('Failed to update daily essential status');
    } finally {
      setUpdatingProduct(null);
    }
  };

  const handleToggleFeatured = async (productId, currentStatus) => {
    try {
      setUpdatingProduct(productId);
      
      await api.patch('/daily-essentials/admin/toggle-featured', { productId });
      toast.success(currentStatus ? 'Product unmarked as featured' : 'Product marked as featured');
      
      // Reload data
      loadProducts();
      loadDailyEssentials();
    } catch (error) {
      toast.error('Failed to update featured status');
    } finally {
      setUpdatingProduct(null);
    }
  };

  const isDailyEssential = (productId) => {
    return dailyEssentials.some(essential => essential._id === productId);
  };

  const filteredProducts = products.filter(product => {
    if (filter === 'daily-essentials') {
      return isDailyEssential(product._id);
    } else if (filter === 'not-daily-essentials') {
      return !isDailyEssential(product._id);
    }
    return true;
  });

  const ProductCard = ({ product }) => {
    const isEssential = isDailyEssential(product._id);
    const isFeatured = product.isFeaturedDailyEssential || false;
    const isUpdating = updatingProduct === product._id;

    return (
      <div className="bg-white rounded-lg shadow-md p-4 border border-gray-200 hover:shadow-lg transition-shadow">
        <div className="flex items-start justify-between mb-3">
          <div className="flex-1">
            <h3 className="font-semibold text-gray-900 truncate">{product.name}</h3>
            <p className="text-sm text-gray-600">{product.category}</p>
          </div>
          <div className="flex items-center space-x-2">
            {isEssential ? (
              <CheckCircle className="w-5 h-5 text-green-500" />
            ) : (
              <Circle className="w-5 h-5 text-gray-300" />
            )}
          </div>
        </div>

        <div className="mb-3 relative">
          <img 
            src={product.imageUrl} 
            alt={product.name}
            className="w-full h-32 object-cover rounded-md"
            onError={(e) => {
              e.target.src = 'https://via.placeholder.com/300x200?text=No+Image';
            }}
          />
          {isFeatured && (
            <div className="absolute top-2 left-2">
              <span className="bg-orange-500 text-white text-xs px-2 py-1 rounded-full font-bold">
                FEATURED
              </span>
            </div>
          )}
        </div>

        <div className="flex items-center justify-between mb-3">
          <div>
            <p className="text-lg font-bold text-gray-900">₹{product.price}</p>
            <p className="text-sm text-gray-500">{product.unit}</p>
          </div>
          <div className="text-right">
            <p className={`text-sm px-2 py-1 rounded-full ${
              product.isAvailable 
                ? 'bg-green-100 text-green-800' 
                : 'bg-red-100 text-red-800'
            }`}>
              {product.isAvailable ? 'Available' : 'Unavailable'}
            </p>
          </div>
        </div>

        <div className="space-y-2">
          <button
            onClick={() => handleToggleDailyEssential(product._id, isEssential)}
            disabled={isUpdating}
            className={`w-full py-2 px-4 rounded-md font-medium transition-colors ${
              isEssential
                ? 'bg-red-100 text-red-700 hover:bg-red-200'
                : 'bg-green-100 text-green-700 hover:bg-green-200'
            } ${isUpdating ? 'opacity-50 cursor-not-allowed' : ''}`}
          >
            {isUpdating ? (
              'Updating...'
            ) : isEssential ? (
              <>
                <StarOff className="w-4 h-4 inline mr-2" />
                Remove from Daily Essentials
              </>
            ) : (
              <>
                <Star className="w-4 h-4 inline mr-2" />
                Add to Daily Essentials
              </>
            )}
          </button>
          
          {isEssential && (
            <button
              onClick={() => handleToggleFeatured(product._id, isFeatured)}
              disabled={isUpdating}
              className={`w-full py-2 px-4 rounded-md font-medium transition-colors ${
                isFeatured
                  ? 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                  : 'bg-orange-100 text-orange-700 hover:bg-orange-200'
              } ${isUpdating ? 'opacity-50 cursor-not-allowed' : ''}`}
            >
              {isUpdating ? (
                'Updating...'
              ) : isFeatured ? (
                <>
                  <StarOff className="w-4 h-4 inline mr-2" />
                  Unmark as Featured
                </>
              ) : (
                <>
                  <Star className="w-4 h-4 inline mr-2" />
                  Mark as Featured
                </>
              )}
            </button>
          )}
        </div>
      </div>
    );
  };

  const ProductList = ({ products }) => (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
      {products.map(product => (
        <ProductCard key={product._id} product={product} />
      ))}
    </div>
  );

  const ProductTable = ({ products }) => (
    <div className="bg-white rounded-lg shadow overflow-hidden">
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Product
            </th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Category
            </th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Price
            </th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Status
            </th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Daily Essential
            </th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Actions
            </th>
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-gray-200">
          {products.map(product => {
            const isEssential = isDailyEssential(product._id);
            const isUpdating = updatingProduct === product._id;
            
            return (
              <tr key={product._id} className="hover:bg-gray-50">
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="flex items-center">
                    <img 
                      src={product.imageUrl} 
                      alt={product.name}
                      className="w-10 h-10 rounded-md object-cover mr-3"
                      onError={(e) => {
                        e.target.src = 'https://via.placeholder.com/40x40?text=No+Image';
                      }}
                    />
                    <div>
                      <div className="text-sm font-medium text-gray-900">{product.name}</div>
                      <div className="text-sm text-gray-500">{product.unit}</div>
                    </div>
                  </div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {product.category}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  ₹{product.price}
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                    product.isAvailable 
                      ? 'bg-green-100 text-green-800' 
                      : 'bg-red-100 text-red-800'
                  }`}>
                    {product.isAvailable ? 'Available' : 'Unavailable'}
                  </span>
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  {isEssential ? (
                    <CheckCircle className="w-5 h-5 text-green-500" />
                  ) : (
                    <Circle className="w-5 h-5 text-gray-300" />
                  )}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                  <button
                    onClick={() => handleToggleDailyEssential(product._id, isEssential)}
                    disabled={isUpdating}
                    className={`px-3 py-1 rounded-md text-xs font-medium transition-colors ${
                      isEssential
                        ? 'bg-red-100 text-red-700 hover:bg-red-200'
                        : 'bg-green-100 text-green-700 hover:bg-green-200'
                    } ${isUpdating ? 'opacity-50 cursor-not-allowed' : ''}`}
                  >
                    {isUpdating ? 'Updating...' : isEssential ? 'Remove' : 'Add'}
                  </button>
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900 mb-2">Daily Essentials Management</h1>
        <p className="text-gray-600">
          Manage which products are marked as daily essentials for the mobile app.
        </p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div className="bg-white p-4 rounded-lg shadow border border-gray-200">
          <div className="flex items-center">
            <Package className="w-8 h-8 text-blue-500 mr-3" />
            <div>
              <p className="text-sm font-medium text-gray-600">Total Products</p>
              <p className="text-2xl font-bold text-gray-900">{products.length}</p>
            </div>
          </div>
        </div>
        <div className="bg-white p-4 rounded-lg shadow border border-gray-200">
          <div className="flex items-center">
            <Star className="w-8 h-8 text-yellow-500 mr-3" />
            <div>
              <p className="text-sm font-medium text-gray-600">Daily Essentials</p>
              <p className="text-2xl font-bold text-gray-900">{dailyEssentials.length}</p>
            </div>
          </div>
        </div>
        <div className="bg-white p-4 rounded-lg shadow border border-gray-200">
          <div className="flex items-center">
            <CheckCircle className="w-8 h-8 text-orange-500 mr-3" />
            <div>
              <p className="text-sm font-medium text-gray-600">Featured</p>
              <p className="text-2xl font-bold text-gray-900">
                {dailyEssentials.filter(p => p.isFeaturedDailyEssential).length}
              </p>
            </div>
          </div>
        </div>
        <div className="bg-white p-4 rounded-lg shadow border border-gray-200">
          <div className="flex items-center">
            <CheckCircle className="w-8 h-8 text-green-500 mr-3" />
            <div>
              <p className="text-sm font-medium text-gray-600">Available Products</p>
              <p className="text-2xl font-bold text-gray-900">
                {products.filter(p => p.isAvailable).length}
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Controls */}
      <div className="bg-white p-4 rounded-lg shadow border border-gray-200 mb-6">
        <div className="flex flex-col sm:flex-row gap-4 items-center justify-between">
          <div className="flex items-center space-x-4">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
              <input
                type="text"
                placeholder="Search products..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10 pr-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>
            <select
              value={filter}
              onChange={(e) => setFilter(e.target.value)}
              className="px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="all">All Products</option>
              <option value="daily-essentials">Daily Essentials</option>
              <option value="not-daily-essentials">Not Daily Essentials</option>
            </select>
          </div>
          <div className="flex items-center space-x-2">
            <button
              onClick={() => setViewMode('grid')}
              className={`p-2 rounded-md ${
                viewMode === 'grid' 
                  ? 'bg-blue-100 text-blue-600' 
                  : 'bg-gray-100 text-gray-600'
              }`}
            >
              <Grid className="w-4 h-4" />
            </button>
            <button
              onClick={() => setViewMode('list')}
              className={`p-2 rounded-md ${
                viewMode === 'list' 
                  ? 'bg-blue-100 text-blue-600' 
                  : 'bg-gray-100 text-gray-600'
              }`}
            >
              <List className="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>

      {/* Content */}
      {loading ? (
        <div className="flex items-center justify-center py-12">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
          <span className="ml-2 text-gray-600">Loading products...</span>
        </div>
      ) : filteredProducts.length === 0 ? (
        <div className="text-center py-12">
          <Package className="w-12 h-12 text-gray-400 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">No products found</h3>
          <p className="text-gray-600">
            {searchTerm ? 'Try adjusting your search terms.' : 'No products available.'}
          </p>
        </div>
      ) : (
        <>
          {viewMode === 'grid' ? (
            <ProductList products={filteredProducts} />
          ) : (
            <ProductTable products={filteredProducts} />
          )}
          
          {/* Pagination */}
          {totalPages > 1 && (
            <div className="mt-6 flex items-center justify-center">
              <nav className="flex items-center space-x-2">
                <button
                  onClick={() => setCurrentPage(Math.max(1, currentPage - 1))}
                  disabled={currentPage === 1}
                  className="px-3 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-300 rounded-md hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Previous
                </button>
                <span className="px-3 py-2 text-sm text-gray-700">
                  Page {currentPage} of {totalPages}
                </span>
                <button
                  onClick={() => setCurrentPage(Math.min(totalPages, currentPage + 1))}
                  disabled={currentPage === totalPages}
                  className="px-3 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-300 rounded-md hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Next
                </button>
              </nav>
            </div>
          )}
        </>
      )}
    </div>
  );
};

export default DailyEssentials; 