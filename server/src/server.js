const app = require('./app');
const env = require('./config/env');

app.listen(env.PORT, () => {
  console.log(`🎬 TFI Bagundali API running on http://localhost:${env.PORT}`);
});
