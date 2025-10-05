const express = require("express");
const { MongoClient, ObjectId } = require("mongodb");
const cors = require("cors");
const bcrypt = require("bcrypt");

// Fungsi untuk membuat kode kelas unik
function generateClassCode() {
  return Math.random().toString(36).substring(2, 8).toUpperCase();
}

const app = express();
app.use(cors());
app.use(express.json());

const uri = "mongodb+srv://ivantrifajar:Ivantrifajar35@eduflip.u56cklg.mongodb.net/?retryWrites=true&w=majority&appName=EduFlip";
const client = new MongoClient(uri);

async function main() {
  try {
    await client.connect();
    console.log("✅ MongoDB Atlas Connected");

    const db = client.db("eduflipdb");
    const users = db.collection("users");
    const classes = db.collection("classes");
    const topics = db.collection("topics");
    const flashcards = db.collection("flashcards");

    app.get("/", (req, res) => {
      res.json({ message: "Welcome to EduFlip API!" });
    });

    // --- API REGISTER & LOGIN ---
    app.post("/register", async (req, res) => {
        const { username, email, password, role } = req.body;
        if (!username || !email || !password || !role) { return res.status(400).json({ success: false, message: "Semua kolom wajib diisi" }); }
        try {
            const existingUser = await users.findOne({ $or: [{ username: username }, { email: email }] });
            if (existingUser) { return res.status(409).json({ success: false, message: "Username atau email sudah terdaftar" }); }
            const salt = await bcrypt.genSalt(10);
            const hashedPassword = await bcrypt.hash(password, salt);
            await users.insertOne({ username, email, password: hashedPassword, role: role, createdAt: new Date() });
            res.status(201).json({ success: true, message: "Registrasi berhasil" });
        } catch (err) { res.status(500).json({ success: false, message: "Terjadi kesalahan server" }); }
    });
    app.post("/login", async (req, res) => {
        const { username, password } = req.body;
        if (!username || !password) { return res.status(400).json({ success: false, message: "Username & Password wajib diisi" }); }
        try {
            const user = await users.findOne({ username: username });
            if (!user) { return res.status(404).json({ success: false, message: "Username tidak ditemukan" }); }
            const isPasswordMatch = await bcrypt.compare(password, user.password);
            if (isPasswordMatch) {
                const userProfile = { username: user.username, email: user.email, role: user.role };
                return res.status(200).json({ success: true, message: "Login berhasil", user: userProfile });
            } else { return res.status(401).json({ success: false, message: "Password salah" }); }
        } catch (err) { res.status(500).json({ success: false, message: "Terjadi kesalahan server" }); }
    });

    // --- API KELAS ---
    app.post('/classes', async (req, res) => {
        const { className, createdBy } = req.body;
        const classCode = generateClassCode();
        const newClass = { className, classCode, teacher: createdBy, students: [], createdAt: new Date() };
        const result = await classes.insertOne(newClass);
        res.status(201).json({ success: true, message: `Kelas '${className}' berhasil dibuat`, classId: result.insertedId });
    });
    app.get('/teacher-classes/:username', async (req, res) => {
        const teacherClasses = await classes.find({ teacher: req.params.username }).toArray();
        res.status(200).json({ success: true, classes: teacherClasses });
    });
    app.get('/my-classes/:username', async (req, res) => {
        const enrolledClasses = await classes.find({ students: req.params.username }).toArray();
        res.status(200).json({ success: true, classes: enrolledClasses });
    });
    
    // --- API FLASHCARD ---
    app.post('/topics', async (req, res) => {
        const { topicName, classId } = req.body;
        if (!topicName || !classId) { return res.status(400).json({ success: false, message: "Nama topik dan ID kelas wajib diisi" }); }
        try {
            await topics.insertOne({ topicName, classId: new ObjectId(classId), createdAt: new Date() });
            res.status(201).json({ success: true, message: "Topik baru berhasil dibuat" });
        } catch (err) { res.status(500).json({ success: false, message: "Gagal membuat topik" }); }
    });
    
    app.post('/flashcards', async (req, res) => {
        const { question, answer, topicId } = req.body;
        if (!question || !answer || !topicId) { return res.status(400).json({ success: false, message: "Judul dan Materi wajib diisi" }); }
        try {
            await flashcards.insertOne({ question, answer, topicId: new ObjectId(topicId), createdAt: new Date() });
            res.status(201).json({ success: true, message: "Kartu baru berhasil ditambahkan" });
        } catch (err) { res.status(500).json({ success: false, message: "Gagal menambahkan kartu" }); }
    });

    app.get('/topics/:classId', async (req, res) => {
        try {
            const classTopics = await topics.find({ classId: new ObjectId(req.params.classId) }).sort({ createdAt: -1 }).toArray();
            res.status(200).json({ success: true, topics: classTopics });
        } catch (err) { res.status(500).json({ success: false, message: "Gagal mengambil topik" }); }
    });
    
    app.get('/flashcards/:topicId', async (req, res) => {
        try {
            const topicFlashcards = await flashcards.find({ topicId: new ObjectId(req.params.topicId) }).sort({ createdAt: -1 }).toArray();
            res.status(200).json({ success: true, flashcards: topicFlashcards });
        } catch (err) { res.status(500).json({ success: false, message: "Gagal mengambil kartu" }); }
    });

    app.put('/flashcards/:cardId', async (req, res) => {
        const { question, answer } = req.body;
        try {
            await flashcards.updateOne({ _id: new ObjectId(req.params.cardId) }, { $set: { question, answer } });
            res.status(200).json({ success: true, message: "Kartu berhasil diperbarui" });
        } catch (err) { res.status(500).json({ success: false, message: "Gagal memperbarui kartu" }); }
    });

    app.delete('/flashcards/:cardId', async (req, res) => {
        try {
            await flashcards.deleteOne({ _id: new ObjectId(req.params.cardId) });
            res.status(200).json({ success: true, message: "Kartu berhasil dihapus" });
        } catch (err) { res.status(500).json({ success: false, message: "Gagal menghapus kartu" }); }
    });

    app.listen(3000, '0.0.0.0', () => {
      console.log("🚀 Server running on port 3000 and accessible on the network");
    });

  } catch (err) {
    console.error("❌ Error:", err);
  }
}

main();

