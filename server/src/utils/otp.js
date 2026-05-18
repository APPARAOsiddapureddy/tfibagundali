const crypto = require('crypto');
const env = require('../config/env');

function generateOtp() {
  return String(Math.floor(100000 + Math.random() * 900000));
}

function hashOtp(code) {
  return crypto.createHash('sha256').update(code).digest('hex');
}

function hashToken(token) {
  return crypto.createHash('sha256').update(token).digest('hex');
}

async function sendOtpSms(phone, code) {
  if (env.NODE_ENV === 'development') {
    console.log(`📱 OTP for ${phone}: ${code}`);
    return;
  }
  // MSG91 integration placeholder
}

module.exports = { generateOtp, hashOtp, hashToken, sendOtpSms };
