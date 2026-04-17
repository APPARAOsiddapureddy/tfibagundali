import { useApp } from '../context/AppContext';
import BottomNav from '../components/BottomNav';

const RESULT_CONFIG = {
  5: { emoji: '🏆', headline: 'PAKKAA FAN!', sub: 'Nuvvu legend ra!', stars: '⭐⭐⭐⭐⭐' },
  4: { emoji: '🔥', headline: 'DHAMAKA!', sub: 'Almost perfect!', stars: '⭐⭐⭐⭐' },
  3: { emoji: '💪', headline: '괜찮AE!', sub: 'Practice cheyyi!', stars: '⭐⭐⭐' },
  2: { emoji: '😄', headline: 'POYI MOVIES CHOODU!', sub: 'Reppati ki improve avutundi', stars: '⭐⭐' },
  1: { emoji: '😅', headline: 'EKA QUESTION?!', sub: 'Reppati munch prathipala choodaali!', stars: '⭐' },
  0: { emoji: '😂', headline: 'BABU...', sub: 'Reppati ki definitely improve avutundi!', stars: '' },
};

export default function ResultsScreen({ results, onPlayAgain, onQuiz }) {
  const { setScreen } = useApp();
  const score = results?.score ?? 0;
  const total = results?.total ?? 5;
  const coinsEarned = results?.coins_earned ?? 0;
  const streak = results?.streak ?? 0;
  const config = RESULT_CONFIG[score] || RESULT_CONFIG[0];

  function shareScore() {
    const text = `🎯 TFI Bagundali Daily Quiz\n${score}/${total} correct! ${config.stars}\n${coinsEarned > 0 ? `Earned ${coinsEarned} 🪙 coins!` : ''}\n\nNeevu kuda aaduta — Download TFI Bagundali! 🎬`;
    if (navigator.share) {
      navigator.share({ title: 'TFI Bagundali Quiz', text }).catch(() => {});
    } else {
      navigator.clipboard?.writeText(text);
      alert('Score copied to clipboard!');
    }
  }

  return (
    <>
      <div className="scrollable">
        <div style={{ padding: '20px 16px', display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
          <div style={{ fontSize: 64, marginBottom: 4, filter: 'drop-shadow(0 0 20px rgba(244,166,26,0.3))' }}>{config.emoji}</div>
          <div style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 32, color: 'var(--red)', textAlign: 'center', lineHeight: 1, marginBottom: 4, letterSpacing: 1 }}>
            {config.headline}
          </div>
          <div style={{ fontSize: 13, color: 'var(--muted2)', textAlign: 'center', marginBottom: 16, fontFamily: "'Noto Sans Telugu',sans-serif" }}>{config.sub}</div>

          {/* Score display */}
          <div style={{ display: 'flex', alignItems: 'baseline', gap: 4, marginBottom: 8 }}>
            <span style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 80, color: 'var(--text)', lineHeight: 1 }}>{score}</span>
            <span style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 28, color: 'var(--muted)' }}>/{total}</span>
          </div>
          <div style={{ fontSize: 22, letterSpacing: 2, marginBottom: 16 }}>{config.stars}</div>

          {/* Coins earned */}
          {coinsEarned > 0 && (
            <div style={{ background: 'var(--gold-dim)', border: '1px solid rgba(244,166,26,0.25)', borderRadius: 18, padding: '14px 24px', textAlign: 'center', width: '100%', marginBottom: 12 }}>
              <div style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 42, color: 'var(--gold)', lineHeight: 1 }}>+{coinsEarned} 🪙</div>
              <div style={{ fontSize: 11, color: 'var(--muted2)', marginTop: 2 }}>COINS EARNED TODAY</div>
            </div>
          )}

          {/* Streak */}
          {streak > 0 && (
            <div style={{ background: 'var(--red-dim)', border: '1px solid rgba(230,57,70,0.2)', borderRadius: 14, padding: '10px 16px', display: 'flex', alignItems: 'center', gap: 10, width: '100%', marginBottom: 16 }}>
              <span style={{ fontSize: 22 }}>🔥</span>
              <span style={{ fontSize: 13, color: 'var(--text)', fontWeight: 600 }}>{streak} day streak! Keep it up!</span>
            </div>
          )}

          {/* Action buttons */}
          <div style={{ width: '100%', display: 'flex', flexDirection: 'column', gap: 8 }}>
            <button
              onClick={shareScore}
              style={{ background: 'var(--wa)', border: 'none', borderRadius: 16, padding: 16, color: '#fff', fontFamily: "'Bebas Neue',sans-serif", fontSize: 20, letterSpacing: 1, cursor: 'pointer', width: '100%', boxShadow: '0 8px 24px rgba(37,211,102,0.25)' }}
            >
              📲 SHARE MY SCORE ON WHATSAPP
            </button>
            <button
              onClick={() => setScreen('fanarmy')}
              style={{ background: 'var(--bg3)', border: '1px solid var(--border2)', borderRadius: 14, padding: 13, color: 'var(--text)', fontFamily: "'Bebas Neue',sans-serif", fontSize: 16, cursor: 'pointer', width: '100%' }}
            >
              See Today's Leaderboard
            </button>
            <button
              onClick={() => setScreen('home')}
              style={{ background: 'transparent', border: '1px solid var(--border)', borderRadius: 14, padding: 13, color: 'var(--muted2)', fontFamily: "'Bebas Neue',sans-serif", fontSize: 16, cursor: 'pointer', width: '100%' }}
            >
              Go to Home
            </button>
          </div>
        </div>
      </div>
      <BottomNav active="quiz" onQuiz={onQuiz} />
    </>
  );
}
