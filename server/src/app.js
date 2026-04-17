const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const compression = require('compression');
const morgan = require('morgan');
const env = require('./config/env');

const authRoutes = require('./modules/auth/auth.routes');
const quizRoutes = require('./modules/quiz/quiz.routes');
const coinsRoutes = require('./modules/coins/coins.routes');
const contentRoutes = require('./modules/content/content.routes');
const fanArmyRoutes = require('./modules/fanarmy/fanarmy.routes');
const premiumRoutes = require('./modules/premium/premium.routes');
const adminRoutes = require('./modules/admin/admin.routes');
const errorMiddleware = require('./middleware/error.middleware');

const app = express();

// Security
app.use(helmet({ crossOriginResourcePolicy: { policy: 'cross-origin' } }));
app.use(cors({
  origin: env.ALLOWED_ORIGINS.split(',').map(o => o.trim()),
  credentials: true,
}));

// Body parsing & compression
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(compression());

// Logging
if (env.NODE_ENV !== 'test') {
  app.use(morgan('[:date[iso]] :method :url :status :response-time ms'));
}

// Health check
app.get('/health', (req, res) => res.json({ status: 'ok', env: env.NODE_ENV }));

// API Routes
app.use('/v1/auth', authRoutes);
app.use('/v1/quiz', quizRoutes);
app.use('/v1/coins', coinsRoutes);
app.use('/v1', contentRoutes);
app.use('/v1', fanArmyRoutes);
app.use('/v1/premium', premiumRoutes);
app.use('/v1/admin', adminRoutes);

// 404
app.use((req, res) => {
  res.status(404).json({ success: false, error: { code: 'NOT_FOUND', message: 'Route not found', statusCode: 404 } });
});

// Global error handler
app.use(errorMiddleware);

module.exports = app;
