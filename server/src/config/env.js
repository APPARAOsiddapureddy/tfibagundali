require('dotenv').config();
const { z } = require('zod');

const schema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.coerce.number().default(3001),
  DATABASE_URL: z.string().min(1),
  REDIS_URL: z.string().optional(),
  JWT_SECRET: z.string().min(16),
  JWT_REFRESH_SECRET: z.string().min(16),
  JWT_EXPIRES_IN: z.string().default('15m'),
  JWT_REFRESH_EXPIRES_IN: z.string().default('30d'),
  OTP_BYPASS_CODE: z.string().optional(),
  ALLOWED_ORIGINS: z.string().default('http://localhost:5173'),
  ADMIN_API_KEY: z.string().optional(),
  PUBLIC_BASE_URL: z.string().default('http://localhost:3001'),
  UPLOAD_MAX_BYTES: z.coerce.number().default(5 * 1024 * 1024),
  UPLOAD_DIR: z.string().default('uploads'),
  REMOTE_IMAGE_TIMEOUT_MS: z.coerce.number().default(15000),
});

const parsed = schema.safeParse(process.env);
if (!parsed.success) {
  console.error('❌ Invalid environment variables:');
  console.error(parsed.error.flatten().fieldErrors);
  process.exit(1);
}

module.exports = parsed.data;
