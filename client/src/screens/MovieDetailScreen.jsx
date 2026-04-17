import { useState } from 'react';
import { useApp } from '../context/AppContext';
import BottomNav from '../components/BottomNav';

const CAST = [
  { name: 'Allu Arjun', role: 'Hero', icon: '🔥' },
  { name: 'Rashmika', role: 'Heroine', icon: '💃' },
  { name: 'Sukumar', role: 'Director', icon: '🎬' },
  { name: 'Fahadh F.', role: 'Villain', icon: '😈' },
  { name: 'DSP', role: 'Music', icon: '🎵' },
];

export default function MovieDetailScreen({ onQuiz }) {
  const { setScreen } = useApp();
  const [activeTab, setActiveTab] = useState('about');

  return (
    <>
      <div style={{ height: '100%', overflowY: 'auto', paddingBottom: 72 }}>
        {/* Hero banner */}
        <div style={{ height: 190, position: 'relative', overflow: 'hidden', background: 'linear-gradient(160deg, #130a0a, #0a130a)', display: 'flex', alignItems: 'flex-end', padding: 16 }}>
          <div style={{ position: 'absolute', fontSize: 120, opacity: 0.08, top: -10, right: -10, pointerEvents: 'none' }}>🔥</div>

          <div style={{ position: 'absolute', top: 12, left: 12, background: 'rgba(0,0,0,0.5)', border: '1px solid var(--border2)', borderRadius: 10, padding: '5px 10px', fontSize: 11, color: 'var(--text)', cursor: 'pointer' }}
            onClick={() => setScreen('home')}>
            ← Back
          </div>

          <div style={{ position: 'relative' }}>
            <div style={{ fontSize: 9, color: 'var(--red)', fontWeight: 700, letterSpacing: 2, textTransform: 'uppercase', marginBottom: 4 }}>UPCOMING RELEASE</div>
            <div style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 36, color: 'var(--text)', lineHeight: 1, letterSpacing: 1 }}>PUSHPA 3</div>
            <div style={{ fontSize: 12, color: 'var(--muted2)', marginTop: 4 }}>Allu Arjun • Sukumar • Releasing Aug 15, 2025</div>
          </div>
        </div>

        {/* Countdown + reminder */}
        <div style={{ padding: '12px 14px', display: 'flex', alignItems: 'center', gap: 10, borderBottom: '1px solid var(--border)', background: 'rgba(230,57,70,0.04)' }}>
          <div style={{ flex: 1, display: 'flex', gap: 6 }}>
            {[['18', 'DAYS'], ['04', 'HRS'], ['22', 'MIN']].map(([n, l]) => (
              <div key={l} style={{ background: 'rgba(230,57,70,0.15)', border: '1px solid rgba(230,57,70,0.2)', borderRadius: 8, padding: '4px 8px', textAlign: 'center', minWidth: 36 }}>
                <div style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 20, color: 'var(--red)', lineHeight: 1 }}>{n}</div>
                <div style={{ fontSize: 7, color: 'var(--muted)', letterSpacing: 1, textTransform: 'uppercase' }}>{l}</div>
              </div>
            ))}
          </div>
          <button style={{ background: 'var(--red)', border: 'none', borderRadius: 10, padding: '8px 14px', color: '#fff', fontFamily: "'Bebas Neue',sans-serif", fontSize: 14, cursor: 'pointer', letterSpacing: 0.5 }}>
            🔔 Set Reminder
          </button>
        </div>

        {/* Tabs */}
        <div style={{ padding: '12px 14px 0' }}>
          <div style={{ display: 'flex', gap: 5, marginBottom: 14 }}>
            {['about', 'gallery', 'fan talk'].map(t => (
              <div
                key={t}
                onClick={() => setActiveTab(t)}
                style={{ flex: 1, padding: 9, textAlign: 'center', borderRadius: 12, background: activeTab === t ? 'var(--red)' : 'var(--bg3)', border: `1px solid ${activeTab === t ? 'var(--red)' : 'var(--border)'}`, fontSize: 11, color: activeTab === t ? '#fff' : 'var(--muted2)', cursor: 'pointer', fontWeight: 600, transition: 'all 0.2s', textTransform: 'capitalize' }}
              >
                {t}
              </div>
            ))}
          </div>

          {activeTab === 'about' && (
            <>
              <p style={{ fontSize: 13, color: 'var(--muted2)', lineHeight: 1.6, marginBottom: 14 }}>
                Pushpa Raj continues his fiery journey in the high-stakes world of red sandalwood smuggling. This time, the conflict escalates as new rivals and old enemies converge in a battle of loyalty, power, and identity. Stylized action, mass dialogues, and DSP's blockbuster music.
              </p>
              <div style={{ fontSize: 12, color: 'var(--text)', fontWeight: 700, marginBottom: 10 }}>Cast & Crew</div>
              <div style={{ display: 'flex', gap: 10, overflowX: 'auto', marginBottom: 14 }}>
                {CAST.map(c => (
                  <div key={c.name} style={{ textAlign: 'center', flexShrink: 0 }}>
                    <div style={{ width: 48, height: 48, borderRadius: '50%', background: 'var(--bg4)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 22, margin: '0 auto 5px', border: '2px solid var(--border)' }}>{c.icon}</div>
                    <div style={{ fontSize: 9, color: 'var(--muted2)', fontWeight: 600, textAlign: 'center', maxWidth: 56 }}>{c.name}</div>
                    <div style={{ fontSize: 8, color: 'var(--muted)', textAlign: 'center' }}>{c.role}</div>
                  </div>
                ))}
              </div>
              <button onClick={() => setScreen('sharezone')} style={{ background: 'var(--red)', border: 'none', borderRadius: 16, padding: 15, color: '#fff', fontFamily: "'Bebas Neue',sans-serif", fontSize: 20, letterSpacing: 1, cursor: 'pointer', width: '100%', boxShadow: '0 8px 24px rgba(230,57,70,0.25)' }}>
                📲 Share This Movie
              </button>
            </>
          )}

          {activeTab === 'gallery' && (
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2,1fr)', gap: 8 }}>
              {['🔥', '💥', '🎬', '🌟', '⚡', '🎵'].map((icon, i) => (
                <div key={i} style={{ background: 'var(--bg4)', borderRadius: 12, height: 100, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 36, border: '1px solid var(--border)' }}>{icon}</div>
              ))}
            </div>
          )}

          {activeTab === 'fan talk' && (
            <div>
              <div style={{ fontSize: 13, color: 'var(--text)', fontWeight: 700, marginBottom: 12 }}>Pushpa 3 expectations?</div>
              {[
                { icon: '🔥', label: 'Mass Blockbuster!', pct: 68 },
                { icon: '👍', label: 'Good Movie', pct: 22 },
                { icon: '😐', label: 'Average', pct: 10 },
              ].map(opt => (
                <div key={opt.label} style={{ marginBottom: 10, cursor: 'pointer' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 4 }}>
                    <span style={{ fontSize: 13, color: 'var(--text)', fontWeight: 600 }}>{opt.icon} {opt.label}</span>
                    <span style={{ fontSize: 12, color: 'var(--muted2)' }}>{opt.pct}%</span>
                  </div>
                  <div style={{ height: 6, background: 'var(--border)', borderRadius: 3, overflow: 'hidden' }}>
                    <div style={{ height: 6, borderRadius: 3, background: 'var(--red)', width: `${opt.pct}%` }} />
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      <BottomNav active="home" onQuiz={onQuiz} />
    </>
  );
}
