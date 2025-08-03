# Backend for Tuukatuu

This backend serves the Tuukatuu application, supporting four user roles:
- **Admin**: Manage users, products, orders, analytics
- **Vendor**: Manage own products, view and update orders
- **Rider**: View assigned deliveries, update delivery status
- **Customer**: Browse products, place orders, view order history

## Principles
- **Industry Standard**: Follows best practices for structure, security, and maintainability
- **DRY**: Avoids code duplication via modularization and reusable components
- **SOLID**: Applies SOLID principles for scalable, testable, and maintainable code

## Structure
- `src/` — Main backend source code
- `src/controllers/` — Route handlers for each resource
- `src/models/` — Database models/schemas
- `src/routes/` — API route definitions
- `src/services/` — Business logic and reusable services
- `src/middleware/` — Authentication, authorization, error handling
- `src/utils/` — Utility functions
- `tests/` — Unit and integration tests

## Tech Stack
- Node.js (Express.js)
- MongoDB (Mongoose)
- JWT for authentication
- dotenv for configuration

## Getting Started
1. `npm install`
2. `npm run dev`

See `done.md` for progress and checklist. 


