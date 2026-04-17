import { useApp } from '../context/AppContext';
import BottomNav from '../components/BottomNav';

const BADGES = [
  { icon: '🔥', label: '7-Day Streak', earned: true },
  { icon: '🎯', label: 'Perfect Score', earned: true },
  { icon: '📲', label: 'First Share', earned: true },
  { icon: '🏆', label: 'Quiz Master', earned: false },
  { icon: '👑', label: 'Month Streak', earned: false },
  { icon: '💎', label: 'Premium Fan', earned: false },
];

const HERO_ICONS = { pawan: '🦁', mahesh: '👑', allu: '🔥', charan: '⚡', ntr: '🌊', prabhas: '🐯', balayya: '🦅', chiranjeevi: '🌟' };
const HERO_ARMIES = { pawan: 'Power Army', mahesh: 'Mahesh Army', allu: 'Bunny Army', charan: 'Charan Army', ntr: 'Young Tiger Army', prabhas: 'Rebel Army', balayya: 'Nandamuri Sena', chiranjeevi: 'Mega Army' };

export default function ProfileScreen({ onQuiz }) {
  const { user, selectedHero, coinBalance, setScreen, logout, isLoggedIn } = useApp();

  if (!isLoggedIn) {
    return (
      <>
        <div style={{ padding: 32, textAlign: 'center', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 16, height: '100%' }}>
          <div style={{ fontSize: 48 }}>👤</div>
          <div style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 24, color: 'var(--text)' }}>Login Avvandi</div>
          <div style={{ fontSize: 13, color: 'var(--muted2)', fontFamily: "'Noto Sans Telugu',sans-serif" }}>Login avvite coins, quiz history, badges anni save avutayi!</div>
          <button onClick={() => setScreen('auth')} style={{ background: 'var(--red)', border: 'none', borderRadius: 16, padding: '14px 32px', color: '#fff', fontFamily: "'Bebas Neue',sans-serif", fontSize: 20, cursor: 'pointer', boxShadow: '0 8px 24px rgba(230,57,70,0.3)' }}>
            Login / Register
          </button>
        </div>
        <BottomNav active="profile" onQuiz={onQuiz} />
      </>
    );
  }

  return (
    <>
      <div className="scrollable">
        {/* Profile header */}
        <div style={{ background: 'linear-gradient(180deg, rgba(230,57,70,0.08) 0%, transparent 100%)', padding: '20px 16px 14px', textAlign: 'center' }}>
          <div style={{ width: 76, height: 76, borderRadius: '50%', border: '3px solid var(--red)', background: 'var(--bg4)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 34, margin: '0 auto 10px', boxShadow: '0 0 20px rgba(230,57,70,0.2)' }}>
            {HERO_ICONS[selectedHero] || '🦁'}
          </div>
          <div style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 26, color: 'var(--text)' }}>
            {user?.display_name || user?.username || 'TFI Fan'}
          </div>
          <div style={{ fontSize: 12, color: 'var(--muted)', marginTop: 2 }}>
            @{user?.username || 'fan_' + (user?.id || '').slice(0, 8)}
          </div>
          <div style={{ display: 'inline-flex', alignItems: 'center', gap: 5, marginTop: 8, background: 'var(--red-dim)', border: '1px solid rgba(230,57,70,0.25)', borderRadius: 12, padding: '5px 12px', fontSize: 11, color: 'var(--red)', fontWeight: 700 }}>
            {HERO_ICONS[selectedHero]} {HERO_ARMIES[selectedHero] || 'Power Army'}
          </div>
        </div>

        {/* Stats grid */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2,1fr)', gap: 8, padding: '0 12px 12px' }}>
          {[
            { num: coinBalance, label: 'COINS', color: 'gold' },
            { num: '7', label: 'DAY STREAK', color: 'red' },
            { num: '24', label: 'QUIZZES', color: '' },
            { num: '82%', label: 'ACCURACY', color: '' },
          ].map(s => (
            <div key={s.label} style={{ background: 'var(--bg3)', borderRadius: 14, padding: 14, border: '1px solid var(--border)', textAlign: 'center' }}>
              <div style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 32, color: s.color === 'gold' ? 'var(--gold)' : s.color === 'red' ? 'var(--red)' : 'var(--text)', lineHeight: 1 }}>
                {s.num}
              </div>
              <div style={{ fontSize: 10, color: 'var(--muted)', marginTop: 4, fontWeight: 600, letterSpacing: 0.5 }}>{s.label}</div>
            </div>
          ))}
        </div>

        {/* Badges */}
        <div style={{ padding: '0 12px 12px' }}>
          <div style={{ fontSize: 12, color: 'var(--text)', fontWeight: 700, marginBottom: 8 }}>Badges</div>
          <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
            {BADGES.map(b => (
              <div key={b.label} style={{ background: b.earned ? 'var(--gold-dim)' : 'var(--bg3)', border: `1px solid ${b.earned ? 'rgba(244,166,26,0.3)' : 'var(--border)'}`, borderRadius: 20, padding: '5px 10px', display: 'flex', alignItems: 'center', gap: 5, fontSize: 10, color: b.earned ? 'var(--gold)' : 'var(--muted2)', fontWeight: 600, opacity: b.earned ? 1 : 0.5 }}>
                <span>{b.icon}</span>{b.label}
              </div>
            ))}
          </div>
        </div>

        {/* Premium upsell */}
        <div style={{ margin: '0 12px 12px', background: 'linear-gradient(135deg, #100810, #1f0f20)', border: '1px solid rgba(244,166,26,0.25)', borderRadius: 16, padding: 14, display: 'flex', alignItems: 'center', gap: 12 }}>
          <span style={{ fontSize: 30 }}>👑</span>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 14, color: 'var(--gold)', fontWeight: 700 }}>Upgrade to Premium</div>
            <div style={{ fontSize: 10, color: 'var(--muted2)', marginTop: 2 }}>Ad-free • HD downloads • Exclusive content</div>
          </div>
          <button onClick={() => setScreen('premium')} style={{ background: 'var(--gold)', border: 'none', borderRadius: 10, padding: '8px 14px', fontSize: 11, fontWeight: 700, color: '#0d0d0d', cursor: 'pointer', boxShadow: '0 4px 12px rgba(244,166,26,0.25)' }}>
            View Plans
          </button>
        </div>

        {/* Settings */}
        <div style={{ margin: '0 12px 12px' }}>
          {[
            { icon: '🔔', label: 'Notifications', action: () => {} },
            { icon: '🌐', label: 'Language — Telugu / English', action: () => {} },
            { icon: '👥', label: 'Invite Friends (+50 🪙)', action: () => {} },
            { icon: '🚪', label: 'Logout', action: logout, color: 'var(--red)' },
          ].map(item => (
            <div key={item.label} onClick={item.action} style={{ padding: '12px 0', display: 'flex', alignItems: 'center', gap: 12, borderBottom: '1px solid var(--border)', cursor: 'pointer' }}>
              <span style={{ fontSize: 18 }}>{item.icon}</span>
              <span style={{ fontSize: 13, color: item.color || 'var(--text)', flex: 1, fontWeight: 600 }}>{item.label}</span>
              <span style={{ color: 'var(--muted)' }}>›</span>
            </div>
          ))}
        </div>
      </div>

      <BottomNav active="profile" onQuiz={onQuiz} />
    </>
  );
}
