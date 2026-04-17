const crypto = require('crypto');
const env = require('../config/env');

function generateOtp() {
  // 6-digit numeric OTP
  return String(Math.floor(100000 + Math.random() * 900000));
}

function hashOtp(otp) {
  return crypto.createHash('sha256').update(otp).digest('hex');
}

function hashToken(token) {
  return crypto.createHash('sha256').update(token).digest('hex');
}

async function sendOtpSms(phone, otp) {
  // In dev, bypass actual SMS
  if (env.NODE_ENV === 'development' || env.OTP_BYPASS_CODE) {
    console.log(`📱 [DEV] OTP for ${phone}: ${otp}`);
    return true;
  }

  // MSG91 integration
  const url = `https://api.msg91.com/api/v5/otp?authkey=${env.MSG91_AUTH_KEY}&template_id=your_template_id`;
  const body = { mobile: phone.replace('+', ''), otp };

  const response = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });

  return response.ok;
}

module.exports = { generateOtp, hashOtp, hashToken, sendOtpSms };
