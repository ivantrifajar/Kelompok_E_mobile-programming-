# API Documentation - User Management

Base URL: `http://localhost:3000`

## 📋 User Schema

```javascript
{
  nama_lengkap: String (required, 3-100 chars),
  email: String (required, unique, valid email),
  password: String (required, min 6 chars, hashed),
  role: String (enum: ['siswa', 'guru'], default: 'siswa'),
  isActive: Boolean (default: true),
  createdAt: Date (auto),
  updatedAt: Date (auto)
}
```

## 🔐 Authentication Endpoints

### 1. Register User
**POST** `/api/users/register`

**Request Body:**
```json
{
  "nama_lengkap": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "role": "siswa"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "_id": "65f1a2b3c4d5e6f7g8h9i0j1",
    "nama_lengkap": "John Doe",
    "email": "john@example.com",
    "role": "siswa",
    "isActive": true,
    "createdAt": "2024-01-15T10:30:00.000Z"
  }
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:3000/api/users/register \
  -H "Content-Type: application/json" \
  -d "{\"nama_lengkap\":\"John Doe\",\"email\":\"john@example.com\",\"password\":\"password123\",\"role\":\"siswa\"}"
```

---

### 2. Login User
**POST** `/api/users/login`

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "_id": "65f1a2b3c4d5e6f7g8h9i0j1",
    "nama_lengkap": "John Doe",
    "email": "john@example.com",
    "role": "siswa",
    "isActive": true
  }
}
```

**Error Response (401):**
```json
{
  "success": false,
  "message": "Invalid credentials"
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:3000/api/users/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"john@example.com\",\"password\":\"password123\"}"
```

---

## 👥 User Management Endpoints

### 3. Get All Users
**GET** `/api/users`

**Query Parameters:**
- `role` (optional): Filter by role ('siswa' or 'guru')

**Examples:**
- Get all users: `GET /api/users`
- Get only siswa: `GET /api/users?role=siswa`
- Get only guru: `GET /api/users?role=guru`

**Response (200):**
```json
{
  "success": true,
  "count": 2,
  "data": [
    {
      "_id": "65f1a2b3c4d5e6f7g8h9i0j1",
      "nama_lengkap": "John Doe",
      "email": "john@example.com",
      "role": "siswa",
      "isActive": true,
      "createdAt": "2024-01-15T10:30:00.000Z"
    }
  ]
}
```

**cURL Example:**
```bash
# Get all users
curl http://localhost:3000/api/users

# Get only siswa
curl http://localhost:3000/api/users?role=siswa

# Get only guru
curl http://localhost:3000/api/users?role=guru
```

---

### 4. Get User by ID
**GET** `/api/users/:id`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "_id": "65f1a2b3c4d5e6f7g8h9i0j1",
    "nama_lengkap": "John Doe",
    "email": "john@example.com",
    "role": "siswa",
    "isActive": true,
    "createdAt": "2024-01-15T10:30:00.000Z"
  }
}
```

**cURL Example:**
```bash
curl http://localhost:3000/api/users/65f1a2b3c4d5e6f7g8h9i0j1
```

---

### 5. Create User
**POST** `/api/users`

**Request Body:**
```json
{
  "nama_lengkap": "Jane Smith",
  "email": "jane@example.com",
  "password": "password123",
  "role": "guru"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "User created successfully",
  "data": {
    "_id": "65f1a2b3c4d5e6f7g8h9i0j2",
    "nama_lengkap": "Jane Smith",
    "email": "jane@example.com",
    "role": "guru",
    "isActive": true,
    "createdAt": "2024-01-15T11:00:00.000Z"
  }
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d "{\"nama_lengkap\":\"Jane Smith\",\"email\":\"jane@example.com\",\"password\":\"password123\",\"role\":\"guru\"}"
```

---

### 6. Update User
**PUT** `/api/users/:id`

**Request Body (partial update allowed):**
```json
{
  "nama_lengkap": "John Doe Updated",
  "role": "guru"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "User updated successfully",
  "data": {
    "_id": "65f1a2b3c4d5e6f7g8h9i0j1",
    "nama_lengkap": "John Doe Updated",
    "email": "john@example.com",
    "role": "guru",
    "isActive": true,
    "updatedAt": "2024-01-15T12:00:00.000Z"
  }
}
```

**cURL Example:**
```bash
curl -X PUT http://localhost:3000/api/users/65f1a2b3c4d5e6f7g8h9i0j1 \
  -H "Content-Type: application/json" \
  -d "{\"nama_lengkap\":\"John Doe Updated\",\"role\":\"guru\"}"
```

---

### 7. Delete User
**DELETE** `/api/users/:id`

**Response (200):**
```json
{
  "success": true,
  "message": "User deleted successfully",
  "data": {}
}
```

**cURL Example:**
```bash
curl -X DELETE http://localhost:3000/api/users/65f1a2b3c4d5e6f7g8h9i0j1
```

---

### 8. Search Users
**GET** `/api/users/search?q=keyword`

**Query Parameters:**
- `q` (required): Search keyword
- `role` (optional): Filter by role

**Examples:**
- Search all users: `GET /api/users/search?q=john`
- Search only siswa: `GET /api/users/search?q=john&role=siswa`
- Search only guru: `GET /api/users/search?q=jane&role=guru`

**Response (200):**
```json
{
  "success": true,
  "count": 1,
  "data": [
    {
      "_id": "65f1a2b3c4d5e6f7g8h9i0j1",
      "nama_lengkap": "John Doe",
      "email": "john@example.com",
      "role": "siswa",
      "isActive": true
    }
  ]
}
```

**cURL Example:**
```bash
# Search all users
curl "http://localhost:3000/api/users/search?q=john"

# Search only siswa
curl "http://localhost:3000/api/users/search?q=john&role=siswa"

# Search only guru
curl "http://localhost:3000/api/users/search?q=jane&role=guru"
```

---

## 🔒 Security Features

- ✅ Password automatically hashed with bcrypt (10 salt rounds)
- ✅ Password never returned in responses
- ✅ Email uniqueness enforced
- ✅ Input validation on all fields
- ✅ Role-based access (siswa/guru)

---

## ⚠️ Error Responses

### 400 Bad Request
```json
{
  "success": false,
  "message": "Email already exists"
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "message": "Invalid credentials"
}
```

### 404 Not Found
```json
{
  "success": false,
  "message": "User not found"
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "message": "Error message here",
  "error": "Detailed error (development only)"
}
```

---

## 🧪 Testing Flow

### 1. Register a Siswa
```bash
curl -X POST http://localhost:3000/api/users/register \
  -H "Content-Type: application/json" \
  -d "{\"nama_lengkap\":\"Ahmad Siswa\",\"email\":\"ahmad@example.com\",\"password\":\"123456\",\"role\":\"siswa\"}"
```

### 2. Register a Guru
```bash
curl -X POST http://localhost:3000/api/users/register \
  -H "Content-Type: application/json" \
  -d "{\"nama_lengkap\":\"Ibu Guru\",\"email\":\"guru@example.com\",\"password\":\"123456\",\"role\":\"guru\"}"
```

### 3. Login
```bash
curl -X POST http://localhost:3000/api/users/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"ahmad@example.com\",\"password\":\"123456\"}"
```

### 4. Get All Siswa
```bash
curl "http://localhost:3000/api/users?role=siswa"
```

### 5. Get All Guru
```bash
curl "http://localhost:3000/api/users?role=guru"
```

### 6. Search Users
```bash
curl "http://localhost:3000/api/users/search?q=ahmad"
```

---

## 📝 Notes

- Password minimum 6 characters
- Email must be valid format
- Role can only be 'siswa' or 'guru'
- Default role is 'siswa' if not specified
- All timestamps are in ISO 8601 format
