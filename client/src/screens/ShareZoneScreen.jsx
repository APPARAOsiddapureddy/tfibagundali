import { useState, useEffect } from 'react';
import { useApp } from '../context/AppContext';
import { contentApi } from '../services/api';
import BottomNav from '../components/BottomNav';

const FILTERS = ['All', 'Hero Status', 'Dialogues', 'Countdown', 'Fan Army', 'Birthdays'];

const FILTER_MAP = {
  'All': 'All',
  'Hero Status': 'hero_status',
  'Dialogues': 'dialogue',
  'Countdown': 'countdown',
  'Fan Army': 'fan_army',
  'Birthdays': 'birthday',
};

const FALLBACK_CARDS = [
  { id: '1', title: 'Power Star Morning Status', category: 'hero_status', icon: '🦁', share_count: 4200, is_premium: false },
  { id: '2', title: 'Pushpa 3 Countdown Card', category: 'countdown', icon: '🔥', share_count: 8700, is_premium: false },
  { id: '3', title: 'Iconic Dialogue Card', category: 'dialogue', icon: '💬', share_count: 2100, is_premium: false },
  { id: '4', title: 'Mahesh B-Day Special', category: 'birthday', icon: '🎂', share_count: 6300, is_premium: true },
  { id: '5', title: 'Bunny Army Flag 2025', category: 'fan_army', icon: '🔥', share_count: 3900, is_premium: false },
  { id: '6', title: 'NTR Tiger Status Pack', category: 'hero_status', icon: '🌊', share_count: 5100, is_premium: true },
  { id: '7', title: 'Baahubali Anniversary', category: 'anniversary', icon: '⚔️', share_count: 9200, is_premium: false },
  { id: '8', title: 'RRR Dialogue Telugu', category: 'dialogue', icon: '💥', share_count: 7400, is_premium: false },
];

export default function ShareZoneScreen({ onQuiz }) {
  const { setScreen, isLoggedIn } = useApp();
  const [filter, setFilter] = useState('All');
  const [cards, setCards] = useState(FALLBACK_CARDS);

  useEffect(() => {
    if (isLoggedIn) {
      const cat = FILTER_MAP[filter] || 'All';
      contentApi.getShareCards({ category: cat })
        .then(data => { if (data?.items?.length) setCards(data.items); })
        .catch(() => {});
    }
  }, [filter, isLoggedIn]);

  function shareCard(card) {
    const text = `🎬 ${card.title}\n\nTFI Bagundali App lo inka chala content undi! 📲`;
    if (navigator.share) {
      navigator.share({ title: card.title, text }).catch(() => {});
    } else {
      navigator.clipboard?.writeText(text);
    }
    if (isLoggedIn) contentApi.logShare(card.id).catch(() => {});
  }

  return (
    <>
      <div className="topbar">
        <div className="app-logo">SHARE ZONE</div>
        <div style={{ fontSize: 11, color: 'var(--muted2)' }}>📲 WhatsApp Ready</div>
      </div>

      <div className="scrollable">
        {/* Filter chips */}
        <div style={{ display: 'flex', gap: 7, padding: '10px 12px', overflowX: 'auto' }}>
          {FILTERS.map(f => (
            <div
              key={f}
              onClick={() => setFilter(f)}
              style={{
                padding: '6px 14px', borderRadius: 20,
                border: `1px solid ${filter === f ? 'var(--red)' : 'var(--border)'}`,
                background: filter === f ? 'var(--red)' : 'var(--bg3)',
                color: filter === f ? '#fff' : 'var(--muted2)',
                fontSize: 11, fontWeight: 600, whiteSpace: 'nowrap', cursor: 'pointer',
                flexShrink: 0, transition: 'all 0.2s',
              }}
            >
              {f}
            </div>
          ))}
        </div>

        {/* Content grid */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2,1fr)', gap: 10, padding: '0 12px 12px' }}>
          {cards.map(card => (
            <div
              key={card.id}
              style={{ background: 'var(--bg3)', borderRadius: 16, overflow: 'hidden', border: '1px solid var(--border)', cursor: 'pointer', transition: 'all 0.2s' }}
            >
              <div style={{ height: 110, background: 'var(--bg4)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 42, position: 'relative' }}>
                {card.thumbnail_url
                  ? <img src={card.thumbnail_url} style={{ width: '100%', height: '100%', objectFit: 'cover' }} alt={card.title} />
                  : (card.icon || '📲')
                }
                <div style={{ position: 'absolute', top: 7, left: 7, background: 'rgba(0,0,0,0.75)', borderRadius: 6, padding: '2px 7px', fontSize: 8, color: 'var(--text)', fontWeight: 700, letterSpacing: 0.5 }}>
                  {card.category?.replace(/_/g, ' ').toUpperCase()}
                </div>
                {card.is_premium && (
                  <div style={{ position: 'absolute', top: 7, right: 7, background: 'var(--gold-dim)', border: '1px solid rgba(244,166,26,0.3)', borderRadius: 6, padding: '2px 6px', fontSize: 9 }}>⭐</div>
                )}
                <div
                  style={{ position: 'absolute', bottom: 7, right: 7, background: 'var(--wa)', borderRadius: 6, padding: '3px 7px', fontSize: 9, color: '#fff', fontWeight: 700, cursor: 'pointer' }}
                  onClick={(e) => { e.stopPropagation(); shareCard(card); }}
                >
                  WA
                </div>
              </div>
              <div style={{ padding: '9px 10px 10px' }}>
                <div style={{ fontSize: 12, color: 'var(--text)', fontWeight: 700, lineHeight: 1.2 }}>{card.title}</div>
                <div style={{ fontSize: 10, color: 'var(--muted2)', marginTop: 3 }}>Shared {(card.share_count || 0).toLocaleString()} times</div>
              </div>
            </div>
          ))}
        </div>
      </div>

      <BottomNav active="sharezone" onQuiz={onQuiz} />
    </>
  );
}
