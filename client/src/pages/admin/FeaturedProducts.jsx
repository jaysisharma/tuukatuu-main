import React, { useState, useEffect } from 'react';
import { 
  Table, 
  Button, 
  Input, 
  Select, 
  Switch, 
  message, 
  Popconfirm, 
  Space,
  Card,
  Row,
  Col,
  Tag,
  Image,
  Tooltip,
  Modal,
  Form,
  InputNumber
} from 'antd';
import { 
  StarOutlined, 
  StarFilled, 
  SearchOutlined, 
  FilterOutlined,
  EditOutlined,
  DeleteOutlined,
  PlusOutlined,
  ReloadOutlined
} from '@ant-design/icons';
import { api } from '../../api';

const { Option } = Select;
const { Search } = Input;

const FeaturedProducts = () => {
  const [products, setProducts] = useState([]);
  const [featuredProducts, setFeaturedProducts] = useState([]);
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(false);
  const [searchText, setSearchText] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('');
  const [featuredFilter, setFeaturedFilter] = useState('');
  const [pagination, setPagination] = useState({
    current: 1,
    pageSize: 20,
    total: 0
  });
  const [editModalVisible, setEditModalVisible] = useState(false);
  const [editingProduct, setEditingProduct] = useState(null);
  const [form] = Form.useForm();

  useEffect(() => {
    if (checkAuth()) {
      fetchProducts();
      fetchFeaturedProducts();
      fetchCategories();
    }
  }, [pagination.current, pagination.pageSize, searchText, selectedCategory, featuredFilter]);

  const fetchProducts = async () => {
    setLoading(true);
    try {
      const params = new URLSearchParams({
        page: pagination.current,
        limit: pagination.pageSize,
        search: searchText,
        category: selectedCategory,
        featured: featuredFilter
      });

      const response = await api.get(`/admin/featured-products/products?${params}`);
      
      if (response.success) {
        setProducts(response.data);
        setPagination(prev => ({
          ...prev,
          total: response.pagination.total
        }));
      }
    } catch (error) {
      console.error('Error fetching products:', error);
      message.error('Failed to fetch products');
    } finally {
      setLoading(false);
    }
  };

  const fetchFeaturedProducts = async () => {
    try {
      const response = await api.get('/admin/featured-products/featured');
      if (response.success) {
        setFeaturedProducts(response.data);
      }
    } catch (error) {
      console.error('Error fetching featured products:', error);
    }
  };

  const fetchCategories = async () => {
    try {
      const response = await api.get('/admin/featured-products/categories');
      if (response.success) {
        setCategories(response.data);
      }
    } catch (error) {
      console.error('Error fetching categories:', error);
    }
  };

  const handleToggleFeatured = async (productId, isFeatured, featuredOrder = 0) => {
    try {
      const response = await api.patch(`/admin/featured-products/products/${productId}/featured`, {
        isFeatured,
        featuredOrder
      });

      if (response.success) {
        message.success(response.message);
        fetchProducts();
        fetchFeaturedProducts();
      }
    } catch (error) {
      console.error('Error toggling featured status:', error);
      message.error('Failed to update featured status');
    }
  };

  const handleBulkToggleFeatured = async (productIds, isFeatured) => {
    try {
      const response = await api.post('/admin/featured-products/bulk-toggle-featured', {
        productIds,
        isFeatured
      });

      if (response.success) {
        message.success(response.message);
        fetchProducts();
        fetchFeaturedProducts();
      }
    } catch (error) {
      console.error('Error bulk toggling featured status:', error);
      message.error('Failed to update featured status');
    }
  };

  const handleEditOrder = (product) => {
    setEditingProduct(product);
    form.setFieldsValue({
      featuredOrder: product.featuredOrder || 0
    });
    setEditModalVisible(true);
  };

  const handleSaveOrder = async () => {
    try {
      const values = await form.validateFields();
      await handleToggleFeatured(editingProduct._id, true, values.featuredOrder);
      setEditModalVisible(false);
      setEditingProduct(null);
      form.resetFields();
    } catch (error) {
      console.error('Error saving order:', error);
    }
  };

  const handleTableChange = (paginationInfo) => {
    setPagination(prev => ({
      ...prev,
      current: paginationInfo.current,
      pageSize: paginationInfo.pageSize
    }));
  };

  const handleSearch = (value) => {
    setSearchText(value);
    setPagination(prev => ({ ...prev, current: 1 }));
  };

  const handleCategoryChange = (value) => {
    setSelectedCategory(value);
    setPagination(prev => ({ ...prev, current: 1 }));
  };

  const handleFeaturedFilterChange = (value) => {
    setFeaturedFilter(value);
    setPagination(prev => ({ ...prev, current: 1 }));
  };

  const handleRefresh = () => {
    fetchProducts();
    fetchFeaturedProducts();
  };

  const checkAuth = () => {
    const user = JSON.parse(localStorage.getItem('user'));
    if (!user || user.role !== 'admin') {
      message.error('Please login as admin to access this feature');
      return false;
    }
    return true;
  };

  const columns = [
    {
      title: 'Product',
      key: 'product',
      render: (_, record) => (
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <Image
            src={record.imageUrl}
            alt={record.name}
            width={50}
            height={50}
            style={{ objectFit: 'cover', borderRadius: 8 }}
            fallback="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAMIAAADDCAYAAADQvc6UAAABRWlDQ1BJQ0MgUHJvZmlsZQAAKJFjYGASSSwoyGFhYGDIzSspCnJ3UoiIjFJgf8LAwSDCIMogwMCcmFxc4BgQ4ANUwgCjUcG3awyMIPqyLsis7PPOq3QdDFcvjV3jOD1boQVTPQrgSkktTgbSf4A4LbmgqISBgTEFyFYuLykAsTuAbJEioKOA7DkgdjqEvQHEToKwj4DVhAQ5A9k3gGyB5IxEoBmML4BsnSQk8XQkNtReEOBxcfXxUQg1Mjc0dyHgXNJBSWpFCYh2zi+oLMpMzyhRcASGUqqCZ16yno6CkYGRAQMDKMwhqj/fAIcloxgHQqxAjIHBEugw5sUIsSQpBobtQPdLciLEVJYzMPBHMDBsayhILEqEO4DxG0txmrERhM29nYGBddr//5/DGRjYNRkY/l7////39v///y4Dmn+LgeHANwDrkl1AuO+pmgAAADhlWElmTU0AKgAAAAgAAYdpAAQAAAABAAAAGgAAAAAAAqACAAQAAAABAAAAwqADAAQAAAABAAAAwwAAAAD9b/HnAAAHlklEQVR4Ae3dP3Ik1RnG4W+FgYxN"
          />
          <div>
            <div style={{ fontWeight: 'bold', fontSize: '14px' }}>{record.name}</div>
            <div style={{ color: '#666', fontSize: '12px' }}>₹{record.price}</div>
            <div style={{ color: '#999', fontSize: '12px' }}>{record.category}</div>
          </div>
        </div>
      )
    },
    {
      title: 'Vendor',
      dataIndex: 'vendorId',
      key: 'vendor',
      render: (vendor) => (
        <div>
          <div style={{ fontWeight: 'bold' }}>{vendor?.storeName || 'Unknown'}</div>
          <div style={{ color: '#666' }}>Rating: {vendor?.storeRating || 'N/A'}</div>
        </div>
      )
    },
    {
      title: 'Featured',
      key: 'featured',
      render: (_, record) => (
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <Switch
            checked={record.isFeatured}
            onChange={(checked) => handleToggleFeatured(record._id, checked)}
            checkedChildren={<StarFilled style={{ color: '#faad14' }} />}
            unCheckedChildren={<StarOutlined />}
          />
          {record.isFeatured && (
            <Tag color="gold">
              Order: {record.featuredOrder || 0}
            </Tag>
          )}
        </div>
      )
    },
    {
      title: 'Actions',
      key: 'actions',
      render: (_, record) => (
        <Space>
          {record.isFeatured && (
            <Tooltip title="Edit Order">
              <Button
                type="link"
                icon={<EditOutlined />}
                onClick={() => handleEditOrder(record)}
              />
            </Tooltip>
          )}
        </Space>
      )
    }
  ];

  const rowSelection = {
    onChange: (selectedRowKeys, selectedRows) => {
      // Handle bulk selection
    },
    getCheckboxProps: (record) => ({
      disabled: record.name === 'Disabled User',
      name: record.name,
    }),
  };

  const user = JSON.parse(localStorage.getItem('user'));
  const isAdmin = user && user.role === 'admin';

  return (
    <div style={{ padding: '24px' }}>
      <Card title="Featured Products Management" extra={
        <Button icon={<ReloadOutlined />} onClick={handleRefresh}>
          Refresh
        </Button>
      }>
        {/* Filters */}
        <Row gutter={16} style={{ marginBottom: 16 }}>
          <Col span={6}>
            <Search
              placeholder="Search products..."
              onSearch={handleSearch}
              style={{ width: '100%' }}
            />
          </Col>
          <Col span={4}>
            <Select
              placeholder="Category"
              style={{ width: '100%' }}
              allowClear
              onChange={handleCategoryChange}
            >
              {categories.map(category => (
                <Option key={category} value={category}>{category}</Option>
              ))}
            </Select>
          </Col>
          <Col span={4}>
            <Select
              placeholder="Featured"
              style={{ width: '100%' }}
              allowClear
              onChange={handleFeaturedFilterChange}
            >
              <Option value="true">Featured</Option>
              <Option value="false">Not Featured</Option>
            </Select>
          </Col>
        </Row>

        {/* Featured Products Summary */}
        {featuredProducts.length > 0 && (
          <Card 
            title={`Featured Products (${featuredProducts.length})`} 
            size="small" 
            style={{ marginBottom: 16 }}
          >
            <Row gutter={[8, 8]}>
              {featuredProducts.map((product, index) => (
                <Col span={6} key={product._id}>
                  <Card size="small">
                    <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                      <Image
                        src={product.imageUrl}
                        alt={product.name}
                        width={40}
                        height={40}
                        style={{ objectFit: 'cover', borderRadius: 4 }}
                      />
                      <div style={{ flex: 1 }}>
                        <div style={{ fontSize: '12px', fontWeight: 'bold' }}>
                          {product.name}
                        </div>
                        <div style={{ fontSize: '10px', color: '#666' }}>
                          Order: {product.featuredOrder || 0}
                        </div>
                      </div>
                    </div>
                  </Card>
                </Col>
              ))}
            </Row>
          </Card>
        )}

        {/* Products Table */}
        <Table
          columns={columns}
          dataSource={products}
          rowKey="_id"
          loading={loading}
          pagination={pagination}
          onChange={handleTableChange}
          rowSelection={rowSelection}
          scroll={{ x: 1200 }}
        />
      </Card>

      {/* Edit Order Modal */}
      <Modal
        title="Edit Featured Order"
        open={editModalVisible}
        onOk={handleSaveOrder}
        onCancel={() => {
          setEditModalVisible(false);
          setEditingProduct(null);
          form.resetFields();
        }}
      >
        <Form form={form} layout="vertical">
          <Form.Item
            name="featuredOrder"
            label="Featured Order"
            rules={[{ required: true, message: 'Please enter featured order' }]}
          >
            <InputNumber min={0} style={{ width: '100%' }} />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default FeaturedProducts; 