import React, { useState, useEffect } from 'react';
import { 
  Table, 
  Button, 
  Input, 
  Switch, 
  message, 
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
  EditOutlined,
  ReloadOutlined
} from '@ant-design/icons';
import { api } from '../../api';

const { Search } = Input;

const FeaturedCategories = () => {
  const [categories, setCategories] = useState([]);
  const [featuredCategories, setFeaturedCategories] = useState([]);
  const [loading, setLoading] = useState(false);
  const [searchText, setSearchText] = useState('');
  const [editModalVisible, setEditModalVisible] = useState(false);
  const [editingCategory, setEditingCategory] = useState(null);
  const [form] = Form.useForm();

  useEffect(() => {
    fetchCategories();
    fetchFeaturedCategories();
  }, []);

  const fetchCategories = async () => {
    setLoading(true);
    try {
      const response = await api.get('/categories');
      if (response.success) {
        setCategories(response.data);
      }
    } catch (error) {
      console.error('Error fetching categories:', error);
      message.error('Failed to fetch categories');
    } finally {
      setLoading(false);
    }
  };

  const fetchFeaturedCategories = async () => {
    try {
      const response = await api.get('/tmart/categories/featured');
      if (response.success) {
        setFeaturedCategories(response.data);
      }
    } catch (error) {
      console.error('Error fetching featured categories:', error);
    }
  };

  const handleToggleFeatured = async (categoryId, isFeatured, sortOrder = 0) => {
    try {
      const response = await api.patch(`/categories/${categoryId}`, {
        isFeatured,
        sortOrder
      });

      if (response.success) {
        message.success(`Category ${isFeatured ? 'featured' : 'unfeatured'} successfully`);
        fetchCategories();
        fetchFeaturedCategories();
      }
    } catch (error) {
      console.error('Error toggling featured status:', error);
      message.error('Failed to update featured status');
    }
  };

  const handleEditOrder = (category) => {
    setEditingCategory(category);
    form.setFieldsValue({
      sortOrder: category.sortOrder || 0
    });
    setEditModalVisible(true);
  };

  const handleSaveOrder = async () => {
    try {
      const values = await form.validateFields();
      await handleToggleFeatured(editingCategory._id, true, values.sortOrder);
      setEditModalVisible(false);
      setEditingCategory(null);
      form.resetFields();
    } catch (error) {
      console.error('Error saving order:', error);
    }
  };

  const handleSearch = (value) => {
    setSearchText(value);
  };

  const handleRefresh = () => {
    fetchCategories();
    fetchFeaturedCategories();
  };

  const filteredCategories = categories.filter(category =>
    category.name.toLowerCase().includes(searchText.toLowerCase()) ||
    category.displayName?.toLowerCase().includes(searchText.toLowerCase())
  );

  const columns = [
    {
      title: 'Category',
      key: 'category',
      render: (_, record) => (
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <div style={{
            width: 50,
            height: 50,
            backgroundColor: _getCategoryColor(record.color) + '20',
            borderRadius: 8,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center'
          }}>
            {record.iconUrl ? (
              <Image
                src={record.iconUrl}
                alt={record.name}
                width={50}
                height={50}
                style={{ objectFit: 'cover', borderRadius: 8 }}
                fallback="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAMIAAADDCAYAAADQvc6UAAABRWlDQ1BJQ0MgUHJvZmlsZQAAKJFjYGASSSwoyGFhYGDIzSspCnJ3UoiIjFJgf8LAwSDCIMogwMCcmFxc4BgQ4ANUwgCjUcG3awyMIPqyLsis7PPOq3QdDFcvjV3jOD1boQVTPQrgSkktTgbSf4A4LbmgqISBgTEFyFYuLykAsTuAbJEioKOA7DkgdjqEvQHEToKwj4DVhAQ5A9k3gGyB5IxEoBmML4BsnSQk8XQkNtReEOBxcfXxUQg1Mjc0dyHgXNJBSWpFCYh2zi+oLMpMzyhRcASGUqqCZ16yno6CkYGRAQMDKMwhqj/fAIcloxgHQqxAjIHBEugw5sUIsSQpBobtQPdLciLEVJYzMPBHMDBsayhILEqEO4DxG0txmrERhM29nYGBddr//5/DGRjYNRkY/l7////39v///y4Dmn+LgeHANwDrkl1AuO+pmgAAADhlWElmTU0AKgAAAAgAAYdpAAQAAAABAAAAGgAAAAAAAqACAAQAAAABAAAAwqADAAQAAAABAAAAwwAAAAD9b/HnAAAHlklEQVR4Ae3dP3Ik1RnG4W+FgYxN"
              />
            ) : (
                             <div style={{ 
                 display: 'flex', 
                 alignItems: 'center', 
                 justifyContent: 'center',
                 color: _getCategoryColor(record.color),
                 fontSize: 20
               }}>
                 📦
               </div>
             )}
           </div>
          <div>
            <div style={{ fontWeight: 'bold', fontSize: '14px' }}>
              {record.displayName || record.name}
            </div>
            <div style={{ color: '#666', fontSize: '12px' }}>
              {record.productCount || 0} products
            </div>
          </div>
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
              Order: {record.sortOrder || 0}
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

  const _getCategoryColor = (colorValue) => {
    if (colorValue === 'green') return '#52c41a';
    if (colorValue === 'blue') return '#1890ff';
    if (colorValue === 'red') return '#f5222d';
    if (colorValue === 'orange') return '#fa8c16';
    if (colorValue === 'purple') return '#722ed1';
    if (colorValue === 'pink') return '#eb2f96';
    if (colorValue === 'cyan') return '#13c2c2';
    if (colorValue === 'indigo') return '#2f54eb';
    return '#fc8019'; // Default Swiggy Orange
  };

  return (
    <div style={{ padding: '24px' }}>
      <Card title="Featured Categories Management" extra={
        <Button icon={<ReloadOutlined />} onClick={handleRefresh}>
          Refresh
        </Button>
      }>
        {/* Search */}
        <Row gutter={16} style={{ marginBottom: 16 }}>
          <Col span={8}>
            <Search
              placeholder="Search categories..."
              onSearch={handleSearch}
              style={{ width: '100%' }}
            />
          </Col>
        </Row>

        {/* Featured Categories Summary */}
        {featuredCategories.length > 0 && (
          <Card 
            title={`Featured Categories (${featuredCategories.length})`} 
            size="small" 
            style={{ marginBottom: 16 }}
          >
            <Row gutter={[8, 8]}>
              {featuredCategories.map((category, index) => (
                <Col span={6} key={category._id}>
                  <Card size="small">
                    <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                      <div style={{
                        width: 30,
                        height: 30,
                        backgroundColor: _getCategoryColor(category.color),
                        borderRadius: 4,
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        color: 'white',
                        fontSize: 12
                      }}>
                        {category.displayName?.charAt(0) || category.name?.charAt(0) || 'C'}
                      </div>
                      <div style={{ flex: 1 }}>
                        <div style={{ fontSize: '12px', fontWeight: 'bold' }}>
                          {category.displayName || category.name}
                        </div>
                        <div style={{ fontSize: '10px', color: '#666' }}>
                          Order: {category.sortOrder || 0} • {category.productCount || 0} products
                        </div>
                      </div>
                    </div>
                  </Card>
                </Col>
              ))}
            </Row>
          </Card>
        )}

        {/* Categories Table */}
        <Table
          columns={columns}
          dataSource={filteredCategories}
          rowKey="_id"
          loading={loading}
          scroll={{ x: 800 }}
        />
      </Card>

      {/* Edit Order Modal */}
      <Modal
        title="Edit Featured Order"
        open={editModalVisible}
        onOk={handleSaveOrder}
        onCancel={() => {
          setEditModalVisible(false);
          setEditingCategory(null);
          form.resetFields();
        }}
      >
        <Form form={form} layout="vertical">
          <Form.Item
            name="sortOrder"
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

export default FeaturedCategories; 