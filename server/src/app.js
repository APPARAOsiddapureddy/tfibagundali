const express = require('express');
const path = require('path');
const helmet = require('helmet');
const cors = require('cors');
const compression = require('compression');
const morgan = require('morgan');
const env = require('./config/env');
const errorMiddleware = require('./middleware/error.middleware');

const authRoutes = require('./modules/auth/auth.routes');
const homeRoutes = require('./modules/home/home.routes');
const updatesRoutes = require('./modules/updates/updates.routes');
const moviesRoutes = require('./modules/movies/movies.routes');
const heroesRoutes = require('./modules/heroes/heroes.routes');
const quizRoutes = require('./modules/quiz/quiz.routes');
const pollsRoutes = require('./modules/polls/polls.routes');
const exploreRoutes = require('./modules/explore/explore.routes');
const profileRoutes = require('./modules/profile/profile.routes');
const recommendationsRoutes = require('./modules/recommendations/recommendations.routes');
const wallpapersRoutes = require('./modules/wallpapers/wallpapers.routes');
const statusCardsRoutes = require('./modules/status-cards/status-cards.routes');
const remindersRoutes = require('./modules/reminders/reminders.routes');
const searchRoutes = require('./modules/search/search.routes');
const notificationsRoutes = require('./modules/notifications/notifications.routes');
const adminRoutes = require('./modules/admin/admin.routes');
const recController = require('./modules/recommendations/recommendations.controller');
const { optionalAuth } = require('./middleware/auth.middleware');

const app = express();

app.use(helmet({ crossOriginResourcePolicy: { policy: 'cross-origin' } }));
const allowedOrigins = env.ALLOWED_ORIGINS.split(',').map((o) => o.trim());
app.use(cors({
  origin(origin, callback) {
    if (!origin) return callback(null, true);
    if (allowedOrigins.includes(origin)) return callback(null, true);
    if (env.NODE_ENV === 'development' && /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin)) {
      return callback(null, true);
    }
    callback(new Error('Not allowed by CORS'));
  },
  credentials: true,
}));
app.use(express.json({ limit: '10mb' }));
app.use('/uploads', express.static(path.join(process.cwd(), env.UPLOAD_DIR), {
  dotfiles: 'deny',
  index: false,
}));
app.use(compression());
if (env.NODE_ENV !== 'test') app.use(morgan('[:date[iso]] :method :url :status :response-time ms'));

app.get('/health', (req, res) => res.json({
  success: true,
  data: { status: 'ok', app: 'TFI Bagundali', version: '2.1.0' },
}));

app.get('/admin/upload', (_req, res) => {
  res.sendFile(path.join(__dirname, '../public/admin-upload.html'));
});

app.use('/v1/auth', authRoutes);
app.use('/v1/home', homeRoutes);
app.use('/v1/updates', updatesRoutes);
app.use('/v1/movies', moviesRoutes);
app.use('/v1/heroes', heroesRoutes);
app.use('/v1/quiz', quizRoutes);
app.use('/v1/polls', pollsRoutes);
app.use('/v1/explore', exploreRoutes);
app.use('/v1/profile', profileRoutes);
app.use('/v1/wallpapers', wallpapersRoutes);
app.use('/v1/status-cards', statusCardsRoutes);
app.use('/v1/reminders', remindersRoutes);
app.use('/v1/search', searchRoutes);
app.use('/v1/notifications', notificationsRoutes);
app.use('/v1/recommendations', recommendationsRoutes);
app.use('/v1/admin', adminRoutes);
app.post('/v1/events', optionalAuth, recController.postEvent);

app.use((req, res) => {
  res.status(404).json({ success: false, error: { code: 'NOT_FOUND', message: 'Route not found', statusCode: 404 } });
});

app.use(errorMiddleware);

module.exports = app;
