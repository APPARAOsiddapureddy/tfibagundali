import { useState } from 'react';
import { useApp } from '../context/AppContext';
import { authApi } from '../services/api';

export default function AuthScreen() {
  const { login, setScreen } = useApp();
  const [step, setStep] = useState('phone'); // 'phone' | 'otp'
  const [phone, setPhone] = useState('');
  const [code, setCode] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  async function handleSendOtp() {
    if (!phone.match(/^\+91[6-9]\d{9}$/)) {
      setError('Valid Indian number required (e.g. +919876543210)');
      return;
    }
    setError('');
    setLoading(true);
    try {
      await authApi.sendOtp(phone);
      setStep('otp');
    } catch (err) {
      setError(err.message || 'Failed to send OTP');
    } finally {
      setLoading(false);
    }
  }

  async function handleVerifyOtp() {
    if (code.length !== 6) { setError('Enter 6-digit OTP'); return; }
    setError('');
    setLoading(true);
    try {
      const data = await login(phone, code);
      setScreen(data.user.is_new_user ? 'onboard' : 'home');
    } catch (err) {
      setError(err.message || 'Invalid OTP');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="auth-screen">
      <div style={{ flex: 1 }} />
      <div className="auth-logo">TFI<br/>BAGUNDALI</div>
      <div className="auth-sub">తెలుగు సినిమా కోసమే పుట్టిన App</div>
      <div style={{ flex: 1 }} />

      {step === 'phone' ? (
        <>
          <div className="auth-input-wrap">
            <div className="auth-label">Mobile Number</div>
            <input
              className="auth-input"
              type="tel"
              placeholder="+91 98765 43210"
              value={phone}
              onChange={e => setPhone(e.target.value)}
              onKeyDown={e => e.key === 'Enter' && handleSendOtp()}
            />
          </div>
          {error && <div style={{ color: 'var(--red)', fontSize: 12, textAlign: 'center' }}>{error}</div>}
          <button className="auth-btn" onClick={handleSendOtp} disabled={loading}>
            {loading ? 'Sending...' : 'OTP Send Cheyyi →'}
          </button>
          <div className="auth-hint">Dev mode: enter any +91 number, use OTP 123456</div>
        </>
      ) : (
        <>
          <div className="auth-input-wrap">
            <div className="auth-label">OTP — {phone}</div>
            <input
              className="auth-input"
              type="number"
              placeholder="6-digit OTP"
              value={code}
              onChange={e => setCode(e.target.value.slice(0, 6))}
              onKeyDown={e => e.key === 'Enter' && handleVerifyOtp()}
              autoFocus
            />
          </div>
          {error && <div style={{ color: 'var(--red)', fontSize: 12, textAlign: 'center' }}>{error}</div>}
          <button className="auth-btn" onClick={handleVerifyOtp} disabled={loading}>
            {loading ? 'Verifying...' : 'Verify & Enter →'}
          </button>
          <div className="auth-hint" style={{ cursor: 'pointer', color: 'var(--muted2)' }} onClick={() => { setStep('phone'); setCode(''); setError(''); }}>
            ← Change number
          </div>
        </>
      )}

      <div style={{ flex: 2 }} />
    </div>
  );
}
