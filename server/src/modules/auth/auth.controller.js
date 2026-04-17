const service = require('./auth.service');
const { respond } = require('../../utils/pagination');
const { z } = require('zod');

const sendOtpSchema = z.object({ body: z.object({ phone: z.string().regex(/^\+91[6-9]\d{9}$/, 'Invalid Indian phone number') }) });
const verifyOtpSchema = z.object({ body: z.object({ phone: z.string(), code: z.string().length(6), device_id: z.string().optional() }) });
const refreshSchema = z.object({ body: z.object({ refresh_token: z.string() }) });
const logoutSchema = z.object({ body: z.object({ refresh_token: z.string() }) });

async function sendOtp(req, res, next) {
  try {
    const { phone } = req.body;
    const result = await service.sendOtp(phone);
    respond(res, result);
  } catch (err) { next(err); }
}

async function verifyOtp(req, res, next) {
  try {
    const { phone, code, device_id } = req.body;
    const result = await service.verifyOtp(phone, code, device_id);
    respond(res, result);
  } catch (err) { next(err); }
}

async function refreshToken(req, res, next) {
  try {
    const { refresh_token } = req.body;
    const result = await service.refreshTokens(refresh_token);
    respond(res, result);
  } catch (err) { next(err); }
}

async function logout(req, res, next) {
  try {
    const { refresh_token } = req.body;
    await service.logout(refresh_token);
    respond(res, { message: 'Logged out successfully' });
  } catch (err) { next(err); }
}

async function getMe(req, res, next) {
  try {
    const user = await service.getMe(req.user.id);
    respond(res, user);
  } catch (err) { next(err); }
}

async function updateMe(req, res, next) {
  try {
    const user = await service.updateMe(req.user.id, req.body);
    respond(res, user);
  } catch (err) { next(err); }
}

module.exports = { sendOtp, verifyOtp, refreshToken, logout, getMe, updateMe };
module.exports.schemas = { sendOtpSchema, verifyOtpSchema, refreshSchema, logoutSchema };
