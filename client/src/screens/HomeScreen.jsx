import { useState, useEffect } from 'react';
import { useApp } from '../context/AppContext';
import { contentApi } from '../services/api';
import BottomNav from '../components/BottomNav';

const FALLBACK_MOVIES = [
  { id: '1', title: 'Pushpa 3', icon: '🔥', date: 'Aug 15, 2025', genre: 'Mass Action' },
  { id: '2', title: 'Devara 2', icon: '🌊', date: 'May 3, 2025', genre: 'Mass' },
  { id: '3', title: 'HHVM', icon: '🦁', date: 'Jul 4, 2025', genre: 'Period Action' },
  { id: '4', title: 'Game Changer 2', icon: '⚡', date: 'Jun 18, 2025', genre: 'Action' },
];

const FALLBACK_STATUS = [
  { icon: '🦁', lbl: 'Power Star' }, { icon: '💬', lbl: 'Dialogue' },
  { icon: '⚡', lbl: 'Charan FC' }, { icon: '🏆', lbl: 'FDFS Hype' }, { icon: '🌊', lbl: 'NTR Army' },
];

export default function HomeScreen({ onQuiz }) {
  const { setScreen, coinBalance, isLoggedIn } = useApp();
  const [feed, setFeed] = useState(null);

  useEffect(() => {
    if (isLoggedIn) {
      contentApi.getHomeFeed().then(setFeed).catch(() => {});
    }
  }, [isLoggedIn]);

  const movies = feed?.upcoming_movies?.length ? feed.upcoming_movies : FALLBACK_MOVIES;
  const quizDone = feed?.quiz?.completed_today;

  return (
    <>
      <div className="topbar">
        <div className="app-logo">TFI BAGUNDALI</div>
        <div className="topbar-right">
          <div className="coin-chip">
            <span>🪙</span>
            <span>{(feed?.coin_balance ?? coinBalance) || 0}</span>
          </div>
          <div style={{ fontSize: 20, cursor: 'pointer' }}>🔔</div>
        </div>
      </div>

      <div className="scrollable">
        {/* Release Countdown Card */}
        <div
          style={{
            margin: 12, borderRadius: 20, overflow: 'hidden',
            background: 'linear-gradient(135deg, #130608 0%, #1a0a0a 50%, #0d1a0d 100%)',
            border: '1px solid rgba(230,57,70,0.2)',
            boxShadow: '0 4px 24px rgba(230,57,70,0.1)',
            cursor: 'pointer',
          }}
          onClick={() => setScreen('moviedetail')}
        >
          <div style={{ padding: 16, display: 'flex', alignItems: 'center', gap: 14, position: 'relative' }}>
            <div style={{ position: 'absolute', top: -20, right: -20, width: 120, height: 120, background: 'radial-gradient(circle, rgba(230,57,70,0.12) 0%, transparent 70%)', pointerEvents: 'none' }} />
            <div style={{ width: 64, height: 80, borderRadius: 10, background: 'var(--bg4)', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', fontSize: 32, flexShrink: 0, border: '1px solid var(--border2)' }}>🔥</div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 9, color: 'var(--red)', fontWeight: 700, letterSpacing: 2, textTransform: 'uppercase', marginBottom: 3 }}>Next Big Release</div>
              <div style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 28, color: 'var(--text)', lineHeight: 0.95, letterSpacing: 1 }}>PUSHPA 3</div>
              <div style={{ fontSize: 11, color: 'var(--muted2)', margin: '4px 0 8px' }}>Allu Arjun • Sukumar</div>
              <div style={{ display: 'flex', gap: 6 }}>
                {[['18', 'DAYS'], ['04', 'HRS'], ['22', 'MIN']].map(([n, l]) => (
                  <div key={l} style={{ background: 'rgba(230,57,70,0.15)', border: '1px solid rgba(230,57,70,0.2)', borderRadius: 8, padding: '4px 8px', textAlign: 'center', minWidth: 36 }}>
                    <div style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 20, color: 'var(--red)', lineHeight: 1 }}>{n}</div>
                    <div style={{ fontSize: 7, color: 'var(--muted)', letterSpacing: 1, textTransform: 'uppercase' }}>{l}</div>
                  </div>
                ))}
              </div>
            </div>
            <button
              style={{ background: 'var(--red)', border: 'none', borderRadius: 10, padding: '8px 10px', color: '#fff', fontSize: 10, fontWeight: 700, cursor: 'pointer', flexShrink: 0, lineHeight: 1.3, textAlign: 'center' }}
              onClick={e => { e.stopPropagation(); }}
            >Set<br/>Alert 🔔</button>
          </div>
        </div>

        {/* Daily Quiz Card */}
        <div
          style={{
            margin: '0 12px 12px', borderRadius: 18, padding: '14px 16px',
            background: quizDone ? 'linear-gradient(135deg, #050f08, #0a180d)' : 'linear-gradient(135deg, #050f0a 0%, #0a1f10 100%)',
            border: `1px solid ${quizDone ? 'rgba(46,204,113,0.3)' : 'rgba(46,204,113,0.2)'}`,
            display: 'flex', alignItems: 'center', gap: 12, cursor: 'pointer',
          }}
          onClick={onQuiz}
        >
          <div style={{ fontSize: 36, flexShrink: 0 }}>🎯</div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 14, color: 'var(--text)', fontWeight: 700 }}>
              {quizDone ? 'Today\'s Quiz Complete! 🏆' : 'Daily Cinema Challenge Ready!'}
            </div>
            <div style={{ fontSize: 11, color: 'var(--muted2)', marginTop: 2 }}>
              {quizDone ? `Score: ${feed?.quiz?.score}/5 • Come back tomorrow` : '5 questions • Neevu gelusthava? 🏆'}
            </div>
          </div>
          <div style={{ background: quizDone ? 'var(--green-dim)' : 'var(--green-dim)', border: `1px solid ${quizDone ? 'rgba(46,204,113,0.3)' : 'rgba(46,204,113,0.25)'}`, borderRadius: 10, padding: '6px 10px', textAlign: 'center' }}>
            <div style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 22, color: 'var(--green)', lineHeight: 1 }}>{quizDone ? '✓' : '25'}</div>
            <div style={{ fontSize: 8, color: 'var(--muted)' }}>{quizDone ? 'DONE' : '🪙 MAX'}</div>
          </div>
        </div>

        {/* Upcoming Releases */}
        <div className="section-row">
          <div className="section-title">Upcoming Releases</div>
          <div className="see-all">See All →</div>
        </div>
        <div className="hscroll" style={{ paddingBottom: 12 }}>
          {movies.map(m => (
            <div
              key={m.id || m.title}
              onClick={() => setScreen('moviedetail')}
              style={{ background: 'var(--bg3)', borderRadius: 14, width: 96, flexShrink: 0, border: '1px solid var(--border)', overflow: 'hidden', cursor: 'pointer', transition: 'all 0.2s' }}
            >
              <div style={{ width: 96, height: 118, background: 'var(--bg4)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 40 }}>
                {m.poster_url ? <img src={m.poster_url} style={{ width: '100%', height: '100%', objectFit: 'cover' }} alt={m.title} /> : (m.icon || '🎬')}
              </div>
              <div style={{ padding: '7px 8px 9px' }}>
                <div style={{ fontSize: 11, color: 'var(--text)', fontWeight: 700, lineHeight: 1.2 }}>{m.title}</div>
                <div style={{ fontSize: 9, color: 'var(--red)', marginTop: 3, fontWeight: 600 }}>{m.date || m.release_date}</div>
                <div style={{ fontSize: 8, color: 'var(--muted)', marginTop: 1 }}>{m.genre}</div>
              </div>
            </div>
          ))}
        </div>

        {/* WhatsApp Status */}
        <div className="section-row">
          <div className="section-title">Today's WhatsApp Status 📲</div>
          <div className="see-all" onClick={() => setScreen('sharezone')}>More →</div>
        </div>
        <div className="hscroll" style={{ paddingBottom: 16 }}>
          {FALLBACK_STATUS.map(s => (
            <div
              key={s.lbl}
              onClick={() => setScreen('sharezone')}
              style={{ background: 'var(--bg3)', borderRadius: 14, width: 110, height: 90, flexShrink: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 5, border: '1px solid var(--border)', fontSize: 28, position: 'relative', overflow: 'hidden', cursor: 'pointer' }}
            >
              <span>{s.icon}</span>
              <span style={{ fontSize: 9, color: 'var(--muted2)', fontWeight: 600 }}>{s.lbl}</span>
              <div style={{ position: 'absolute', bottom: 6, right: 6, background: 'var(--wa)', borderRadius: 6, padding: '2px 6px', fontSize: 8, color: '#fff', fontWeight: 700 }}>WA</div>
            </div>
          ))}
        </div>
      </div>

      <BottomNav active="home" onQuiz={onQuiz} />
    </>
  );
}
