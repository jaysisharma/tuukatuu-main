# Client Setup Guide

## Prerequisites
- Node.js (v14 or higher)
- npm or yarn

## Installation

1. Install dependencies:
```bash
npm install
```

2. Start the development server:
```bash
npm run dev
```

The application will be available at `http://localhost:5173`

## Configuration

The client is configured to connect to the backend at `http://localhost:3000/api`. If your backend is running on a different port or URL, update the `API_BASE` constant in `src/api.js`:

```javascript
const API_BASE = 'http://localhost:3000/api';
```

## Features

### Admin Dashboard
- **Riders Management**: View, create, edit, approve, block, and delete riders
- **Rider Details**: Detailed view of rider information, performance, and earnings
- **Rider Analytics**: Performance metrics and statistics
- **User Management**: Manage all users (customers, vendors, riders)
- **Vendor Management**: Manage vendor accounts and stores
- **Order Management**: View and manage all orders
- **Product Management**: Manage products across all vendors
- **Coupons & Banners**: Manage promotional content

### Vendor Dashboard
- **Products**: Manage store products
- **Orders**: View and manage store orders
- **Analytics**: Sales and performance metrics
- **Profile**: Update store information
- **Settings**: Configure store preferences

## Authentication

The application uses JWT authentication. Users are automatically redirected to the appropriate dashboard based on their role:
- Admin users → `/admin`
- Vendor users → `/vendor`

## State Management

The application uses Redux Toolkit for state management with the following slices:
- `auth`: User authentication and session management

## API Integration

All API calls are handled through the `api.js` utility which:
- Automatically includes JWT tokens in requests
- Handles error responses consistently
- Provides a simple interface for HTTP methods

## Styling

The application uses Tailwind CSS for styling with a custom color scheme defined in the CSS variables.

## Development

### Project Structure
```
src/
├── components/     # Reusable UI components
├── layouts/        # Layout components (Admin, Vendor)
├── pages/          # Page components
│   ├── admin/      # Admin dashboard pages
│   └── vendor/     # Vendor dashboard pages
├── api.js          # API utility
├── store.js        # Redux store configuration
└── App.jsx         # Main application component
```

### Adding New Features

1. Create new components in the appropriate directory
2. Add routes in `App.jsx` if needed
3. Update the navigation in layout components
4. Add any new API endpoints to `api.js` if needed

## Building for Production

```bash
npm run build
```

The built files will be in the `dist` directory. 