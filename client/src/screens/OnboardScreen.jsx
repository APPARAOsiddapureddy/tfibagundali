import { useApp } from '../context/AppContext';

const HEROES = [
  { id: 'pawan', icon: '🦁', name: 'Pawan Kalyan', army: 'Power Army' },
  { id: 'mahesh', icon: '👑', name: 'Mahesh Babu', army: 'Mahesh Army' },
  { id: 'allu', icon: '🔥', name: 'Allu Arjun', army: 'Bunny Army' },
  { id: 'charan', icon: '⚡', name: 'Ram Charan', army: 'Charan Army' },
  { id: 'ntr', icon: '🌊', name: 'Jr. NTR', army: 'Young Tiger' },
  { id: 'prabhas', icon: '🐯', name: 'Prabhas', army: 'Rebel Army' },
  { id: 'balayya', icon: '🦅', name: 'Balakrishna', army: 'Nandamuri' },
  { id: 'chiranjeevi', icon: '🌟', name: 'Chiranjeevi', army: 'Mega Army' },
];

export default function OnboardScreen() {
  const { selectedHero, setSelectedHero, setScreen } = useApp();

  return (
    <div className="scrollable">
      <div style={{ padding: '16px 20px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div style={{ display: 'flex', gap: 6 }}>
          {[1, 0, 0].map((active, i) => (
            <div key={i} style={{ height: 3, borderRadius: 2, background: i === 0 ? 'var(--red)' : 'var(--border2)', width: i === 0 ? 24 : 8, transition: 'all 0.3s' }} />
          ))}
        </div>
        <div style={{ fontSize: 12, color: 'var(--muted2)', cursor: 'pointer' }} onClick={() => setScreen('home')}>Skip →</div>
      </div>

      <div style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 32, color: 'var(--text)', padding: '8px 20px 4px', lineHeight: 1 }}>
        Nee Favourite<br/>Hero Evaru?
      </div>
      <div style={{ fontFamily: "'Noto Sans Telugu',sans-serif", fontSize: 12, color: 'var(--muted2)', padding: '0 20px 16px' }}>
        నీ hero select చెయ్యి — మీ army లో join అవుతావు!
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4,1fr)', gap: 8, padding: '0 14px' }}>
        {HEROES.map(h => (
          <div
            key={h.id}
            onClick={() => setSelectedHero(h.id)}
            style={{
              background: selectedHero === h.id ? 'var(--red-dim)' : 'var(--bg3)',
              borderRadius: 14,
              border: `1.5px solid ${selectedHero === h.id ? 'var(--red)' : 'transparent'}`,
              padding: '10px 6px',
              textAlign: 'center',
              cursor: 'pointer',
              transition: 'all 0.2s',
            }}
          >
            <span style={{ fontSize: 26, display: 'block', marginBottom: 5 }}>{h.icon}</span>
            <div style={{ fontSize: 9, color: 'var(--text)', fontWeight: 700, lineHeight: 1.2 }}>{h.name}</div>
            <div style={{ fontSize: 8, color: selectedHero === h.id ? 'var(--red)' : 'var(--muted)', marginTop: 2 }}>{h.army}</div>
          </div>
        ))}
      </div>

      <button
        onClick={() => setScreen('home')}
        style={{
          margin: '16px 14px 0', background: 'var(--red)', color: '#fff', border: 'none',
          borderRadius: 16, padding: 16, width: 'calc(100% - 28px)',
          fontFamily: "'Bebas Neue',sans-serif", fontSize: 22, letterSpacing: 1,
          cursor: 'pointer', boxShadow: '0 8px 24px rgba(230,57,70,0.3)',
        }}
      >
        Next — Region Select →
      </button>
    </div>
  );
}
