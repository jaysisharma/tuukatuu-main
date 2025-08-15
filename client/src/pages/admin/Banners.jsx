import React, { useState, useEffect, useRef } from 'react';
import { 
  Plus, 
  Edit, 
  Trash2, 
  Eye, 
  Star, 
  Calendar,
  BarChart3,
  Search,
  Filter,
  MoreVertical,
  Image as ImageIcon,
  TrendingUp,
  Target,
  Palette,
  Link as LinkIcon
} from 'lucide-react';
import { toast } from 'react-hot-toast';
import { api } from '../../api';
import Table from '../../components/Table';
import Skeleton from '../../components/Skeleton';
import Loader from '../../components/Loader';
import * as Dialog from '@radix-ui/react-dialog';

export default function Banners() {
  const [banners, setBanners] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [search, setSearch] = useState('');
  const [filter, setFilter] = useState('all');
  const [type, setType] = useState('');
  const [category, setCategory] = useState('');
  const [stats, setStats] = useState(null);
  const searchTimeout = useRef(null);
  const [selectedBanner, setSelectedBanner] = useState(null);
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [showEditModal, setShowEditModal] = useState(false);
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const [showAnalyticsModal, setShowAnalyticsModal] = useState(false);
  const [updatingBanner, setUpdatingBanner] = useState(null);

  const pageSize = 20;

  const bannerTypes = [
    { value: '', label: 'All Types' },
    { value: 'regular', label: 'Regular' },
    { value: 'tmart', label: 'T-Mart' },
    { value: 'hero', label: 'Hero' },
    { value: 'category', label: 'Category' },
    { value: 'promotional', label: 'Promotional' },
    { value: 'deal', label: 'Deal' }
  ];

  const categories = [
    { value: '', label: 'All Categories' },
    { value: 'restaurant', label: 'Restaurant' },
    { value: 'grocery', label: 'Grocery' },
    { value: 'pharmacy', label: 'Pharmacy' },
    { value: 'general', label: 'General' }
  ];

  const filters = [
    { value: 'all', label: 'All Banners' },
    { value: 'active', label: 'Active' },
    { value: 'inactive', label: 'Inactive' },
    { value: 'featured', label: 'Featured' },
    { value: 'expired', label: 'Expired' }
  ];

  useEffect(() => {
    loadBanners();
    loadStats();
  }, [page, filter, type, category]);

  useEffect(() => {
    if (searchTimeout.current) clearTimeout(searchTimeout.current);
    searchTimeout.current = setTimeout(() => {
      loadBanners({ page: 1 });
      setPage(1);
    }, 400);
    return () => clearTimeout(searchTimeout.current);
  }, [search]);

  const loadBanners = async (opts = {}) => {
    setLoading(true);
    setError('');
    try {
      const params = new URLSearchParams({
        page: opts.page ?? page,
        limit: pageSize,
        ...(search && { search }),
        ...(filter !== 'all' && { filter }),
        ...(type && { type }),
        ...(category && { category })
      });

      const response = await api.get(`/admin/banners?${params}`);
      setBanners(response.data);
      setTotalPages(response.pagination.pages);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const loadStats = async () => {
    try {
      const response = await api.get('/admin/banners/statistics');
      setStats(response.data);
    } catch (err) {
      console.error('Failed to load stats:', err);
    }
  };

  const handleCreateBanner = async (formData) => {
    try {
      setLoading(true);
      await api.upload('/admin/banners', formData);
      toast.success('Banner created successfully');
      setShowCreateModal(false);
      loadBanners();
      loadStats();
    } catch (err) {
      toast.error(err.message || 'Failed to create banner');
    } finally {
      setLoading(false);
    }
  };

  const handleUpdateBanner = async (id, formData) => {
    try {
      setUpdatingBanner(id);
      await api.uploadPut(`/admin/banners/${id}`, formData);
      toast.success('Banner updated successfully');
      setShowEditModal(false);
      loadBanners();
      loadStats();
    } catch (err) {
      toast.error(err.message || 'Failed to update banner');
    } finally {
      setUpdatingBanner(null);
    }
  };

  const handleDelete = async (id) => {
    try {
      setLoading(true);
      await api.del(`/admin/banners/${id}`);
      toast.success('Banner deleted successfully');
      setShowDeleteModal(false);
      loadBanners();
      loadStats();
    } catch (err) {
      toast.error(err.message || 'Failed to delete banner');
    } finally {
      setLoading(false);
    }
  };

  const handleToggleStatus = async (id, field) => {
    try {
      await api.patch(`/admin/banners/${id}/toggle-status?field=${field}`);
      toast.success(`Banner ${field} toggled successfully`);
      loadBanners();
      loadStats();
    } catch (err) {
      toast.error(err.message || `Failed to toggle ${field}`);
    }
  };

  const handleViewAnalytics = async (id) => {
    try {
      const response = await api.get(`/admin/banners/${id}/analytics`);
      setSelectedBanner({ ...selectedBanner, analytics: response.data });
      setShowAnalyticsModal(true);
    } catch (err) {
      toast.error(err.message || 'Failed to load analytics');
    }
  };

  const columns = [
    { 
      key: 'image', 
      title: 'Image', 
      render: b => b.image ? 
        <img src={b.image} alt={b.title} className="w-16 h-10 rounded object-cover" /> : 
        <div className="w-16 h-10 bg-gray-200 rounded flex items-center justify-center">
          <ImageIcon className="w-5 h-5 text-gray-400" />
        </div>
    },
    { key: 'title', title: 'Title' },
    { key: 'subtitle', title: 'Subtitle' },
    { 
      key: 'bannerType', 
      title: 'Type', 
      render: b => (
        <span className={`px-2 py-1 rounded text-xs font-medium ${
          b.bannerType === 'tmart' ? 'bg-blue-100 text-blue-800' :
          b.bannerType === 'hero' ? 'bg-purple-100 text-purple-800' :
          b.bannerType === 'category' ? 'bg-green-100 text-green-800' :
          b.bannerType === 'promotional' ? 'bg-orange-100 text-orange-800' :
          b.bannerType === 'deal' ? 'bg-red-100 text-red-800' :
          'bg-gray-100 text-gray-800'
        }`}>
          {b.bannerType}
        </span>
      )
    },
    { 
      key: 'category', 
      title: 'Category', 
      render: b => b.category || '-'
    },
    { 
      key: 'status', 
      title: 'Status', 
      render: b => (
        <div className="flex flex-col gap-1">
          <span className={`px-2 py-1 rounded text-xs font-medium ${
            b.isActive ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
          }`}>
            {b.isActive ? 'Active' : 'Inactive'}
          </span>
          {b.isFeatured && (
            <span className="px-2 py-1 rounded text-xs font-medium bg-yellow-100 text-yellow-800">
              Featured
            </span>
          )}
        </div>
      )
    },
    { 
      key: 'analytics', 
      title: 'Analytics', 
      render: b => (
        <div className="text-xs text-gray-600">
          <div>👁️ {b.impressions || 0}</div>
          <div>🖱️ {b.clicks || 0}</div>
          <div>📊 {b.ctr || '0%'}</div>
        </div>
      )
    },
    { 
      key: 'actions', 
      title: 'Actions', 
      render: b => (
        <div className="flex gap-2">
          <button 
            className="text-xs bg-blue-500 text-white px-2 py-1 rounded hover:bg-blue-600"
            onClick={() => { setSelectedBanner(b); setShowAnalyticsModal(true); }}
            title="View Analytics"
          >
            <BarChart3 className="w-3 h-3" />
          </button>
          <button 
            className="text-xs bg-green-500 text-white px-2 py-1 rounded hover:bg-green-600"
            onClick={() => { setSelectedBanner(b); setShowEditModal(true); }}
            title="Edit"
          >
            <Edit className="w-3 h-3" />
          </button>
          <button 
            className="text-xs bg-red-500 text-white px-2 py-1 rounded hover:bg-red-600"
            onClick={() => { setSelectedBanner(b); setShowDeleteModal(true); }}
            title="Delete"
          >
            <Trash2 className="w-3 h-3" />
          </button>
        </div>
      )
    },
  ];

  const data = banners.map(b => ({ ...b }));

  return (
    <div className="min-h-screen bg-bg flex items-start justify-center pt-10">
      <div className="max-w-7xl w-full bg-surface rounded-xl shadow-lg p-8 border border-border">
        {/* Header */}
        <div className="flex justify-between items-center mb-6">
          <div>
            <h1 className="text-3xl font-bold text-primary">Banner Management</h1>
            <p className="text-gray-600 mt-1">Manage all banner types in one place</p>
          </div>
          <button 
            className="bg-primary text-white px-4 py-2 rounded font-semibold hover:bg-primary-dark transition flex items-center gap-2"
            onClick={() => { setSelectedBanner(null); setShowCreateModal(true); }}
          >
            <Plus className="w-4 h-4" />
            Add Banner
          </button>
        </div>

        {/* Stats Cards */}
        {stats && (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
            {stats.map((stat, index) => (
              <div key={index} className="bg-white p-4 rounded-lg border border-border">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm text-gray-600 capitalize">{stat._id || 'All Types'}</p>
                    <p className="text-2xl font-bold text-primary">{stat.total}</p>
                  </div>
                  <div className="text-right text-sm text-gray-600">
                    <div>Active: {stat.active}</div>
                    <div>Featured: {stat.featured}</div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Filters */}
        <div className="bg-white p-4 rounded-lg border border-border mb-6">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Search</label>
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-400" />
                <input
                  type="text"
                  placeholder="Search banners..."
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                  className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
                />
              </div>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Filter</label>
              <select
                value={filter}
                onChange={(e) => setFilter(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
              >
                {filters.map(f => (
                  <option key={f.value} value={f.value}>{f.label}</option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Type</label>
              <select
                value={type}
                onChange={(e) => setType(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
              >
                {bannerTypes.map(t => (
                  <option key={t.value} value={t.value}>{t.label}</option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Category</label>
              <select
                value={category}
                onChange={(e) => setCategory(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
              >
                {categories.map(c => (
                  <option key={c.value} value={c.value}>{c.label}</option>
                ))}
              </select>
            </div>
            <div className="flex items-end">
              <button
                onClick={() => loadBanners()}
                className="w-full bg-gray-500 text-white px-4 py-2 rounded hover:bg-gray-600 transition"
              >
                <Filter className="w-4 h-4 inline mr-2" />
                Apply
              </button>
            </div>
          </div>
        </div>

        {/* Table */}
        <Table columns={columns} data={data} loading={loading} error={error} />

        {/* Pagination */}
        {totalPages > 1 && (
          <div className="flex justify-center items-center gap-2 mt-6">
            <button
              onClick={() => setPage(p => Math.max(1, p - 1))}
              disabled={page === 1}
              className="px-3 py-2 border border-gray-300 rounded disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-50"
            >
              Previous
            </button>
            <span className="px-3 py-2">
              Page {page} of {totalPages}
            </span>
            <button
              onClick={() => setPage(p => Math.min(totalPages, p + 1))}
              disabled={page === totalPages}
              className="px-3 py-2 border border-gray-300 rounded disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-50"
            >
              Next
            </button>
          </div>
        )}

        {/* Modals will be added here */}
        <Dialog.Root open={showCreateModal} onOpenChange={setShowCreateModal}>
          <Dialog.Portal>
            <Dialog.Overlay className="fixed inset-0 bg-black/30 z-40" />
            <Dialog.Content className="fixed z-50 left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 bg-surface p-8 rounded-xl shadow-lg border border-border w-full max-w-2xl max-h-[90vh] overflow-y-auto">
              <BannerModal 
                mode="create" 
                onClose={() => setShowCreateModal(false)} 
                onSubmit={handleCreateBanner} 
                loading={loading} 
              />
            </Dialog.Content>
          </Dialog.Portal>
        </Dialog.Root>

        <Dialog.Root open={showEditModal} onOpenChange={setShowEditModal}>
          <Dialog.Portal>
            <Dialog.Overlay className="fixed inset-0 bg-black/30 z-40" />
            <Dialog.Content className="fixed z-50 left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 bg-surface p-8 rounded-xl shadow-lg border border-border w-full max-w-2xl max-h-[90vh] overflow-y-auto">
              <BannerModal 
                mode="edit" 
                banner={selectedBanner} 
                onClose={() => setShowEditModal(false)} 
                onSubmit={(formData) => handleUpdateBanner(selectedBanner._id, formData)} 
                loading={updatingBanner === selectedBanner?._id} 
              />
            </Dialog.Content>
          </Dialog.Portal>
        </Dialog.Root>

        <Dialog.Root open={showDeleteModal} onOpenChange={setShowDeleteModal}>
          <Dialog.Portal>
            <Dialog.Overlay className="fixed inset-0 bg-black/30 z-40" />
            <Dialog.Content className="fixed z-50 left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 bg-surface p-6 rounded-xl shadow-lg border border-border w-full max-w-md">
              <DeleteBannerModal 
                banner={selectedBanner} 
                onClose={() => setShowDeleteModal(false)} 
                onConfirm={() => handleDelete(selectedBanner._id)} 
                loading={loading} 
              />
            </Dialog.Content>
          </Dialog.Portal>
        </Dialog.Root>

        <Dialog.Root open={showAnalyticsModal} onOpenChange={setShowAnalyticsModal}>
          <Dialog.Portal>
            <Dialog.Overlay className="fixed inset-0 bg-black/30 z-40" />
            <Dialog.Content className="fixed z-50 left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 bg-surface p-6 rounded-xl shadow-lg border border-border w-full max-w-md">
              <AnalyticsModal 
                banner={selectedBanner} 
                onClose={() => setShowAnalyticsModal(false)} 
              />
            </Dialog.Content>
          </Dialog.Portal>
        </Dialog.Root>
      </div>
    </div>
  );
}

// Banner Modal Component
const BannerModal = ({ mode, banner, onClose, onSubmit, loading }) => {
  const [form, setForm] = useState({
    title: banner?.title || '',
    subtitle: banner?.subtitle || '',
    description: banner?.description || '',
    imageAlt: banner?.imageAlt || '',
    link: banner?.link || '',
    linkType: banner?.linkType || 'none',
    linkTarget: banner?.linkTarget || '',
    bannerType: banner?.bannerType || 'regular',
    category: banner?.category || 'general',
    sortOrder: banner?.sortOrder || 0,
    priority: banner?.priority || 1,
    backgroundColor: banner?.backgroundColor || '#FF6B35',
    textColor: banner?.textColor || '#FFFFFF',
    isActive: banner?.isActive ?? true,
    isFeatured: banner?.isFeatured ?? false,
    startDate: banner?.startDate ? new Date(banner.startDate).toISOString().split('T')[0] : '',
    endDate: banner?.endDate ? new Date(banner.endDate).toISOString().split('T')[0] : '',
    targetAudience: banner?.targetAudience || []
  });
  const [imageFile, setImageFile] = useState(null);
  const [imagePreview, setImagePreview] = useState(banner?.image || '');
  const [error, setError] = useState('');

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setForm(f => ({ 
      ...f, 
      [name]: type === 'checkbox' ? checked : 
               type === 'number' ? parseFloat(value) || 0 : value 
    }));
  };

  const handleImageChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      setImageFile(file);
      const reader = new FileReader();
      reader.onloadend = () => setImagePreview(reader.result);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');

    if (!form.title) {
      setError('Title is required');
      return;
    }

    if (mode === 'create' && !imageFile) {
      setError('Image is required');
      return;
    }

    const formData = new FormData();
    Object.keys(form).forEach(key => {
      if (form[key] !== undefined && form[key] !== '') {
        if (Array.isArray(form[key])) {
          form[key].forEach(item => formData.append(key, item));
        } else {
          formData.append(key, form[key]);
        }
      }
    });

    if (imageFile) {
      formData.append('image', imageFile);
    }

    onSubmit(formData);
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <h2 className="text-2xl font-bold mb-4 text-primary">
        {mode === 'create' ? 'Create New Banner' : 'Edit Banner'}
      </h2>
      
      {error && <div className="text-red-500 text-sm">{error}</div>}

      {/* Basic Information */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Title *</label>
          <input
            name="title"
            value={form.title}
            onChange={handleChange}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
            required
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Subtitle</label>
          <input
            name="subtitle"
            value={form.subtitle}
            onChange={handleChange}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
          />
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
        <textarea
          name="description"
          value={form.description}
          onChange={handleChange}
          rows={3}
          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
        />
      </div>

      {/* Banner Type and Category */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Banner Type</label>
          <select
            name="bannerType"
            value={form.bannerType}
            onChange={handleChange}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
          >
            <option value="regular">Regular</option>
            <option value="tmart">T-Mart</option>
            <option value="hero">Hero</option>
            <option value="category">Category</option>
            <option value="promotional">Promotional</option>
            <option value="deal">Deal</option>
          </select>
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Category</label>
          <select
            name="category"
            value={form.category}
            onChange={handleChange}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
          >
            <option value="general">General</option>
            <option value="restaurant">Restaurant</option>
            <option value="grocery">Grocery</option>
            <option value="pharmacy">Pharmacy</option>
          </select>
        </div>
      </div>

      {/* Image Upload */}
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">
          Banner Image {mode === 'create' ? '*' : ''}
        </label>
        <input
          type="file"
          accept="image/*"
          onChange={handleImageChange}
          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
        />
        {imagePreview && (
          <div className="mt-2">
            <img src={imagePreview} alt="Preview" className="w-32 h-20 object-cover rounded border" />
          </div>
        )}
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">Image Alt Text</label>
        <input
          name="imageAlt"
          value={form.imageAlt}
          onChange={handleChange}
          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
        />
      </div>

      {/* Link Configuration */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Link</label>
          <input
            name="link"
            value={form.link}
            onChange={handleChange}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Link Type</label>
          <select
            name="linkType"
            value={form.linkType}
            onChange={handleChange}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
          >
            <option value="none">None</option>
            <option value="product">Product</option>
            <option value="category">Category</option>
            <option value="external">External</option>
          </select>
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Link Target</label>
          <input
            name="linkTarget"
            value={form.linkTarget}
            onChange={handleChange}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
          />
        </div>
      </div>

      {/* Display Settings */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Sort Order</label>
          <input
            type="number"
            name="sortOrder"
            value={form.sortOrder}
            onChange={handleChange}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Priority</label>
          <input
            type="number"
            name="priority"
            value={form.priority}
            onChange={handleChange}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
          />
        </div>
      </div>

      {/* Colors */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Background Color</label>
          <input
            type="color"
            name="backgroundColor"
            value={form.backgroundColor}
            onChange={handleChange}
            className="w-full h-10 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Text Color</label>
          <input
            type="color"
            name="textColor"
            value={form.textColor}
            onChange={handleChange}
            className="w-full h-10 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
          />
        </div>
      </div>

      {/* Scheduling */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Start Date</label>
          <input
            type="date"
            name="startDate"
            value={form.startDate}
            onChange={handleChange}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">End Date</label>
          <input
            type="date"
            name="endDate"
            value={form.endDate}
            onChange={handleChange}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
          />
        </div>
      </div>

      {/* Status Toggles */}
      <div className="flex gap-6">
        <label className="flex items-center gap-2">
          <input
            type="checkbox"
            name="isActive"
            checked={form.isActive}
            onChange={handleChange}
            className="rounded border-gray-300 text-primary focus:ring-primary"
          />
          <span className="text-sm font-medium text-gray-700">Active</span>
        </label>
        <label className="flex items-center gap-2">
          <input
            type="checkbox"
            name="isFeatured"
            checked={form.isFeatured}
            onChange={handleChange}
            className="rounded border-gray-300 text-primary focus:ring-primary"
          />
          <span className="text-sm font-medium text-gray-700">Featured</span>
        </label>
      </div>

      {/* Actions */}
      <div className="flex gap-3 justify-end pt-4 border-t">
        <button
          type="button"
          onClick={onClose}
          className="px-4 py-2 text-gray-700 bg-gray-200 rounded-md hover:bg-gray-300 transition"
          disabled={loading}
        >
          Cancel
        </button>
        <button
          type="submit"
          className="px-4 py-2 bg-primary text-white rounded-md hover:bg-primary-dark transition disabled:opacity-50"
          disabled={loading}
        >
          {loading ? 'Saving...' : (mode === 'create' ? 'Create Banner' : 'Update Banner')}
        </button>
      </div>
    </form>
  );
};

// Delete Confirmation Modal
const DeleteBannerModal = ({ banner, onClose, onConfirm, loading }) => {
  return (
    <div>
      <h2 className="text-2xl font-bold mb-4 text-red-600">Delete Banner</h2>
      <div className="mb-6">
        <p className="text-gray-700 mb-2">
          Are you sure you want to delete this banner?
        </p>
        <div className="bg-gray-50 p-3 rounded border">
          <p className="font-semibold">{banner?.title}</p>
          <p className="text-sm text-gray-600">Type: {banner?.bannerType}</p>
          <p className="text-sm text-gray-600">Category: {banner?.category}</p>
        </div>
        <p className="text-sm text-red-600 mt-2">
          This action cannot be undone.
        </p>
      </div>
      <div className="flex gap-3 justify-end">
        <button
          onClick={onClose}
          className="px-4 py-2 text-gray-700 bg-gray-200 rounded-md hover:bg-gray-300 transition"
          disabled={loading}
        >
          Cancel
        </button>
        <button
          onClick={onConfirm}
          className="px-4 py-2 bg-red-600 text-white rounded-md hover:bg-red-700 transition disabled:opacity-50"
          disabled={loading}
        >
          {loading ? 'Deleting...' : 'Delete Banner'}
        </button>
      </div>
    </div>
  );
};

// Analytics Modal
const AnalyticsModal = ({ banner, onClose }) => {
  if (!banner?.analytics) {
    return (
      <div>
        <h2 className="text-2xl font-bold mb-4 text-primary">Banner Analytics</h2>
        <p className="text-gray-600">No analytics data available for this banner.</p>
        <div className="flex justify-end mt-4">
          <button
            onClick={onClose}
            className="px-4 py-2 bg-gray-200 text-gray-700 rounded-md hover:bg-gray-300 transition"
          >
            Close
          </button>
        </div>
      </div>
    );
  }

  const { analytics } = banner;

  return (
    <div>
      <h2 className="text-2xl font-bold mb-4 text-primary">Banner Analytics</h2>
      <div className="space-y-4">
        <div className="bg-blue-50 p-4 rounded-lg border border-blue-200">
          <h3 className="font-semibold text-blue-800 mb-2">Performance Metrics</h3>
          <div className="grid grid-cols-2 gap-4 text-sm">
            <div>
              <p className="text-blue-600">Impressions</p>
              <p className="text-2xl font-bold text-blue-800">{analytics.impressions}</p>
            </div>
            <div>
              <p className="text-blue-600">Clicks</p>
              <p className="text-2xl font-bold text-blue-800">{analytics.clicks}</p>
            </div>
          </div>
          <div className="mt-3">
            <p className="text-blue-600">Click-Through Rate</p>
            <p className="text-xl font-bold text-blue-800">{analytics.ctr}%</p>
          </div>
        </div>
        
        <div className="bg-gray-50 p-4 rounded-lg border border-gray-200">
          <h3 className="font-semibold text-gray-800 mb-2">Banner Details</h3>
          <div className="space-y-2 text-sm">
            <div className="flex justify-between">
              <span className="text-gray-600">Status:</span>
              <span className={`font-medium ${
                analytics.status === 'active' ? 'text-green-600' : 
                analytics.status === 'inactive' ? 'text-red-600' : 'text-yellow-600'
              }`}>
                {analytics.status}
              </span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600">Created:</span>
              <span className="font-medium">{new Date(analytics.createdAt).toLocaleDateString()}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600">Updated:</span>
              <span className="font-medium">{new Date(analytics.updatedAt).toLocaleDateString()}</span>
            </div>
          </div>
        </div>
      </div>
      
      <div className="flex justify-end mt-6">
        <button
          onClick={onClose}
          className="px-4 py-2 bg-gray-200 text-gray-700 rounded-md hover:bg-gray-300 transition"
        >
          Close
        </button>
      </div>
    </div>
  );
}; 