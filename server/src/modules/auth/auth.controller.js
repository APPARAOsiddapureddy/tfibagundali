const service = require('./auth.service');

async function sendOtpHandler(req, res, next) {
  try {
    const data = await service.sendOtp(req.body.phone);
    res.json({ success: true, data });
  } catch (e) { next(e); }
}

async function verifyOtpHandler(req, res, next) {
  try {
    const data = await service.verifyOtp(req.body.phone, req.body.code);
    res.json({ success: true, data });
  } catch (e) { next(e); }
}

async function getMeHandler(req, res, next) {
  try {
    const data = await service.getMe(req.user.id);
    res.json({ success: true, data });
  } catch (e) { next(e); }
}

async function updateMeHandler(req, res, next) {
  try {
    const data = await service.updateMe(req.user.id, req.body);
    res.json({ success: true, data });
  } catch (e) { next(e); }
}

module.exports = { sendOtpHandler, verifyOtpHandler, getMeHandler, updateMeHandler };
