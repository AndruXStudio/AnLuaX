const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const app = express();
const PORT = process.env.PORT || 8790;
const DATA = path.join(__dirname, 'data');
const DB = path.join(DATA, 'db.json');
fs.mkdirSync(DATA, { recursive: true });
function load() {
  if (!fs.existsSync(DB)) {
    const seed = {
      users: {
        admin: { id: 'admin', username: 'admin', password: hash('admin123'), email: 'admin@anluax.local', role: 'admin', points: 99999, banned: false },
        demo: { id: 'demo', username: 'demo', password: hash('demo123'), email: 'demo@anluax.local', role: 'user', points: 500, banned: false },
        banned: {
          id: 'banned', username: 'banned', password: hash('banned123'), email: 'banned@anluax.local', role: 'user', points: 0, banned: true,
          banReason: '发布违规内容 / 恶意刷分', banAt: '2026-10-20 14:32:08', unbanAt: '2026-11-20 14:32:08',
          violation: '在源码区发布含恶意代码的示例', reviewAt: '2026-10-20 14:30:01'
        }
      },
      posts: [
        { id: 'p1', title: '极品MD3弹窗+远程验证', summary: '- 自己对接到自己的项目里', content: 'MD3', code: 'print("MD3")\n', author: 'demo', price: 30, likes: 0, stars: 0, comments: 4, views: 277, createdAt: '2026-10-22 23:54:05', deleted: false },
        { id: 'p2', title: 'SelectableCards', summary: 'require import', content: 'cards', code: 'print("SelectableCards")\n', author: 'demo', price: 0, likes: 0, stars: 0, comments: 0, views: 252, createdAt: '2026-10-22 22:36:20', deleted: false }
      ],
      purchases: {},
      tokens: {}
    };
    fs.writeFileSync(DB, JSON.stringify(seed, null, 2));
  }
  return JSON.parse(fs.readFileSync(DB, 'utf8'));
}
function save(db) { fs.writeFileSync(DB, JSON.stringify(db, null, 2)); }
function hash(s) { return crypto.createHash('sha256').update(String(s)).digest('hex'); }
function publicUser(u) {
  if (!u) return null;
  return { id: u.id, username: u.username, displayName: u.banned ? '账户已被封禁' : u.username, role: u.role, points: u.points, banned: !!u.banned, banReason: u.banReason, banAt: u.banAt, unbanAt: u.unbanAt, violation: u.violation, reviewAt: u.reviewAt, joinedAt: u.joinedAt || '2025-09-02' };
}
function auth(req) {
  const h = req.headers.authorization || '';
  const t = h.startsWith('Bearer ') ? h.slice(7) : '';
  const db = load();
  const uid = db.tokens[t];
  return uid ? db.users[uid] : null;
}
app.use(cors());
app.use(express.json({ limit: '2mb' }));
app.get('/api/health', (_, res) => res.json({ ok: true, name: 'AnLuaX', time: Date.now() }));
app.post('/api/auth/register', (req, res) => {
  const { username, password, email, code } = req.body || {};
  if (!username || !password || !email) return res.status(400).json({ ok: false, error: '请填写完整信息' });
  if (!String(email).includes('@')) return res.status(400).json({ ok: false, error: '邮箱格式不正确' });
  if (!/^\d{6}$/.test(String(code || ''))) return res.status(400).json({ ok: false, error: '请输入 6 位验证码' });
  const db = load();
  if (db.users[username]) return res.status(400).json({ ok: false, error: '用户名已存在' });
  db.users[username] = { id: username, username, password: hash(password), email, role: 'user', points: 100, banned: false, joinedAt: new Date().toISOString().slice(0, 10) };
  const token = crypto.randomBytes(24).toString('hex');
  db.tokens[token] = username;
  save(db);
  res.json({ ok: true, token, user: publicUser(db.users[username]) });
});
app.post('/api/auth/login', (req, res) => {
  const { username, password } = req.body || {};
  const db = load();
  const u = db.users[username];
  if (!u || u.password !== hash(password)) return res.status(401).json({ ok: false, error: '用户名或密码错误' });
  const token = crypto.randomBytes(24).toString('hex');
  db.tokens[token] = username;
  save(db);
  res.json({ ok: true, token, user: publicUser(u) });
});
app.get('/api/me', (req, res) => {
  const u = auth(req);
  if (!u) return res.status(401).json({ ok: false, error: '未登录' });
  res.json({ ok: true, user: publicUser(u) });
});
app.get('/api/posts', (req, res) => {
  const db = load();
  const u = auth(req);
  const list = db.posts.filter(p => !p.deleted).map(p => {
    const author = publicUser(db.users[p.author] || { id: p.author, username: p.author, role: 'user', points: 0 });
    const purchased = !!(u && (db.purchases[u.username] || []).includes(p.id));
    return Object.assign({}, p, { author, purchased, code: (p.price === 0 || purchased) ? p.code : null });
  });
  res.json({ ok: true, items: list });
});
app.get('/api/posts/:id', (req, res) => {
  const db = load();
  const u = auth(req);
  const p = db.posts.find(x => x.id === req.params.id && !x.deleted);
  if (!p) return res.status(404).json({ ok: false, error: '不存在' });
  const purchased = !!(u && (db.purchases[u.username] || []).includes(p.id));
  const author = publicUser(db.users[p.author] || { id: p.author, username: p.author, role: 'user', points: 0 });
  res.json({ ok: true, post: Object.assign({}, p, { author, purchased, code: (p.price === 0 || purchased) ? p.code : null }) });
});
app.post('/api/posts/:id/purchase', (req, res) => {
  const u = auth(req);
  if (!u) return res.status(401).json({ ok: false, error: '请先登录' });
  if (u.banned) return res.status(403).json({ ok: false, error: '账户已被封禁' });
  const db = load();
  const p = db.posts.find(x => x.id === req.params.id && !x.deleted);
  if (!p) return res.status(404).json({ ok: false, error: '不存在' });
  db.purchases[u.username] = db.purchases[u.username] || [];
  if (db.purchases[u.username].includes(p.id) || p.price <= 0) return res.json({ ok: true, user: publicUser(u), code: p.code });
  if (u.points < p.price) return res.status(400).json({ ok: false, error: '积分不足' });
  u.points -= p.price;
  if (db.users[p.author]) db.users[p.author].points = (db.users[p.author].points || 0) + p.price;
  db.purchases[u.username].push(p.id);
  save(db);
  res.json({ ok: true, user: publicUser(u), code: p.code });
});
app.get('/api/users/:username', (req, res) => {
  const db = load();
  const u = db.users[req.params.username];
  if (!u) return res.status(404).json({ ok: false, error: '用户不存在' });
  const posts = u.banned ? [] : db.posts.filter(p => p.author === u.username && !p.deleted).map(p => ({ id: p.id, title: p.title, summary: p.summary, price: p.price, createdAt: p.createdAt, views: p.views }));
  res.json({ ok: true, user: publicUser(u), posts });
});
app.listen(PORT, '0.0.0.0', () => console.log('AnLuaX API on', PORT));
