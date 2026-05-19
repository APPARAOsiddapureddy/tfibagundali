/** Normalize Indian mobile numbers to +91XXXXXXXXXX */

function normalizePhone(input) {
  if (!input || typeof input !== 'string') return null;
  const digits = input.replace(/\D/g, '');
  const local = digits.length >= 10 ? digits.slice(-10) : digits;
  if (local.length !== 10) return null;
  return `+91${local}`;
}

module.exports = { normalizePhone };
