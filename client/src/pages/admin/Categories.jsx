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
  Merge, 
  Search,
  Filter,
  Grid,
  List,
  Eye,
  EyeOff,
  ArrowUp,
  ArrowDown
} from 'lucide-react';

const Categories = () => {
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState({});
  const [searchTerm, setSearchTerm] = useState('');
  const [filter, setFilter] = useState('all');
  const [viewMode, setViewMode] = useState('grid');
  const [showCombinedForm, setShowCombinedForm] = useState(false);
  const [editingCategory, setEditingCategory] = useState(null);
  const [selectedCategories, setSelectedCategories] = useState([]);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [uploadingImage, setUploadingImage] = useState(false);
  const [showEditModal, setShowEditModal] = useState(false);
  const [editingCategoryData, setEditingCategoryData] = useState({});
  const [uploadingCategoryImage, setUploadingCategoryImage] = useState(false);

  // Combined category form state
  const [combinedData, setCombinedData] = useState({
    name: '',
    displayName: '',
    description: '',
    color: 'green',
    combinedCategories: [],
    imageFile: null
  });

  useEffect(() => {
    loadCategories();
    loadStats();
  }, [currentPage, searchTerm, filter]);

  const loadCategories = async () => {
    try {
      setLoading(true);
      const params = new URLSearchParams({
        page: currentPage,
        limit: 20,
        ...(searchTerm && { search: searchTerm }),
        ...(filter !== 'all' && { [filter]: true })
      });

      const response = await api.get(`/admin/categories?${params}`);
      setCategories(response.data);
      setTotalPages(response.pagination.pages);
    } catch (error) {
      toast.error('Failed to load categories');
      console.error('Error loading categories:', error);
    } finally {
      setLoading(false);
    }
  };

  const loadStats = async () => {
    try {
      const response = await api.get('/admin/categories/stats');
      setStats(response.data);
    } catch (error) {
      console.error('Error loading stats:', error);
    }
  };

  const handleImageUpload = async (file) => {
    try {
      setUploadingImage(true);
      const formData = new FormData();
      formData.append('image', file);
      
      const response = await api.upload('/admin/categories/upload-image', formData);
      
      setCombinedData(prev => ({
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

  const handleEditCategory = (category) => {
    setEditingCategoryData({
      _id: category._id,
      name: category.name,
      displayName: category.displayName,
      description: category.description,
      color: category.color,
      imageUrl: category.imageUrl,
      isActive: category.isActive,
      isFeatured: category.isFeatured,
      sortOrder: category.sortOrder
    });
    setShowEditModal(true);
  };

  const handleCategoryImageUpload = async (file, categoryId) => {
    try {
      setUploadingCategoryImage(true);
      const formData = new FormData();
      formData.append('image', file);
      
      const response = await api.upload(`/admin/categories/${categoryId}/upload-image`, formData);
      
      setEditingCategoryData(prev => ({
        ...prev,
        imageUrl: response.data.imageUrl
      }));
      
      // Update the category in the list
      setCategories(prev => prev.map(cat => 
        cat._id === categoryId 
          ? { ...cat, imageUrl: response.data.imageUrl }
          : cat
      ));
      
      toast.success('Category image updated successfully');
    } catch (error) {
      toast.error('Failed to update category image');
    } finally {
      setUploadingCategoryImage(false);
    }
  };

  const handleUpdateCategory = async (e) => {
    e.preventDefault();
    try {
      const response = await api.put(`/admin/categories/${editingCategoryData._id}`, {
        name: editingCategoryData.name,
        displayName: editingCategoryData.displayName,
        description: editingCategoryData.description,
        color: editingCategoryData.color,
        imageUrl: editingCategoryData.imageUrl,
        isActive: editingCategoryData.isActive,
        isFeatured: editingCategoryData.isFeatured,
        sortOrder: editingCategoryData.sortOrder
      });

      // Update the category in the list
      setCategories(prev => prev.map(cat => 
        cat._id === editingCategoryData._id 
          ? { ...cat, ...editingCategoryData }
          : cat
      ));

      toast.success('Category updated successfully');
      setShowEditModal(false);
      setEditingCategoryData({});
    } catch (error) {
      toast.error('Failed to update category');
    }
  };

  const handleDelete = async (categoryId) => {
    if (!window.confirm('Are you sure you want to delete this category?')) return;
    
    try {
      await api.del(`/admin/categories/${categoryId}`);
      toast.success('Category deleted successfully');
      loadCategories();
      loadStats();
    } catch (error) {
      toast.error(error.message || 'Failed to delete category');
    }
  };

  const handleToggleFeatured = async (categoryId) => {
    try {
      await api.patch(`/admin/categories/${categoryId}/toggle-featured`);
      toast.success('Featured status updated');
      loadCategories();
    } catch (error) {
      toast.error(error.message || 'Failed to update featured status');
    }
  };



  const handleCombined = async (e) => {
    e.preventDefault();
    console.log('🚀 handleCombined called');
    console.log('📝 Form data:', combinedData);
    
    // Basic validation
    if (!combinedData.name.trim()) {
      toast.error('Please enter a category name');
      return;
    }
    
    if (combinedData.combinedCategories.length < 2) {
      toast.error('Please select at least 2 individual categories to combine');
      return;
    }
    
    try {
      console.log('✅ Making API call to /categories/combined');
      const response = await api.post('/admin/categories/combined', combinedData);
      console.log('✅ API response:', response);
      toast.success('Combined category created successfully');
      setShowCombinedForm(false);
      resetCombinedForm();
      loadCategories();
      loadStats();
    } catch (error) {
      console.error('❌ API error:', error);
      toast.error(error.message || 'Failed to create combined category');
    }
  };

  const resetCombinedForm = () => {
    setCombinedData({
      name: '',
      displayName: '',
      description: '',
      color: 'green',
      combinedCategories: [],
      imageFile: null,
      imageUrl: ''
    });
  };



  const getColorClass = (color) => {
    const colorMap = {
      green: 'bg-green-100 text-green-800',
      blue: 'bg-blue-100 text-blue-800',
      orange: 'bg-orange-100 text-orange-800',
      red: 'bg-red-100 text-red-800',
      purple: 'bg-purple-100 text-purple-800',
      cyan: 'bg-cyan-100 text-cyan-800',
      indigo: 'bg-indigo-100 text-indigo-800',
      pink: 'bg-pink-100 text-pink-800',
      teal: 'bg-teal-100 text-teal-800',
      amber: 'bg-amber-100 text-amber-800',
      deepPurple: 'bg-purple-200 text-purple-900',
      lightBlue: 'bg-blue-200 text-blue-900',
      yellow: 'bg-yellow-100 text-yellow-800',
      brown: 'bg-amber-200 text-amber-900'
    };
    return colorMap[color] || 'bg-gray-100 text-gray-800';
  };

  const suggestAlternativeName = (baseName, existingNames) => {
    const base = baseName.trim();
    let counter = 1;
    let suggestion = `${base} ${counter}`;
    
    while (existingNames.some(name => name.toLowerCase() === suggestion.toLowerCase())) {
      counter++;
      suggestion = `${base} ${counter}`;
    }
    
    return suggestion;
  };

  const CategoryCard = ({ category }) => (
    <div className="bg-white rounded-lg shadow-md p-6 border border-gray-200">
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center space-x-3">
          {category.imageUrl ? (
            <img 
              src={category.imageUrl} 
              alt={category.name}
              className="w-12 h-12 rounded-lg object-cover"
            />
          ) : (
            <div className={`w-12 h-12 rounded-lg flex items-center justify-center ${getColorClass(category.color)}`}>
              <span className="text-lg font-semibold">{category.name.charAt(0)}</span>
            </div>
          )}
          <div>
            <h3 className="font-semibold text-gray-900">{category.displayName}</h3>
            <p className="text-sm text-gray-500">{category.name}</p>
          </div>
        </div>
        <div className="flex items-center space-x-2">
          <button
            onClick={() => handleEditCategory(category)}
            className="p-2 text-blue-600 hover:bg-blue-50 rounded-full"
            title="Edit category"
          >
            <Edit size={16} />
          </button>

          <button
            onClick={() => handleToggleFeatured(category._id)}
            className={`p-2 rounded-full ${category.isFeatured ? 'text-yellow-500' : 'text-gray-400'}`}
            title={category.isFeatured ? 'Remove from featured' : 'Mark as featured'}
          >
            {category.isFeatured ? <Star size={16} /> : <StarOff size={16} />}
          </button>

          <button
            onClick={() => handleDelete(category._id)}
            className="p-2 text-red-600 hover:bg-red-50 rounded-full"
            title="Delete category"
          >
            <Trash2 size={16} />
          </button>
        </div>
      </div>
      
      {category.description && (
        <p className="text-sm text-gray-600 mb-3">{category.description}</p>
      )}
      
      {category.combinedCategories && category.combinedCategories.length > 0 && (
        <div className="mb-3">
          <p className="text-xs text-gray-500 mb-1">Combines:</p>
          <div className="flex flex-wrap gap-1">
            {category.combinedCategories.map((cat, index) => (
              <span key={index} className="px-2 py-1 bg-gray-100 text-gray-600 rounded text-xs">
                {cat}
              </span>
            ))}
          </div>
        </div>
      )}
      
      <div className="flex items-center justify-between text-sm text-gray-500">
        <span className={`px-2 py-1 rounded-full text-xs ${getColorClass(category.color)}`}>
          {category.color}
        </span>
        <span>Products: {category.productCount || 0}</span>
      </div>
      
      <div className="mt-4 flex items-center justify-between">
        <div className="flex items-center space-x-2">
          <span className={`px-2 py-1 rounded text-xs ${category.isActive ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>
            {category.isActive ? 'Active' : 'Inactive'}
          </span>
          {category.isFeatured && (
            <span className="px-2 py-1 rounded text-xs bg-yellow-100 text-yellow-800">
              Featured
            </span>
          )}
          {category.combinedCategories && category.combinedCategories.length > 0 && (
            <span className="px-2 py-1 rounded text-xs bg-purple-100 text-purple-800">
              Combined
            </span>
          )}
        </div>
        <span className="text-xs text-gray-400">Order: {category.sortOrder}</span>
      </div>
    </div>
  );



  const CombinedForm = () => (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 w-full max-w-lg max-h-[90vh] overflow-y-auto">
        <h2 className="text-xl font-semibold mb-4">Create Combined Category</h2>
        
        <form onSubmit={handleCombined} className="space-y-4">
          {/* Step 1: Select Categories */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Step 1: Select Individual Categories to Combine *
            </label>
            <div className="space-y-2 max-h-40 overflow-y-auto border border-gray-200 rounded-md p-3">
              {categories.filter(cat => !cat.combinedCategories || cat.combinedCategories.length === 0).map(category => (
                <label key={category._id} className="flex items-center hover:bg-gray-50 p-2 rounded">
                  <input
                    type="checkbox"
                    checked={combinedData.combinedCategories.includes(category.name)}
                    onChange={(e) => {
                      if (e.target.checked) {
                        setCombinedData({
                          ...combinedData,
                          combinedCategories: [...combinedData.combinedCategories, category.name]
                        });
                      } else {
                        setCombinedData({
                          ...combinedData,
                          combinedCategories: combinedData.combinedCategories.filter(name => name !== category.name)
                        });
                      }
                    }}
                    className="mr-3"
                  />
                  <div>
                    <div className="font-medium">{category.displayName}</div>
                    <div className="text-sm text-gray-500">{category.name}</div>
                  </div>
                </label>
              ))}
            </div>
            {combinedData.combinedCategories.length > 0 && (
              <div className="mt-2">
                <p className="text-sm text-gray-600">Selected: {combinedData.combinedCategories.join(', ')}</p>
              </div>
            )}
          </div>
          
          {/* Step 2: Category Details */}
          <div className="border-t pt-4">
            <h3 className="text-lg font-medium mb-3">Step 2: Category Details</h3>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Combined Category Name *
                </label>
                <div className="flex space-x-2">
                  <input
                    type="text"
                    value={combinedData.name}
                    onChange={(e) => setCombinedData({
                      ...combinedData,
                      name: e.target.value
                    })}
                    className="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    required
                    placeholder="e.g., Dairy & Eggs"
                  />
                  {combinedData.combinedCategories.length >= 2 && (
                    <button
                      type="button"
                      onClick={() => {
                        const existingNames = categories.map(cat => cat.name);
                        const autoName = combinedData.combinedCategories.join(' & ');
                        const finalName = suggestAlternativeName(autoName, existingNames);
                        setCombinedData({
                          ...combinedData,
                          name: finalName,
                          displayName: finalName
                        });
                      }}
                      className="px-3 py-2 bg-blue-100 text-blue-700 rounded-md hover:bg-blue-200 text-sm"
                    >
                      Auto
                    </button>
                  )}
                </div>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Display Name
                </label>
                <input
                  type="text"
                  value={combinedData.displayName}
                  onChange={(e) => setCombinedData({
                    ...combinedData,
                    displayName: e.target.value
                  })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="e.g., Dairy & Eggs"
                />
              </div>
            </div>
            
            <div className="mt-4">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Description
              </label>
              <textarea
                value={combinedData.description}
                onChange={(e) => setCombinedData({
                  ...combinedData,
                  description: e.target.value
                })}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                rows="3"
                placeholder="Description of the combined category..."
              />
            </div>
          </div>
          
          {/* Step 3: Image Upload */}
          <div className="border-t pt-4">
            <h3 className="text-lg font-medium mb-3">Step 3: Category Image</h3>
            
            <div className="space-y-3">
              {combinedData.imageUrl ? (
                <div>
                  <img 
                    src={combinedData.imageUrl} 
                    alt="Category preview" 
                    className="w-32 h-32 object-cover rounded-lg border"
                  />
                  <button
                    type="button"
                    onClick={() => setCombinedData({...combinedData, imageUrl: '', imageFile: null})}
                    className="mt-2 text-sm text-red-600 hover:text-red-800"
                  >
                    Remove Image
                  </button>
                </div>
              ) : (
                <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center">
                  <input
                    type="file"
                    accept="image/*"
                    onChange={(e) => {
                      const file = e.target.files[0];
                      if (file) {
                        setCombinedData({...combinedData, imageFile: file});
                        handleImageUpload(file);
                      }
                    }}
                    className="hidden"
                    id="category-image"
                  />
                  <label htmlFor="category-image" className="cursor-pointer">
                    <Upload className="mx-auto h-12 w-12 text-gray-400" />
                    <p className="mt-2 text-sm text-gray-600">
                      Click to upload category image
                    </p>
                    <p className="text-xs text-gray-500">
                      PNG, JPG, GIF up to 5MB
                    </p>
                  </label>
                </div>
              )}
              
              {uploadingImage && (
                <div className="text-center">
                  <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600 mx-auto"></div>
                  <p className="text-sm text-gray-600 mt-2">Uploading image...</p>
                </div>
              )}
            </div>
          </div>
          
          {/* Step 4: Color Selection */}
          <div className="border-t pt-4">
            <h3 className="text-lg font-medium mb-3">Step 4: Choose Color</h3>
            
            <div className="grid grid-cols-7 gap-2">
              {['green', 'blue', 'orange', 'red', 'purple', 'cyan', 'indigo', 'pink', 'teal', 'amber', 'deepPurple', 'lightBlue', 'yellow', 'brown'].map(color => (
                <button
                  key={color}
                  type="button"
                  onClick={() => setCombinedData({...combinedData, color})}
                  className={`w-10 h-10 rounded-full border-2 ${
                    combinedData.color === color ? 'border-gray-800' : 'border-gray-300'
                  } ${getColorClass(color)}`}
                  title={color}
                />
              ))}
            </div>
          </div>
          
          {/* Action Buttons */}
          <div className="flex space-x-3 pt-6 border-t">
            <button
              type="submit"
              className="flex-1 bg-blue-600 text-white py-3 px-4 rounded-md hover:bg-blue-700"
            >
              Create Combined Category
            </button>
            <button
              type="button"
              onClick={() => {
                console.log('🧪 Test API call');
                const testData = {
                  name: 'Test Category',
                  displayName: 'Test Category',
                  description: 'Test description',
                  color: 'green',
                  combinedCategories: ['Beer', 'wine'],
                  imageUrl: ''
                };
                api.post('/admin/categories/combined', testData)
                  .then(response => {
                    console.log('✅ Test API success:', response);
                    toast.success('Test category created');
                  })
                  .catch(error => {
                    console.error('❌ Test API error:', error);
                    toast.error('Test failed: ' + error.message);
                  });
              }}
              className="flex-1 bg-green-600 text-white py-3 px-4 rounded-md hover:bg-green-700"
            >
              Test API
            </button>
            <button
              type="button"
              onClick={() => {
                setShowCombinedForm(false);
                resetCombinedForm();
              }}
              className="flex-1 bg-gray-300 text-gray-700 py-3 px-4 rounded-md hover:bg-gray-400"
            >
              Cancel
            </button>
          </div>
        </form>
      </div>
    </div>
  );

  const EditModal = () => (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 w-full max-w-lg max-h-[90vh] overflow-y-auto">
        <h2 className="text-xl font-semibold mb-4">Edit Category</h2>
        
        <form onSubmit={handleUpdateCategory} className="space-y-4">
          {/* Basic Information */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Category Name *
              </label>
              <input
                type="text"
                value={editingCategoryData.name || ''}
                onChange={(e) => setEditingCategoryData({
                  ...editingCategoryData,
                  name: e.target.value
                })}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                required
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Display Name
              </label>
              <input
                type="text"
                value={editingCategoryData.displayName || ''}
                onChange={(e) => setEditingCategoryData({
                  ...editingCategoryData,
                  displayName: e.target.value
                })}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Description
            </label>
            <textarea
              value={editingCategoryData.description || ''}
              onChange={(e) => setEditingCategoryData({
                ...editingCategoryData,
                description: e.target.value
              })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              rows="3"
            />
          </div>

          {/* Category Image */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Category Image
            </label>
            <div className="space-y-3">
              {editingCategoryData.imageUrl ? (
                <div>
                  <img 
                    src={editingCategoryData.imageUrl} 
                    alt="Category preview" 
                    className="w-32 h-32 object-cover rounded-lg border"
                  />
                  <button
                    type="button"
                    onClick={() => setEditingCategoryData({
                      ...editingCategoryData, 
                      imageUrl: ''
                    })}
                    className="mt-2 text-sm text-red-600 hover:text-red-800"
                  >
                    Remove Image
                  </button>
                </div>
              ) : (
                <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center">
                  <input
                    type="file"
                    accept="image/*"
                    onChange={(e) => {
                      const file = e.target.files[0];
                      if (file) {
                        handleCategoryImageUpload(file, editingCategoryData._id);
                      }
                    }}
                    className="hidden"
                    id="edit-category-image"
                  />
                  <label htmlFor="edit-category-image" className="cursor-pointer">
                    <Upload className="mx-auto h-12 w-12 text-gray-400" />
                    <p className="mt-2 text-sm text-gray-600">
                      Click to upload category image
                    </p>
                    <p className="text-xs text-gray-500">
                      PNG, JPG, GIF up to 5MB
                    </p>
                  </label>
                </div>
              )}
              
              {uploadingCategoryImage && (
                <div className="text-center">
                  <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600 mx-auto"></div>
                  <p className="text-sm text-gray-600 mt-2">Uploading image...</p>
                </div>
              )}
            </div>
          </div>

          {/* Color Selection */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Choose Color
            </label>
            <div className="grid grid-cols-7 gap-2">
              {['green', 'blue', 'orange', 'red', 'purple', 'cyan', 'indigo', 'pink', 'teal', 'amber', 'deepPurple', 'lightBlue', 'yellow', 'brown'].map(color => (
                <button
                  key={color}
                  type="button"
                  onClick={() => setEditingCategoryData({
                    ...editingCategoryData, 
                    color
                  })}
                  className={`w-10 h-10 rounded-full border-2 ${
                    editingCategoryData.color === color ? 'border-gray-800' : 'border-gray-300'
                  } ${getColorClass(color)}`}
                  title={color}
                />
              ))}
            </div>
          </div>

          {/* Status and Settings */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Sort Order
              </label>
              <input
                type="number"
                value={editingCategoryData.sortOrder || 0}
                onChange={(e) => setEditingCategoryData({
                  ...editingCategoryData,
                  sortOrder: parseInt(e.target.value) || 0
                })}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            
            <div className="flex items-center">
              <input
                type="checkbox"
                id="isActive"
                checked={editingCategoryData.isActive || false}
                onChange={(e) => setEditingCategoryData({
                  ...editingCategoryData,
                  isActive: e.target.checked
                })}
                className="mr-2"
              />
              <label htmlFor="isActive" className="text-sm font-medium text-gray-700">
                Active
              </label>
            </div>
            
            <div className="flex items-center">
              <input
                type="checkbox"
                id="isFeatured"
                checked={editingCategoryData.isFeatured || false}
                onChange={(e) => setEditingCategoryData({
                  ...editingCategoryData,
                  isFeatured: e.target.checked
                })}
                className="mr-2"
              />
              <label htmlFor="isFeatured" className="text-sm font-medium text-gray-700">
                Featured
              </label>
            </div>
          </div>
          
          {/* Action Buttons */}
          <div className="flex space-x-3 pt-6 border-t">
            <button
              type="submit"
              className="flex-1 bg-blue-600 text-white py-3 px-4 rounded-md hover:bg-blue-700"
            >
              Update Category
            </button>
            <button
              type="button"
              onClick={() => {
                setShowEditModal(false);
                setEditingCategoryData({});
              }}
              className="flex-1 bg-gray-300 text-gray-700 py-3 px-4 rounded-md hover:bg-gray-400"
            >
              Cancel
            </button>
          </div>
        </form>
      </div>
    </div>
  );

  return (
    <div className="p-6">
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Category Management</h1>
        <div className="flex items-center space-x-3">
          <button
            onClick={() => setShowCombinedForm(true)}
            className="flex items-center space-x-2 bg-purple-600 text-white px-4 py-2 rounded-md hover:bg-purple-700"
          >
            <Merge size={16} />
            <span>Create Combined Category</span>
          </button>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div className="bg-white p-4 rounded-lg shadow border">
          <h3 className="text-sm font-medium text-gray-500">Total Categories</h3>
          <p className="text-2xl font-bold text-gray-900">{stats.totalCategories || 0}</p>
        </div>
        <div className="bg-white p-4 rounded-lg shadow border">
          <h3 className="text-sm font-medium text-gray-500">Active Categories</h3>
          <p className="text-2xl font-bold text-green-600">{stats.activeCategories || 0}</p>
        </div>
        <div className="bg-white p-4 rounded-lg shadow border">
          <h3 className="text-sm font-medium text-gray-500">Featured Categories</h3>
          <p className="text-2xl font-bold text-yellow-600">{stats.featuredCategories || 0}</p>
        </div>
        <div className="bg-white p-4 rounded-lg shadow border">
          <h3 className="text-sm font-medium text-gray-500">Total Products</h3>
          <p className="text-2xl font-bold text-blue-600">{stats.totalProducts || 0}</p>
        </div>
      </div>

      {/* Filters and Search */}
      <div className="bg-white p-4 rounded-lg shadow border mb-6">
        <div className="flex flex-col md:flex-row md:items-center md:justify-between space-y-4 md:space-y-0">
          <div className="flex items-center space-x-4">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" size={16} />
              <input
                type="text"
                placeholder="Search categories..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10 pr-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <select
              value={filter}
              onChange={(e) => setFilter(e.target.value)}
              className="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="all">All Categories</option>
              <option value="isActive">Active Only</option>
              <option value="isFeatured">Featured Only</option>
            </select>
          </div>
          <div className="flex items-center space-x-2">
            <button
              onClick={() => setViewMode('grid')}
              className={`p-2 rounded ${viewMode === 'grid' ? 'bg-blue-100 text-blue-600' : 'text-gray-400'}`}
            >
              <Grid size={16} />
            </button>
            <button
              onClick={() => setViewMode('list')}
              className={`p-2 rounded ${viewMode === 'list' ? 'bg-blue-100 text-blue-600' : 'text-gray-400'}`}
            >
              <List size={16} />
            </button>
          </div>
        </div>
      </div>

      {/* Categories List */}
      {loading ? (
        <div className="flex items-center justify-center py-12">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
        </div>
      ) : (
        <>
          {viewMode === 'grid' ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
              {categories.map(category => (
                <CategoryCard key={category._id} category={category} />
              ))}
            </div>
          ) : (
            <div className="bg-white rounded-lg shadow border overflow-hidden">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Category
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Products
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Status
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Sort Order
                    </th>
                    <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Actions
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {categories.map(category => (
                    <tr key={category._id}>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center">
                          {category.imageUrl ? (
                            <img 
                              src={category.imageUrl} 
                              alt={category.name}
                              className="w-8 h-8 rounded object-cover mr-3"
                            />
                          ) : (
                            <div className={`w-8 h-8 rounded flex items-center justify-center mr-3 ${getColorClass(category.color)}`}>
                              <span className="text-sm font-semibold">{category.name.charAt(0)}</span>
                            </div>
                          )}
                          <div>
                            <div className="text-sm font-medium text-gray-900">{category.displayName}</div>
                            <div className="text-sm text-gray-500">{category.name}</div>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {category.productCount || 0}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center space-x-2">
                          <span className={`px-2 py-1 text-xs rounded-full ${category.isActive ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>
                            {category.isActive ? 'Active' : 'Inactive'}
                          </span>
                          {category.isFeatured && (
                            <span className="px-2 py-1 text-xs rounded-full bg-yellow-100 text-yellow-800">
                              Featured
                            </span>
                          )}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {category.sortOrder}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                        <div className="flex items-center justify-end space-x-2">
                          <button
                            onClick={() => handleEditCategory(category)}
                            className="text-blue-600 hover:text-blue-900 p-1"
                            title="Edit category"
                          >
                            <Edit size={14} />
                          </button>
                          
                          <button
                            onClick={() => handleToggleFeatured(category._id)}
                            className={`p-1 rounded ${category.isFeatured ? 'text-yellow-500' : 'text-gray-400'}`}
                            title={category.isFeatured ? 'Remove from featured' : 'Mark as featured'}
                          >
                            {category.isFeatured ? <Star size={14} /> : <StarOff size={14} />}
                          </button>
                          
                          <button
                            onClick={() => handleDelete(category._id)}
                            className="text-red-600 hover:text-red-900 p-1"
                            title="Delete category"
                          >
                            <Trash2 size={14} />
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}

          {/* Pagination */}
          {totalPages > 1 && (
            <div className="flex items-center justify-between mt-6">
              <div className="text-sm text-gray-700">
                Page {currentPage} of {totalPages}
              </div>
              <div className="flex space-x-2">
                <button
                  onClick={() => setCurrentPage(Math.max(1, currentPage - 1))}
                  disabled={currentPage === 1}
                  className="px-3 py-1 border border-gray-300 rounded-md disabled:opacity-50"
                >
                  Previous
                </button>
                <button
                  onClick={() => setCurrentPage(Math.min(totalPages, currentPage + 1))}
                  disabled={currentPage === totalPages}
                  className="px-3 py-1 border border-gray-300 rounded-md disabled:opacity-50"
                >
                  Next
                </button>
              </div>
            </div>
          )}
        </>
      )}

      {/* Modals */}
      {showCombinedForm && <CombinedForm />}
      {showEditModal && <EditModal />}
    </div>
  );
};

export default Categories; 