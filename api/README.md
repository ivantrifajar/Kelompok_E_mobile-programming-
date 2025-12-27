# Express API dengan MongoDB

REST API menggunakan Express.js dan MongoDB dengan struktur MVC.

## 📋 Prerequisites

- Node.js (v14 atau lebih baru)
- MongoDB (local atau MongoDB Atlas)
- npm atau yarn

## 🚀 Instalasi

### 1. Install dependencies
```bash
npm install
```

### 2. Setup Environment Variables
Buat file `.env` di root folder (copy dari `.env.example`):
```env
PORT=3000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/api-db
```

**Untuk MongoDB Atlas:**
```env
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/database-name
```

### 3. Install Mongoose (jika belum)
```bash
npm install mongoose
```

### 4. Jalankan MongoDB
- **Local:** Pastikan MongoDB service running
- **Atlas:** Pastikan sudah setup cluster

### 5. Jalankan Server

**Development mode (auto-reload):**
```bash
npm run dev
```

**Production mode:**
```bash
npm start
```

Server akan berjalan di: `http://localhost:3000`

## 📁 Struktur Folder

```
api/
├── src/
│   ├── config/
│   │   └── database.js          # Konfigurasi MongoDB
│   ├── controllers/
│   │   └── userController.js    # Business logic
│   ├── models/
│   │   └── User.js              # Schema MongoDB
│   ├── routes/
│   │   └── userRoutes.js        # API routes
│   ├── middleware/              # Custom middleware
│   └── server.js                # Entry point
├── .env                         # Environment variables
├── .env.example                 # Template environment
├── .gitignore
├── package.json
└── README.md
```

## 🔌 API Endpoints

### Base URL
```
http://localhost:3000
```

### Health Check
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Welcome message |
| GET | `/health` | Health check status |

### User Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/users` | Get all users |
| GET | `/api/users/:id` | Get user by ID |
| POST | `/api/users` | Create new user |
| PUT | `/api/users/:id` | Update user |
| DELETE | `/api/users/:id` | Delete user |
| GET | `/api/users/search?q=keyword` | Search users |

## 📝 Request Examples

### 1. Create User
```bash
POST /api/users
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "age": 25,
  "phone": "081234567890",
  "address": "Jakarta, Indonesia"
}
```

**Response:**
```json
{
  "success": true,
  "message": "User created successfully",
  "data": {
    "_id": "65f1a2b3c4d5e6f7g8h9i0j1",
    "name": "John Doe",
    "email": "john@example.com",
    "age": 25,
    "phone": "081234567890",
    "address": "Jakarta, Indonesia",
    "isActive": true,
    "createdAt": "2024-01-15T10:30:00.000Z",
    "updatedAt": "2024-01-15T10:30:00.000Z"
  }
}
```

### 2. Get All Users
```bash
GET /api/users
```

**Response:**
```json
{
  "success": true,
  "count": 2,
  "data": [
    {
      "_id": "65f1a2b3c4d5e6f7g8h9i0j1",
      "name": "John Doe",
      "email": "john@example.com",
      "age": 25,
      "isActive": true,
      "createdAt": "2024-01-15T10:30:00.000Z"
    }
  ]
}
```

### 3. Get User by ID
```bash
GET /api/users/65f1a2b3c4d5e6f7g8h9i0j1
```

### 4. Update User
```bash
PUT /api/users/65f1a2b3c4d5e6f7g8h9i0j1
Content-Type: application/json

{
  "name": "John Updated",
  "age": 26
}
```

### 5. Delete User
```bash
DELETE /api/users/65f1a2b3c4d5e6f7g8h9i0j1
```

### 6. Search Users
```bash
GET /api/users/search?q=john
```

## 🧪 Testing dengan cURL

### Create User
```bash
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"John Doe\",\"email\":\"john@example.com\",\"age\":25}"
```

### Get All Users
```bash
curl http://localhost:3000/api/users
```

### Get User by ID
```bash
curl http://localhost:3000/api/users/USER_ID
```

### Update User
```bash
curl -X PUT http://localhost:3000/api/users/USER_ID \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"John Updated\",\"age\":26}"
```

### Delete User
```bash
curl -X DELETE http://localhost:3000/api/users/USER_ID
```

### Search Users
```bash
curl http://localhost:3000/api/users/search?q=john
```

## 📦 Dependencies

- **express** - Web framework
- **mongoose** - MongoDB ODM
- **dotenv** - Environment variables
- **cors** - Cross-Origin Resource Sharing
- **helmet** - Security headers
- **morgan** - HTTP request logger
- **nodemon** - Auto-restart (dev)

## 🛠️ Development

### Menambahkan Model Baru

1. Buat file di `src/models/NamaModel.js`
2. Definisikan schema dengan mongoose
3. Export model

```javascript
const mongoose = require('mongoose');

const namaSchema = new mongoose.Schema({
  field: {
    type: String,
    required: true
  }
}, { timestamps: true });

module.exports = mongoose.model('Nama', namaSchema);
```

### Menambahkan Controller

1. Buat file di `src/controllers/namaController.js`
2. Import model
3. Buat fungsi CRUD

### Menambahkan Routes

1. Buat file di `src/routes/namaRoutes.js`
2. Import controller
3. Definisikan routes
4. Import di `server.js`

## 🔒 Security Features

- ✅ Helmet untuk security headers
- ✅ CORS enabled
- ✅ Input validation di model schema
- ✅ Error handling middleware
- ✅ Environment variables untuk sensitive data

## 📊 Database Schema

### User Model
```javascript
{
  name: String (required, 3-50 chars),
  email: String (required, unique, valid email),
  age: Number (0-120),
  phone: String,
  address: String,
  isActive: Boolean (default: true),
  timestamps: true (createdAt, updatedAt)
}
```

## 🐛 Troubleshooting

### MongoDB Connection Error
- Pastikan MongoDB service running
- Check MONGODB_URI di `.env`
- Untuk Atlas, pastikan IP address sudah di-whitelist

### Port Already in Use
- Ubah PORT di `.env`
- Atau kill process yang menggunakan port tersebut

### Module Not Found
```bash
npm install
```

## 📄 License

ISC
