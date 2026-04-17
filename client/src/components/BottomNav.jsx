import { useApp } from '../context/AppContext';

const NAV_ITEMS = [
  { id: 'home', icon: '🏠', label: 'Home' },
  { id: 'quiz', icon: '🎯', label: 'Quiz' },
  { id: 'sharezone', icon: '📲', label: 'Share' },
  { id: 'fanarmy', icon: '⚔️', label: 'Fan Army' },
  { id: 'profile', icon: '👤', label: 'Profile' },
];

export default function BottomNav({ active, onQuiz }) {
  const { setScreen } = useApp();

  return (
    <div className="bottom-nav">
      {NAV_ITEMS.map(n => (
        <div
          key={n.id}
          className={`bnav ${active === n.id ? 'active' : ''}`}
          onClick={() => n.id === 'quiz' ? onQuiz?.() : setScreen(n.id)}
        >
          <div className="bnav-icon">{n.icon}</div>
          <div className="bnav-label">{n.label}</div>
          {active === n.id && <div className="bnav-pip" />}
        </div>
      ))}
    </div>
  );
}
