const express = require('express');
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

const app = express();

app.use(helmet({ crossOriginResourcePolicy: { policy: 'cross-origin' } }));
app.use(cors({
  origin: env.ALLOWED_ORIGINS.split(',').map(o => o.trim()),
  credentials: true,
}));
app.use(express.json({ limit: '10mb' }));
app.use(compression());
if (env.NODE_ENV !== 'test') app.use(morgan('[:date[iso]] :method :url :status :response-time ms'));

app.get('/health', (req, res) => res.json({ status: 'ok', app: 'TFI Bagundali', version: '2.0.0' }));

app.use('/v1/auth', authRoutes);
app.use('/v1/home', homeRoutes);
app.use('/v1/updates', updatesRoutes);
app.use('/v1/movies', moviesRoutes);
app.use('/v1/heroes', heroesRoutes);
app.use('/v1/quiz', quizRoutes);
app.use('/v1/polls', pollsRoutes);
app.use('/v1/explore', exploreRoutes);
app.use('/v1/profile', profileRoutes);

app.use((req, res) => {
  res.status(404).json({ success: false, error: { code: 'NOT_FOUND', message: 'Route not found', statusCode: 404 } });
});

app.use(errorMiddleware);

module.exports = app;
