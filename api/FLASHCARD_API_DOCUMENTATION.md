# Flashcard API Documentation

## Base URL
```
http://localhost:3000/api/flashcards
```

## Endpoints

### 1. Create Flashcard
**POST** `/api/flashcards`

**Description:** Create a new flashcard set

**Request Body:**
```json
{
  "judul": "Matematika Dasar",
  "topik": "Operasi Bilangan dan Aljabar", 
  "deskripsi": "Flashcard untuk mempelajari operasi dasar matematika",
  "kelas_id": "60d5ecb74b24a12b8c8e4567",
  "guru_id": "60d5ecb74b24a12b8c8e4568",
  "kartu": [
    {
      "pertanyaan": "Berapa hasil dari 2 + 3?",
      "jawaban": "5"
    },
    {
      "pertanyaan": "Berapa hasil dari 5 x 4?", 
      "jawaban": "20"
    }
  ]
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Flashcard created successfully",
  "data": {
    "_id": "60d5ecb74b24a12b8c8e4569",
    "judul": "Matematika Dasar",
    "topik": "Operasi Bilangan dan Aljabar",
    "deskripsi": "Flashcard untuk mempelajari operasi dasar matematika",
    "kelas_id": {
      "_id": "60d5ecb74b24a12b8c8e4567",
      "nama": "Kelas 10A",
      "tahun_ajaran": "2023/2024"
    },
    "guru_id": {
      "_id": "60d5ecb74b24a12b8c8e4568",
      "nama_lengkap": "John Doe",
      "email": "john@example.com"
    },
    "kartu": [
      {
        "_id": "60d5ecb74b24a12b8c8e456a",
        "pertanyaan": "Berapa hasil dari 2 + 3?",
        "jawaban": "5"
      },
      {
        "_id": "60d5ecb74b24a12b8c8e456b", 
        "pertanyaan": "Berapa hasil dari 5 x 4?",
        "jawaban": "20"
      }
    ],
    "jumlahKartu": 2,
    "isActive": true,
    "totalViews": 0,
    "totalStudents": 0,
    "createdAt": "2023-06-25T10:30:00.000Z",
    "updatedAt": "2023-06-25T10:30:00.000Z"
  }
}
```

### 2. Get All Flashcards
**GET** `/api/flashcards`

**Query Parameters:**
- `kelas_id` (optional): Filter by class ID
- `guru_id` (optional): Filter by teacher ID  
- `isActive` (optional): Filter by active status (true/false)
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 10)
- `search` (optional): Search in title, topic, or description

**Example:** `/api/flashcards?kelas_id=60d5ecb74b24a12b8c8e4567&page=1&limit=5`

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "_id": "60d5ecb74b24a12b8c8e4569",
      "judul": "Matematika Dasar",
      "topik": "Operasi Bilangan dan Aljabar",
      "deskripsi": "Flashcard untuk mempelajari operasi dasar matematika",
      "kelas_id": {
        "_id": "60d5ecb74b24a12b8c8e4567",
        "nama": "Kelas 10A",
        "tahun_ajaran": "2023/2024"
      },
      "guru_id": {
        "_id": "60d5ecb74b24a12b8c8e4568",
        "nama_lengkap": "John Doe",
        "email": "john@example.com"
      },
      "jumlahKartu": 2,
      "isActive": true,
      "totalViews": 15,
      "totalStudents": 5,
      "createdAt": "2023-06-25T10:30:00.000Z",
      "updatedAt": "2023-06-25T10:30:00.000Z"
    }
  ],
  "pagination": {
    "current_page": 1,
    "per_page": 10,
    "total": 25,
    "total_pages": 3
  }
}
```

### 3. Get Flashcard by ID
**GET** `/api/flashcards/:id`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "_id": "60d5ecb74b24a12b8c8e4569",
    "judul": "Matematika Dasar",
    "topik": "Operasi Bilangan dan Aljabar",
    "deskripsi": "Flashcard untuk mempelajari operasi dasar matematika",
    "kelas_id": {
      "_id": "60d5ecb74b24a12b8c8e4567",
      "nama": "Kelas 10A",
      "tahun_ajaran": "2023/2024"
    },
    "guru_id": {
      "_id": "60d5ecb74b24a12b8c8e4568",
      "nama_lengkap": "John Doe",
      "email": "john@example.com"
    },
    "kartu": [
      {
        "_id": "60d5ecb74b24a12b8c8e456a",
        "pertanyaan": "Berapa hasil dari 2 + 3?",
        "jawaban": "5"
      },
      {
        "_id": "60d5ecb74b24a12b8c8e456b",
        "pertanyaan": "Berapa hasil dari 5 x 4?", 
        "jawaban": "20"
      }
    ],
    "jumlahKartu": 2,
    "isActive": true,
    "totalViews": 16,
    "totalStudents": 5,
    "createdAt": "2023-06-25T10:30:00.000Z",
    "updatedAt": "2023-06-25T10:30:00.000Z"
  }
}
```

### 4. Update Flashcard
**PUT** `/api/flashcards/:id`

**Request Body:**
```json
{
  "judul": "Matematika Dasar - Updated",
  "topik": "Operasi Bilangan dan Aljabar Lanjutan",
  "deskripsi": "Flashcard untuk mempelajari operasi dasar dan lanjutan matematika",
  "kelas_id": "60d5ecb74b24a12b8c8e4567",
  "kartu": [
    {
      "pertanyaan": "Berapa hasil dari 2 + 3?",
      "jawaban": "5"
    },
    {
      "pertanyaan": "Berapa hasil dari 5 x 4?",
      "jawaban": "20"
    },
    {
      "pertanyaan": "Berapa hasil dari 10 - 7?",
      "jawaban": "3"
    }
  ]
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Flashcard updated successfully",
  "data": {
    // Updated flashcard data
  }
}
```

### 5. Delete Flashcard
**DELETE** `/api/flashcards/:id`

**Response (200):**
```json
{
  "success": true,
  "message": "Flashcard deleted successfully"
}
```

### 6. Toggle Active Status
**PATCH** `/api/flashcards/:id/toggle-active`

**Response (200):**
```json
{
  "success": true,
  "message": "Flashcard activated successfully",
  "data": {
    // Updated flashcard data with new isActive status
  }
}
```

### 7. Get Flashcards by Class
**GET** `/api/flashcards/kelas/:kelasId`

**Query Parameters:**
- `isActive` (optional): Filter by active status (default: true)

**Response (200):**
```json
{
  "success": true,
  "data": [
    // Array of flashcards for the specified class
  ],
  "count": 5
}
```

### 8. Search Flashcards
**GET** `/api/flashcards/search`

**Query Parameters:**
- `q` (required): Search query
- `kelas_id` (optional): Filter by class ID
- `guru_id` (optional): Filter by teacher ID

**Example:** `/api/flashcards/search?q=matematika&kelas_id=60d5ecb74b24a12b8c8e4567`

**Response (200):**
```json
{
  "success": true,
  "data": [
    // Array of matching flashcards (max 20 results)
  ],
  "count": 3
}
```

## Error Responses

### 400 Bad Request
```json
{
  "success": false,
  "message": "All fields are required (judul, topik, deskripsi, kelas_id, guru_id, kartu)"
}
```

### 404 Not Found
```json
{
  "success": false,
  "message": "Flashcard not found"
}
```

### 500 Server Error
```json
{
  "success": false,
  "message": "Server error",
  "error": "Error details"
}
```

## Data Validation

### Flashcard Fields
- `judul`: Required, 3-200 characters
- `topik`: Required, 3-200 characters  
- `deskripsi`: Required, 10-1000 characters
- `kelas_id`: Required, valid ObjectId
- `guru_id`: Required, valid ObjectId
- `kartu`: Required array with at least 1 item

### Flashcard Item Fields
- `pertanyaan`: Required, 3-1000 characters
- `jawaban`: Required, 1-1000 characters

## Features
- ✅ Full CRUD operations
- ✅ Pagination support
- ✅ Search functionality
- ✅ Filter by class and teacher
- ✅ Active/inactive status toggle
- ✅ View count tracking
- ✅ Data validation
- ✅ Error handling
- ✅ Population of related data (kelas, guru)
