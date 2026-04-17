const BASE = import.meta.env.VITE_API_URL || '/v1';

let _accessToken = localStorage.getItem('access_token') || null;
let _refreshToken = localStorage.getItem('refresh_token') || null;

function setTokens(access, refresh) {
  _accessToken = access;
  _refreshToken = refresh;
  localStorage.setItem('access_token', access);
  localStorage.setItem('refresh_token', refresh);
}

function clearTokens() {
  _accessToken = null;
  _refreshToken = null;
  localStorage.removeItem('access_token');
  localStorage.removeItem('refresh_token');
}

async function request(path, options = {}) {
  const headers = { 'Content-Type': 'application/json', ...options.headers };
  if (_accessToken) headers['Authorization'] = `Bearer ${_accessToken}`;

  const res = await fetch(`${BASE}${path}`, { ...options, headers });
  const json = await res.json().catch(() => ({}));

  if (res.status === 401 && _refreshToken && !options._retry) {
    try {
      const refreshRes = await fetch(`${BASE}/auth/token/refresh`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refresh_token: _refreshToken }),
      });
      const refreshJson = await refreshRes.json();
      if (refreshJson.success) {
        setTokens(refreshJson.data.access_token, refreshJson.data.refresh_token);
        return request(path, { ...options, _retry: true });
      }
    } catch (_) {}
    clearTokens();
    window.location.reload();
    return;
  }

  if (!json.success) throw { ...json.error, status: res.status };
  return json.data;
}

const get = (path) => request(path);
const post = (path, body) => request(path, { method: 'POST', body: JSON.stringify(body) });
const patch = (path, body) => request(path, { method: 'PATCH', body: JSON.stringify(body) });
const del = (path) => request(path, { method: 'DELETE' });

export const authApi = {
  sendOtp: (phone) => post('/auth/otp/send', { phone }),
  verifyOtp: (phone, code, device_id) => post('/auth/otp/verify', { phone, code, device_id }),
  refreshTokens: (refresh_token) => post('/auth/token/refresh', { refresh_token }),
  logout: (refresh_token) => post('/auth/logout', { refresh_token }),
  getMe: () => get('/auth/me'),
  updateMe: (fields) => patch('/auth/me', fields),
  setTokens,
  clearTokens,
  getAccessToken: () => _accessToken,
  getRefreshToken: () => _refreshToken,
};

export const quizApi = {
  getToday: () => get('/quiz/today'),
  startSession: () => post('/quiz/session/start', {}),
  submitAnswer: (sessionId, questionId, selectedOption, timeTakenMs) =>
    post(`/quiz/session/${sessionId}/answer`, { question_id: questionId, selected_option: selectedOption, time_taken_ms: timeTakenMs }),
  completeSession: (sessionId, totalMs) =>
    post(`/quiz/session/${sessionId}/complete`, { total_time_taken_ms: totalMs }),
  getDailyLeaderboard: () => get('/quiz/leaderboard/daily'),
  getWeeklyLeaderboard: () => get('/quiz/leaderboard/weekly'),
  getHistory: () => get('/quiz/history'),
  getStreak: () => get('/quiz/streak'),
};

export const contentApi = {
  getHomeFeed: () => get('/home/feed'),
  getMovies: () => get('/movies/upcoming'),
  getMovie: (id) => get(`/movies/${id}`),
  setReminder: (movieId) => post(`/movies/${movieId}/reminder`, {}),
  getHeroes: () => get('/heroes'),
  getHero: (id) => get(`/heroes/${id}`),
  getShareCards: (params = {}) => {
    const q = new URLSearchParams(params).toString();
    return get(`/share-cards${q ? '?' + q : ''}`);
  },
  getShareCardDownload: (id) => get(`/share-cards/${id}/download`),
  logShare: (id) => post(`/share-cards/${id}/share`, {}),
};

export const fanArmyApi = {
  getArmies: () => get('/fan-armies'),
  getLeaderboard: () => get('/fan-armies/leaderboard'),
  joinArmy: (id) => post(`/fan-armies/${id}/join`, {}),
  getMyArmy: () => get('/fan-armies/my'),
  getActivePoll: () => get('/polls/active'),
  castVote: (pollId, optionId) => post(`/polls/${pollId}/vote`, { option_id: optionId }),
};

export const coinsApi = {
  getBalance: () => get('/coins/balance'),
  getHistory: () => get('/coins/history'),
  getStore: () => get('/coins/store'),
  redeem: (itemId) => post('/coins/redeem', { item_id: itemId }),
};
