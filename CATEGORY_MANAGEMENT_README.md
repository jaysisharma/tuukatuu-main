# Category Management System

## Overview

This document describes the comprehensive category management system implemented for the Tuukatuu platform. The system provides full CRUD operations, category merging, image uploads, and admin management capabilities.

## Features

### Backend Features

1. **Category Model** (`backend/src/models/Category.js`)
   - Complete category schema with all required fields
   - Support for parent-child relationships
   - Category merging capabilities
   - Product count tracking
   - Featured category management
   - Sort order functionality
   - SEO metadata support

2. **Category Service** (`backend/src/services/categoryService.js`)
   - Full CRUD operations
   - Pagination and filtering
   - Category merging logic
   - Image upload handling
   - Statistics and analytics
   - Auto-category creation from products

3. **Category Controller** (`backend/src/controllers/categoryController.js`)
   - RESTful API endpoints
   - Input validation
   - Error handling
   - File upload processing

4. **Category Routes** (`backend/src/routes/categories.js`)
   - Public routes for TMart
   - Admin-only routes with authentication
   - Image upload endpoints

### Frontend Features (Admin Panel)

1. **Categories Management Page** (`client/src/pages/admin/Categories.jsx`)
   - Grid and list view modes
   - Search and filtering
   - Category creation and editing
   - Category merging interface
   - Featured status toggling
   - Image upload functionality
   - Statistics dashboard
   - Pagination

## API Endpoints

### Public Endpoints (TMart)
- `GET /api/categories/featured` - Get featured categories
- `GET /api/categories/hierarchy` - Get category hierarchy

### Admin Endpoints (Require Authentication)
- `GET /api/categories` - Get all categories with pagination
- `GET /api/categories/stats` - Get category statistics
- `GET /api/categories/:categoryId` - Get category by ID
- `POST /api/categories` - Create new category
- `PUT /api/categories/:categoryId` - Update category
- `DELETE /api/categories/:categoryId` - Delete category
- `POST /api/categories/combined` - Create combined category
- `PATCH /api/categories/:categoryId/toggle-featured` - Toggle featured status
- `PATCH /api/categories/:categoryId/sort-order` - Update sort order
- `POST /api/categories/bulk-update` - Bulk update categories
- `POST /api/categories/:categoryId/upload-image` - Upload category image
- `POST /api/categories/auto-create` - Auto-create from product

## Category Model Schema

```javascript
{
  name: String,                    // Required, unique
  displayName: String,             // Required
  description: String,             // Optional
  imageUrl: String,                // Optional
  iconUrl: String,                 // Optional
  color: String,                   // Predefined color options
  isActive: Boolean,               // Default: true
  isFeatured: Boolean,             // Default: false
  sortOrder: Number,               // Default: 0
  parentCategory: ObjectId,        // Reference to parent category
  childCategories: [ObjectId],     // Array of child categories
  mergedFrom: [String],            // Categories that were merged
  productCount: Number,            // Auto-calculated
  createdBy: ObjectId,             // Required, user reference
  updatedBy: ObjectId,             // User who last updated
  metadata: {
    seoTitle: String,
    seoDescription: String,
    keywords: [String]
  }
}
```

## Category Merging

The system supports merging multiple categories into a single category:

1. **Merge Process**:
   - Select multiple categories to merge
   - Create a new category with combined data
   - Update all products to use the new category
   - Deactivate old categories
   - Maintain merge history

2. **Example Merge**:
   - Merge "Dairy" and "Chocolate" into "Dairy & Chocolate"
   - All products from both categories are moved to the new category
   - Original categories are deactivated but preserved for history

## Auto-Category Creation

When products are created, the system automatically:

1. Checks if the product's category exists
2. If not, creates a new category automatically
3. Associates the category with the product
4. Updates product counts

## Image Upload

Categories support image uploads:

1. **Upload Process**:
   - Uses Multer for file handling
   - Supports JPEG, PNG, GIF, WebP formats
   - 5MB file size limit
   - Automatic Cloudinary integration
   - Image optimization and resizing

2. **Image Storage**:
   - Local temporary storage during upload
   - Cloudinary for permanent storage
   - Automatic cleanup of temporary files

## Admin Panel Features

### Dashboard
- Category statistics overview
- Total categories, active categories, featured categories
- Total products across all categories

### Category Management
- **Grid View**: Card-based layout with category images
- **List View**: Table layout with detailed information
- **Search**: Real-time search across category names and descriptions
- **Filtering**: Filter by active status, featured status
- **Pagination**: Handle large numbers of categories

### Category Operations
- **Create**: Add new categories with all required fields
- **Edit**: Modify existing categories
- **Delete**: Soft delete with product count validation
- **Merge**: Combine multiple categories
- **Toggle Featured**: Mark/unmark categories as featured
- **Sort Order**: Customize category display order

### Image Management
- Upload category images
- Preview uploaded images
- Replace existing images
- Automatic image optimization

## Color System

The system supports 14 predefined colors:
- green, blue, orange, red, purple, cyan
- indigo, pink, teal, amber, deepPurple, lightBlue
- yellow, brown

Each color has corresponding CSS classes for consistent styling.

## Integration with TMart

The category system integrates seamlessly with TMart:

1. **Featured Categories**: Shows only 8 featured categories initially
2. **View All**: Navigate to see all categories
3. **Product Association**: Products are automatically linked to categories
4. **Category Cards**: Display with images, colors, and product counts

## Security

1. **Authentication**: All admin endpoints require valid JWT tokens
2. **Authorization**: Admin role required for category management
3. **Input Validation**: Comprehensive validation for all inputs
4. **File Upload Security**: File type and size restrictions

## Error Handling

1. **Validation Errors**: Detailed error messages for invalid inputs
2. **Duplicate Prevention**: Prevents duplicate category names
3. **Dependency Checks**: Prevents deletion of categories with products
4. **File Upload Errors**: Graceful handling of upload failures

## Performance Optimizations

1. **Database Indexes**: Optimized queries with proper indexing
2. **Pagination**: Efficient handling of large datasets
3. **Image Optimization**: Automatic resizing and compression
4. **Caching**: Category data caching for better performance

## Usage Examples

### Creating a Category
```javascript
const categoryData = {
  name: "Fresh Fruits",
  displayName: "Fresh Fruits & Vegetables",
  description: "Fresh and organic fruits and vegetables",
  color: "green",
  isActive: true,
  isFeatured: true,
  sortOrder: 1
};

const response = await api.post('/categories', categoryData);
```

### Creating a Combined Category
```javascript
const combinedCategoryData = {
  name: "Dairy & Eggs",
  displayName: "Dairy & Eggs",
  description: "All dairy and egg products",
  color: "blue",
  combinedCategories: ["Milk", "Cheese", "Curd", "Eggs"]
};

const response = await api.post('/categories/combined', combinedCategoryData);
```

### Uploading Category Image
```javascript
const formData = new FormData();
formData.append('image', file);

const response = await api.upload(`/categories/${categoryId}/upload-image`, formData);
```

## Installation and Setup

### Backend Dependencies
```bash
npm install multer cloudinary
```

### Frontend Dependencies
```bash
npm install lucide-react react-hot-toast
```

### Environment Variables
```env
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
JWT_SECRET=your_jwt_secret
```

## Future Enhancements

1. **Category Analytics**: Detailed analytics for category performance
2. **Bulk Operations**: Import/export categories via CSV
3. **Category Templates**: Predefined category templates
4. **Advanced Filtering**: More sophisticated filtering options
5. **Category Recommendations**: AI-powered category suggestions
6. **Multi-language Support**: Internationalization for category names
7. **Category SEO**: Advanced SEO management for categories

## Troubleshooting

### Common Issues

1. **Image Upload Fails**:
   - Check file size (max 5MB)
   - Verify file format (JPEG, PNG, GIF, WebP)
   - Ensure Cloudinary credentials are correct

2. **Category Creation Fails**:
   - Verify category name is unique
   - Check required fields are provided
   - Ensure user has admin permissions

3. **Merge Operation Fails**:
   - Ensure at least 2 categories are selected
   - Check new category name is unique
   - Verify all categories exist

### Debug Mode
Enable debug logging by setting:
```env
DEBUG=true
NODE_ENV=development
```

## Support

For issues or questions regarding the category management system, please refer to:
- Backend logs for server-side errors
- Browser console for frontend errors
- API response messages for detailed error information 