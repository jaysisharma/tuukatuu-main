import React, { useState, useEffect } from 'react';
import { api } from '../../api';
import { toast } from 'react-hot-toast';
import { 
  Plus, 
  Edit, 
  Trash2, 
  Star, 
  StarOff, 
  Upload, 
  Search,
  Filter,
  Grid,
  List,
  Eye,
  EyeOff,
  ArrowUp,
  ArrowDown,
  Clock,
  Tag,
  DollarSign,
  Package,
  TrendingUp,
  Calendar,
  AlertCircle,
  Save,
  X,
  Check,
  MoreVertical
} from 'lucide-react';

const TodayDeals = () => {
  // State management
  const [deals, setDeals] = useState([]);
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState({});
  const [searchTerm, setSearchTerm] = useState('');
  const [filter, setFilter] = useState('all');
  const [viewMode, setViewMode] = useState('grid');
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [showEditModal, setShowEditModal] = useState(false);
  const [editingDeal, setEditingDeal] = useState(null);
  const [uploadingImage, setUploadingImage] = useState(false);
  const [categories, setCategories] = useState([]);
  const [currentPage, setCurrentPage] = useState(1);

  // Form states
  const [createFormData, setCreateFormData] = useState({
    name: '',
    description: '',
    originalPrice: '',
    price: '',
    discount: '',
    dealType: 'percentage',
    category: '',
    featured: false,
    maxQuantity: '',
    soldQuantity: '0',
    startDate: '',
    endDate: '',
    tags: [],
    imageUrl: ''
  });

  const [editFormData, setEditFormData] = useState({
    name: '',
    description: '',
    originalPrice: '',
    price: '',
    discount: '',
    dealType: 'percentage',
    category: '',
    featured: false,
    maxQuantity: '',
    soldQuantity: '',
    startDate: '',
    endDate: '',
    tags: [],
    imageUrl: ''
  });

  useEffect(() => {
    loadDeals();
    loadStats();
    loadCategories();
  }, [searchTerm, filter]);

  // CRUD Operations

  // READ - Load deals
  const loadDeals = async () => {
    try {
      setLoading(true);
      const params = new URLSearchParams({
        ...(searchTerm && { search: searchTerm }),
        ...(filter !== 'all' && { [filter]: true })
      });

      const response = await api.get(`/today-deals?${params}`);
      console.log('🔍 Loaded deals:', response);
      
      const dealsData = response.data || response || [];
      setDeals(Array.isArray(dealsData) ? dealsData : []);
    } catch (error) {
      toast.error('Failed to load today\'s deals');
      console.error('Error loading deals:', error);
    } finally {
      setLoading(false);
    }
  };

  // READ - Load stats
  const loadStats = async () => {
    try {
      const response = await api.get('/today-deals/stats');
      setStats(response.data || response || {});
    } catch (error) {
      console.error('Error loading stats:', error);
      setStats({
        totalDeals: deals.length,
        activeDeals: deals.filter(d => !d.isExpired).length,
        featuredDeals: deals.filter(d => d.featured).length,
        expiredDeals: deals.filter(d => d.isExpired).length
      });
    }
  };

  // READ - Load categories
  const loadCategories = async () => {
    try {
      const response = await api.get('/categories');
      setCategories(response.data || []);
    } catch (error) {
      console.error('Error loading categories:', error);
    }
  };

  // CREATE - Create new deal
  const handleCreateDeal = async (e) => {
    e.preventDefault();
    try {
      const dealData = {
        ...createFormData,
        originalPrice: parseFloat(createFormData.originalPrice),
        price: parseFloat(createFormData.price),
        discount: parseInt(createFormData.discount),
        maxQuantity: parseInt(createFormData.maxQuantity),
        soldQuantity: parseInt(createFormData.soldQuantity),
        startDate: new Date(createFormData.startDate).toISOString(),
        endDate: new Date(createFormData.endDate).toISOString()
      };

      await api.post('/deals', dealData);
      toast.success('Deal created successfully!');
      setShowCreateModal(false);
      resetCreateForm();
      loadDeals();
    } catch (error) {
      toast.error('Failed to create deal');
      console.error('Error creating deal:', error);
    }
  };

  // UPDATE - Update existing deal
  const handleUpdateDeal = async (e) => {
    e.preventDefault();
    try {
      const updateData = {
        ...editFormData,
        originalPrice: parseFloat(editFormData.originalPrice),
        price: parseFloat(editFormData.price),
        discount: parseInt(editFormData.discount),
        maxQuantity: parseInt(editFormData.maxQuantity),
        soldQuantity: parseInt(editFormData.soldQuantity),
        startDate: new Date(editFormData.startDate).toISOString(),
        endDate: new Date(editFormData.endDate).toISOString()
      };

      await api.put(`/deals/${editingDeal._id}`, updateData);
      toast.success('Deal updated successfully!');
      setShowEditModal(false);
      setEditingDeal(null);
      loadDeals();
    } catch (error) {
      toast.error('Failed to update deal');
      console.error('Error updating deal:', error);
    }
  };

  // DELETE - Delete deal
  const handleDeleteDeal = async (dealId) => {
    if (!window.confirm('Are you sure you want to delete this deal?')) return;
    
    try {
      await api.del(`/deals/${dealId}`);
      toast.success('Deal deleted successfully!');
      loadDeals();
    } catch (error) {
      toast.error('Failed to delete deal');
      console.error('Error deleting deal:', error);
    }
  };

  // UPDATE - Toggle featured status
  const handleToggleFeatured = async (dealId, currentFeatured) => {
    try {
      await api.patch(`/deals/${dealId}`, { featured: !currentFeatured });
      toast.success(`Deal ${currentFeatured ? 'unfeatured' : 'featured'} successfully!`);
      loadDeals();
    } catch (error) {
      toast.error('Failed to update deal status');
      console.error('Error updating deal status:', error);
    }
  };

  // Image upload
  const handleImageUpload = async (file) => {
    try {
      setUploadingImage(true);
      const formData = new FormData();
      formData.append('image', file);
      
      const response = await api.upload('/upload-image', formData);
      
      setCreateFormData(prev => ({
        ...prev,
        imageUrl: response.data.imageUrl
      }));
      
      toast.success('Image uploaded successfully');
    } catch (error) {
      toast.error('Failed to upload image');
    } finally {
      setUploadingImage(false);
    }
  };

  // Form handlers
  const openCreateModal = () => {
    setShowCreateModal(true);
    resetCreateForm();
  };

  const openEditModal = (deal) => {
    setEditingDeal(deal);
    setEditFormData({
      name: deal.name || '',
      description: deal.description || '',
      originalPrice: deal.originalPrice || '',
      price: deal.price || '',
      discount: deal.discount || '',
      dealType: deal.dealType || 'percentage',
      category: deal.category || '',
      featured: deal.featured || false,
      maxQuantity: deal.maxQuantity || '',
      soldQuantity: deal.soldQuantity || '',
      startDate: deal.startDate ? new Date(deal.startDate).toISOString().split('T')[0] : '',
      endDate: deal.endDate ? new Date(deal.endDate).toISOString().split('T')[0] : '',
      tags: deal.tags || [],
      imageUrl: deal.imageUrl || ''
    });
    setShowEditModal(true);
  };

  const resetCreateForm = () => {
    setCreateFormData({
      name: '',
      description: '',
      originalPrice: '',
      price: '',
      discount: '',
      dealType: 'percentage',
      category: '',
      featured: false,
      maxQuantity: '',
      soldQuantity: '0',
      startDate: '',
      endDate: '',
      tags: [],
      imageUrl: ''
    });
  };

  // Utility functions
  const getStatusColor = (deal) => {
    if (deal.isExpired) return 'text-red-500 bg-red-100';
    if (deal.remainingQuantity < 5) return 'text-orange-500 bg-orange-100';
    return 'text-green-500 bg-green-100';
  };

  const getStatusText = (deal) => {
    if (deal.isExpired) return 'Expired';
    if (deal.remainingQuantity < 5) return 'Low Stock';
    return 'Active';
  };

  // Deal Card Component
  const DealCard = ({ deal }) => {
    const dealName = deal.name || deal.description?.split(' ').slice(0, 3).join(' ') || 'Unnamed Deal';
    const dealImage = deal.imageUrl || 'https://via.placeholder.com/300x200?text=No+Image';
    const dealPrice = deal.price || (deal.originalPrice ? deal.originalPrice * 0.8 : 0);
    const dealOriginalPrice = deal.originalPrice || 0;
    const dealDiscount = deal.discount || 20;
    const dealRemainingQuantity = deal.remainingQuantity || 0;
    const dealSoldQuantity = deal.soldQuantity || 0;
    const dealMaxQuantity = deal.maxQuantity || 10;
    const dealCategory = deal.category || 'Uncategorized';
    const dealEndDate = deal.endDate ? new Date(deal.endDate) : new Date();
    const dealFeatured = deal.featured || false;
    const dealTags = deal.tags || [];
    const dealIsExpired = deal.isExpired || false;
    const dealIsValid = deal.isValid || true;

    return (
      <div className="bg-white rounded-lg shadow-md p-6 border border-gray-200 hover:shadow-lg transition-shadow">
        {/* Header */}
        <div className="flex items-start justify-between mb-4">
          <div className="flex items-center space-x-2">
            <h3 className="text-lg font-semibold text-gray-900">{deal.description || dealName}</h3>
            {dealFeatured && (
              <Star className="w-4 h-4 text-yellow-500 fill-current" />
            )}
          </div>
          <div className="flex items-center space-x-2">
            <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(deal)}`}>
              {getStatusText(deal)}
            </span>
            {dealIsExpired && (
              <span className="px-2 py-1 rounded-full text-xs font-medium bg-red-100 text-red-800">
                Expired
              </span>
            )}
            {!dealIsValid && (
              <span className="px-2 py-1 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800">
                Invalid
              </span>
            )}
          </div>
        </div>

        {/* Image */}
        <div className="mb-4">
          <img 
            src={dealImage} 
            alt={dealName}
            className="w-full h-32 object-cover rounded-lg"
            onError={(e) => {
              e.target.src = 'https://via.placeholder.com/300x200?text=No+Image';
            }}
          />
        </div>

        {/* Deal Details */}
        <div className="space-y-2 mb-4">
          <div className="flex items-center justify-between">
            <span className="text-sm text-gray-600">Original Price:</span>
            <span className="text-sm line-through text-gray-500">₹{dealOriginalPrice}</span>
          </div>
          <div className="flex items-center justify-between">
            <span className="text-sm text-gray-600">Deal Price:</span>
            <span className="text-lg font-bold text-orange-600">₹{dealPrice}</span>
          </div>
          <div className="flex items-center justify-between">
            <span className="text-sm text-gray-600">Discount:</span>
            <span className="text-sm font-medium text-green-600">{dealDiscount}% OFF</span>
          </div>
          <div className="flex items-center justify-between">
            <span className="text-sm text-gray-600">Category:</span>
            <span className="text-sm font-medium">{dealCategory}</span>
          </div>
          <div className="flex items-center justify-between">
            <span className="text-sm text-gray-600">Stock:</span>
            <span className="text-sm font-medium">{dealRemainingQuantity} left</span>
          </div>
          <div className="flex items-center justify-between">
            <span className="text-sm text-gray-600">Sold:</span>
            <span className="text-sm font-medium">{dealSoldQuantity}/{dealMaxQuantity}</span>
          </div>
        </div>

        {/* Progress Bar */}
        <div className="mb-4">
          <div className="w-full bg-gray-200 rounded-full h-2">
            <div 
              className="bg-orange-500 h-2 rounded-full" 
              style={{ width: `${(dealSoldQuantity / dealMaxQuantity) * 100}%` }}
            ></div>
          </div>
        </div>

        {/* Tags */}
        {dealTags.length > 0 && (
          <div className="mb-4">
            <div className="flex flex-wrap gap-1">
              {dealTags.map((tag, index) => (
                <span
                  key={index}
                  className="px-2 py-1 bg-blue-100 text-blue-800 text-xs rounded-full"
                >
                  {tag}
                </span>
              ))}
            </div>
          </div>
        )}

        {/* Footer */}
        <div className="flex items-center justify-between text-xs text-gray-500 mb-4">
          <span>Category: {dealCategory}</span>
          <span>Ends: {dealEndDate.toLocaleDateString()}</span>
        </div>

        {/* Actions */}
        <div className="flex items-center justify-between">
          <div className="flex space-x-2">
            <button
              onClick={() => openEditModal(deal)}
              className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
              title="Edit Deal"
            >
              <Edit className="w-4 h-4" />
            </button>
            <button
              onClick={() => handleToggleFeatured(deal._id, dealFeatured)}
              className={`p-2 rounded-lg transition-colors ${
                dealFeatured 
                  ? 'text-yellow-600 hover:bg-yellow-50' 
                  : 'text-gray-600 hover:bg-gray-50'
              }`}
              title={dealFeatured ? 'Unfeature Deal' : 'Feature Deal'}
            >
              {dealFeatured ? <Star className="w-4 h-4 fill-current" /> : <StarOff className="w-4 h-4" />}
            </button>
          </div>
          <button
            onClick={() => handleDeleteDeal(deal._id)}
            className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
            title="Delete Deal"
          >
            <Trash2 className="w-4 h-4" />
          </button>
        </div>
      </div>
    );
  };

  // Create Deal Modal
  const CreateDealModal = () => (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-2xl font-bold text-gray-900">Create New Deal</h2>
          <button
            onClick={() => setShowCreateModal(false)}
            className="text-gray-500 hover:text-gray-700"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <form onSubmit={handleCreateDeal} className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Deal Name *
              </label>
              <input
                type="text"
                required
                value={createFormData.name}
                onChange={(e) => setCreateFormData({...createFormData, name: e.target.value})}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
                placeholder="Enter deal name"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Category *
              </label>
              <select
                required
                value={createFormData.category}
                onChange={(e) => setCreateFormData({...createFormData, category: e.target.value})}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
              >
                <option value="">Select category</option>
                {categories.map(category => (
                  <option key={category._id} value={category.name}>
                    {category.name}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Original Price *
              </label>
              <input
                type="number"
                required
                step="0.01"
                value={createFormData.originalPrice}
                onChange={(e) => setCreateFormData({...createFormData, originalPrice: e.target.value})}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
                placeholder="0.00"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Deal Price *
              </label>
              <input
                type="number"
                required
                step="0.01"
                value={createFormData.price}
                onChange={(e) => setCreateFormData({...createFormData, price: e.target.value})}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
                placeholder="0.00"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Discount Percentage *
              </label>
              <input
                type="number"
                required
                min="0"
                max="100"
                value={createFormData.discount}
                onChange={(e) => setCreateFormData({...createFormData, discount: e.target.value})}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
                placeholder="0"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Maximum Quantity *
              </label>
              <input
                type="number"
                required
                min="1"
                value={createFormData.maxQuantity}
                onChange={(e) => setCreateFormData({...createFormData, maxQuantity: e.target.value})}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
                placeholder="10"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Start Date *
              </label>
              <input
                type="date"
                required
                value={createFormData.startDate}
                onChange={(e) => setCreateFormData({...createFormData, startDate: e.target.value})}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                End Date *
              </label>
              <input
                type="date"
                required
                value={createFormData.endDate}
                onChange={(e) => setCreateFormData({...createFormData, endDate: e.target.value})}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Description
            </label>
            <textarea
              value={createFormData.description}
              onChange={(e) => setCreateFormData({...createFormData, description: e.target.value})}
              rows="3"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
              placeholder="Enter deal description"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Product Image
            </label>
            <div className="flex items-center space-x-4">
              <input
                type="file"
                accept="image/*"
                onChange={(e) => {
                  const file = e.target.files[0];
                  if (file) {
                    handleImageUpload(file);
                  }
                }}
                className="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
              />
              {uploadingImage && (
                <div className="text-sm text-gray-500">Uploading...</div>
              )}
            </div>
            {createFormData.imageUrl && (
              <img 
                src={createFormData.imageUrl} 
                alt="Preview" 
                className="mt-2 w-32 h-32 object-cover rounded-lg"
              />
            )}
            <div className="mt-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Or enter image URL directly:
              </label>
              <input
                type="url"
                value={createFormData.imageUrl}
                onChange={(e) => setCreateFormData({...createFormData, imageUrl: e.target.value})}
                placeholder="https://example.com/image.jpg"
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
              />
            </div>
          </div>

          <div className="flex items-center space-x-4">
            <label className="flex items-center">
              <input
                type="checkbox"
                checked={createFormData.featured}
                onChange={(e) => setCreateFormData({...createFormData, featured: e.target.checked})}
                className="mr-2"
              />
              <span className="text-sm font-medium text-gray-700">Featured Deal</span>
            </label>
          </div>

          <div className="flex justify-end space-x-4">
            <button
              type="button"
              onClick={() => setShowCreateModal(false)}
              className="px-4 py-2 text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="px-4 py-2 bg-orange-600 text-white rounded-lg hover:bg-orange-700 transition-colors flex items-center space-x-2"
            >
              <Save className="w-4 h-4" />
              <span>Create Deal</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  );

  // Edit Deal Modal
  const EditDealModal = () => (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-2xl font-bold text-gray-900">Edit Deal</h2>
          <button
            onClick={() => setShowEditModal(false)}
            className="text-gray-500 hover:text-gray-700"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <form onSubmit={handleUpdateDeal} className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Deal Name *
              </label>
              <input
                type="text"
                required
                value={editFormData.name}
                onChange={(e) => setEditFormData({...editFormData, name: e.target.value})}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Category *
              </label>
              <select
                required
                value={editFormData.category}
                onChange={(e) => setEditFormData({...editFormData, category: e.target.value})}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
              >
                <option value="">Select category</option>
                {categories.map(category => (
                  <option key={category._id} value={category.name}>
                    {category.name}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Original Price *
              </label>
              <input
                type="number"
                required
                step="0.01"
                value={editFormData.originalPrice}
                onChange={(e) => setEditFormData({...editFormData, originalPrice: e.target.value})}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Deal Price *
              </label>
              <input
                type="number"
                required
                step="0.01"
                value={editFormData.price}
                onChange={(e) => setEditFormData({...editFormData, price: e.target.value})}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Discount Percentage *
              </label>
              <input
                type="number"
                required
                min="0"
                max="100"
                value={editFormData.discount}
                onChange={(e) => setEditFormData({...editFormData, discount: e.target.value})}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Maximum Quantity *
              </label>
              <input
                type="number"
                required
                min="1"
                value={editFormData.maxQuantity}
                onChange={(e) => setEditFormData({...editFormData, maxQuantity: e.target.value})}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Sold Quantity
              </label>
              <input
                type="number"
                min="0"
                value={editFormData.soldQuantity}
                onChange={(e) => setEditFormData({...editFormData, soldQuantity: e.target.value})}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Start Date *
              </label>
              <input
                type="date"
                required
                value={editFormData.startDate}
                onChange={(e) => setEditFormData({...editFormData, startDate: e.target.value})}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                End Date *
              </label>
              <input
                type="date"
                required
                value={editFormData.endDate}
                onChange={(e) => setEditFormData({...editFormData, endDate: e.target.value})}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Description
            </label>
            <textarea
              value={editFormData.description}
              onChange={(e) => setEditFormData({...editFormData, description: e.target.value})}
              rows="3"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Image URL
            </label>
            <input
              type="url"
              value={editFormData.imageUrl}
              onChange={(e) => setEditFormData({...editFormData, imageUrl: e.target.value})}
              placeholder="https://example.com/image.jpg"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
            />
            {editFormData.imageUrl && (
              <img 
                src={editFormData.imageUrl} 
                alt="Preview" 
                className="mt-2 w-32 h-32 object-cover rounded-lg"
              />
            )}
          </div>

          <div className="flex items-center space-x-4">
            <label className="flex items-center">
              <input
                type="checkbox"
                checked={editFormData.featured}
                onChange={(e) => setEditFormData({...editFormData, featured: e.target.checked})}
                className="mr-2"
              />
              <span className="text-sm font-medium text-gray-700">Featured Deal</span>
            </label>
          </div>

          <div className="flex justify-end space-x-4">
            <button
              type="button"
              onClick={() => setShowEditModal(false)}
              className="px-4 py-2 text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="px-4 py-2 bg-orange-600 text-white rounded-lg hover:bg-orange-700 transition-colors flex items-center space-x-2"
            >
              <Save className="w-4 h-4" />
              <span>Update Deal</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  );

  return (
    <div className="p-6">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Today's Deals</h1>
          <p className="text-gray-600 mt-2">Manage daily deals and promotions</p>
        </div>
        <button
          onClick={openCreateModal}
          className="flex items-center space-x-2 px-4 py-2 bg-orange-600 text-white rounded-lg hover:bg-orange-700 transition-colors"
        >
          <Plus className="w-4 h-4" />
          <span>Create Deal</span>
        </button>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">
        <div className="bg-white p-6 rounded-lg shadow-md border border-gray-200">
          <div className="flex items-center">
            <div className="p-2 bg-orange-100 rounded-lg">
              <Package className="w-6 h-6 text-orange-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Total Deals</p>
              <p className="text-2xl font-bold text-gray-900">{stats.totalDeals || deals.length}</p>
            </div>
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow-md border border-gray-200">
          <div className="flex items-center">
            <div className="p-2 bg-green-100 rounded-lg">
              <TrendingUp className="w-6 h-6 text-green-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Active Deals</p>
              <p className="text-2xl font-bold text-gray-900">{stats.activeDeals || deals.filter(d => !d.isExpired).length}</p>
            </div>
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow-md border border-gray-200">
          <div className="flex items-center">
            <div className="p-2 bg-yellow-100 rounded-lg">
              <Star className="w-6 h-6 text-yellow-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Featured Deals</p>
              <p className="text-2xl font-bold text-gray-900">{stats.featuredDeals || deals.filter(d => d.featured).length}</p>
            </div>
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow-md border border-gray-200">
          <div className="flex items-center">
            <div className="p-2 bg-red-100 rounded-lg">
              <AlertCircle className="w-6 h-6 text-red-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Expired Deals</p>
              <p className="text-2xl font-bold text-gray-900">{stats.expiredDeals || deals.filter(d => d.isExpired).length}</p>
            </div>
          </div>
        </div>
      </div>

      {/* Filters and Search */}
      <div className="bg-white p-4 rounded-lg shadow-md border border-gray-200 mb-6">
        <div className="flex flex-col md:flex-row md:items-center md:justify-between space-y-4 md:space-y-0">
          <div className="flex items-center space-x-4">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
              <input
                type="text"
                placeholder="Search deals..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
              />
            </div>
            <select
              value={filter}
              onChange={(e) => setFilter(e.target.value)}
              className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
            >
              <option value="all">All Deals</option>
              <option value="featured">Featured Only</option>
              <option value="active">Active Only</option>
              <option value="expired">Expired Only</option>
            </select>
          </div>
          <div className="flex items-center space-x-2">
            <button
              onClick={() => setViewMode('grid')}
              className={`p-2 rounded-lg transition-colors ${
                viewMode === 'grid' 
                  ? 'bg-orange-100 text-orange-600' 
                  : 'text-gray-600 hover:bg-gray-100'
              }`}
            >
              <Grid className="w-4 h-4" />
            </button>
            <button
              onClick={() => setViewMode('list')}
              className={`p-2 rounded-lg transition-colors ${
                viewMode === 'list' 
                  ? 'bg-orange-100 text-orange-600' 
                  : 'text-gray-600 hover:bg-gray-100'
              }`}
            >
              <List className="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>

      {/* Deals Grid/List */}
      {loading ? (
        <div className="flex items-center justify-center py-12">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-orange-600"></div>
        </div>
      ) : deals.length === 0 ? (
        <div className="text-center py-12">
          <Package className="w-12 h-12 text-gray-400 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">No deals found</h3>
          <p className="text-gray-600">Create your first deal to get started.</p>
        </div>
      ) : (
        <div className={viewMode === 'grid' 
          ? 'grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6' 
          : 'space-y-4'
        }>
          {deals.map((deal) => (
            <DealCard key={deal._id} deal={deal} />
          ))}
        </div>
      )}

      {/* Debug section */}
      {deals.length > 0 && (
        <div className="mt-8 p-4 bg-gray-100 rounded-lg">
          <h4 className="font-semibold mb-2">Debug Info:</h4>
          <p>Total deals: {deals.length}</p>
          <p>First deal sample: {JSON.stringify(deals[0] || {}, null, 2)}</p>
          <div className="mt-4">
            <h5 className="font-medium mb-2">Deal Statistics:</h5>
            <ul className="text-sm space-y-1">
              <li>Featured deals: {deals.filter(d => d.featured).length}</li>
              <li>Expired deals: {deals.filter(d => d.isExpired).length}</li>
              <li>Valid deals: {deals.filter(d => d.isValid).length}</li>
              <li>Categories: {[...new Set(deals.map(d => d.category))].join(', ')}</li>
            </ul>
          </div>
        </div>
      )}

      {/* Modals */}
      {showCreateModal && <CreateDealModal />}
      {showEditModal && <EditDealModal />}
    </div>
  );
};

export default TodayDeals; 