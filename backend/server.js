require('dotenv').config();
const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const jwt = require('jsonwebtoken');

const app = express();
app.use(cors());
app.use(express.json({ limit: '10mb' })); // Image luu dang base64

mongoose
  .connect(process.env.MONGO_URI, { dbName: 'QLHocPhan' })
  .then(() => console.log('Da ket noi MongoDB Atlas'))
  .catch((e) => {
    console.error('Loi ket noi MongoDB:', e.message);
    process.exit(1);
  });

const giangVienSchema = new mongoose.Schema(
  {
    IDGV: { type: String, required: true, unique: true, trim: true },
    Fullname: { type: String, required: true, trim: true },
    Image: { type: String, default: '' },
    SumClass: { type: Number, required: true, min: 0 },
  },
  { collection: 'GiangVien', versionKey: false, strict: true }
);
const GiangVien = mongoose.model('GiangVien', giangVienSchema);

const pick = (b) => ({
  IDGV: b.IDGV,
  Fullname: b.Fullname,
  Image: b.Image || '',
  SumClass: Number(b.SumClass),
});

app.post('/api/login', (req, res) => {
  const { username, password } = req.body || {};
  if (username === process.env.ADMIN_USER && password === process.env.ADMIN_PASS) {
    const token = jwt.sign({ role: 'admin' }, process.env.JWT_SECRET, { expiresIn: '8h' });
    return res.json({ token });
  }
  res.status(401).json({ message: 'Sai tai khoan hoac mat khau' });
});

const auth = (req, res, next) => {
  const token = (req.headers.authorization || '').replace('Bearer ', '');
  try {
    jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch {
    res.status(401).json({ message: 'Unauthorized' });
  }
};

const handleError = (res, e) => {
  if (e.code === 11000) return res.status(409).json({ message: 'IDGV da ton tai' });
  if (e.name === 'ValidationError') return res.status(400).json({ message: e.message });
  res.status(500).json({ message: e.message });
};

// ---------- CRUD ----------
app.get('/api/giangvien', auth, async (req, res) => {
  try {
    const q = (req.query.q || '').trim();
    const filter = q
      ? {
          $or: [
            { IDGV: { $regex: q, $options: 'i' } },
            { Fullname: { $regex: q, $options: 'i' } },
          ],
        }
      : {};
    res.json(await GiangVien.find(filter).sort({ IDGV: 1 }));
  } catch (e) {
    handleError(res, e);
  }
});

app.post('/api/giangvien', auth, async (req, res) => {
  try {
    res.status(201).json(await GiangVien.create(pick(req.body)));
  } catch (e) {
    handleError(res, e);
  }
});

app.put('/api/giangvien/:id', auth, async (req, res) => {
  try {
    const gv = await GiangVien.findByIdAndUpdate(req.params.id, pick(req.body), {
      new: true,
      runValidators: true,
    });
    if (!gv) return res.status(404).json({ message: 'Khong tim thay giang vien' });
    res.json(gv);
  } catch (e) {
    handleError(res, e);
  }
});

app.delete('/api/giangvien/:id', auth, async (req, res) => {
  try {
    const gv = await GiangVien.findByIdAndDelete(req.params.id);
    if (!gv) return res.status(404).json({ message: 'Khong tim thay giang vien' });
    res.json({ message: 'Da xoa' });
  } catch (e) {
    handleError(res, e);
  }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server chay tai http://localhost:${PORT}`));
