import { useEffect } from 'react';
import { useApp } from '../context/AppContext';
import { useQuiz } from '../hooks/useQuiz';

const KEYS = ['a', 'b', 'c', 'd'];

export default function QuizScreen({ quizHook }) {
  const { setScreen } = useApp();
  const { questions, currentQuestion, currentIdx, answered, score, timer, results, loading, handleAnswer, initQuiz } = quizHook;

  useEffect(() => {
    initQuiz();
  }, []);

  if (loading) {
    return (
      <div className="loading-screen">
        <div style={{ textAlign: 'center' }}>
          <div style={{ fontSize: 36, marginBottom: 12 }}>🎯</div>
          <div style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 20, color: 'var(--red)' }}>Loading Quiz...</div>
        </div>
      </div>
    );
  }

  if (results?.already_completed) {
    return (
      <div style={{ padding: 24, textAlign: 'center' }}>
        <div style={{ fontSize: 48, marginBottom: 12 }}>✅</div>
        <div style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 28, color: 'var(--green)' }}>Today's Quiz Done!</div>
        <div style={{ fontSize: 13, color: 'var(--muted2)', margin: '8px 0 24px' }}>Score: {results.score}/5</div>
        <button onClick={() => setScreen('home')} style={{ background: 'var(--red)', border: 'none', borderRadius: 14, padding: '14px 28px', color: '#fff', fontFamily: "'Bebas Neue',sans-serif", fontSize: 18, cursor: 'pointer' }}>
          Go to Home
        </button>
      </div>
    );
  }

  if (!currentQuestion) return null;

  return (
    <div style={{ height: '100%', overflowY: 'auto', display: 'flex', flexDirection: 'column' }}>
      {/* Progress header */}
      <div style={{ padding: '12px 16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', borderBottom: '1px solid var(--border)', flexShrink: 0 }}>
        <div>
          <div style={{ fontSize: 10, color: 'var(--muted)', marginBottom: 4 }}>Question {currentIdx + 1} of {questions.length}</div>
          <div style={{ display: 'flex', gap: 4 }}>
            {questions.map((_, i) => (
              <div key={i} style={{ height: 4, width: 44, borderRadius: 2, background: i < currentIdx ? 'var(--green)' : i === currentIdx ? 'var(--gold)' : 'var(--border2)', transition: 'background 0.3s' }} />
            ))}
          </div>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <span style={{ fontSize: 11, color: 'var(--gold)', fontWeight: 700 }}>+{currentQuestion.coins_reward} 🪙</span>
          <div style={{
            width: 40, height: 40, borderRadius: '50%',
            border: `2px solid ${timer < 5 ? 'var(--red)' : 'var(--gold)'}`,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontFamily: "'Bebas Neue',sans-serif", fontSize: 18,
            color: timer < 5 ? 'var(--red)' : 'var(--gold)',
            transition: 'border-color 0.3s, color 0.3s',
          }}>
            {String(timer).padStart(2, '0')}
          </div>
        </div>
      </div>

      {/* Question body */}
      <div style={{ padding: 14, flex: 1, overflowY: 'auto' }}>
        <div style={{ display: 'inline-block', background: 'rgba(244,166,26,0.1)', border: '1px solid rgba(244,166,26,0.2)', borderRadius: 8, padding: '3px 8px', fontSize: 9, color: 'var(--gold)', fontWeight: 700, letterSpacing: 1, textTransform: 'uppercase', marginBottom: 10 }}>
          {currentQuestion.type?.replace(/_/g, ' ')}
        </div>

        {/* Question image/icon */}
        <div style={{ background: 'var(--bg4)', borderRadius: 16, height: 150, width: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 64, border: '1px solid var(--border)', marginBottom: 14 }}>
          {currentQuestion.image_url
            ? <img src={currentQuestion.image_url} style={{ width: '100%', height: '100%', objectFit: 'cover', borderRadius: 16 }} alt="" />
            : currentQuestion.img || '🎬'
          }
        </div>

        <div style={{ fontSize: 14, color: 'var(--text)', fontWeight: 700, marginBottom: 14, lineHeight: 1.4, fontFamily: "'Noto Sans Telugu',sans-serif" }}>
          {currentQuestion.question_text}
        </div>

        {/* Options */}
        {KEYS.map((key) => {
          const optionText = currentQuestion.options?.[key];
          if (!optionText) return null;

          let bg = 'var(--bg3)', border = 'var(--border)', color = 'var(--text)', keyBg = 'var(--bg4)';

          if (answered !== null) {
            const correctKey = currentQuestion.correct_option;
            if (key === correctKey) {
              bg = 'rgba(46,204,113,0.1)'; border = 'var(--green)'; color = 'var(--green)'; keyBg = 'var(--green)';
            } else if (key === answered && key !== correctKey) {
              bg = 'var(--red-dim)'; border = 'var(--red)'; color = 'var(--red)'; keyBg = 'var(--red)';
            }
          }

          return (
            <button
              key={key}
              onClick={() => handleAnswer(key)}
              disabled={answered !== null}
              style={{
                background: bg, border: `1.5px solid ${border}`, borderRadius: 14,
                padding: '13px 14px', width: '100%', textAlign: 'left', color,
                fontSize: 13, cursor: answered !== null ? 'default' : 'pointer',
                marginBottom: 8, display: 'flex', alignItems: 'center', gap: 10,
                transition: 'all 0.15s', fontFamily: "'Barlow',sans-serif",
              }}
            >
              <span style={{ width: 26, height: 26, borderRadius: 8, background: keyBg, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 11, fontWeight: 700, flexShrink: 0, color: (key === answered || (answered !== null && key === currentQuestion.correct_option)) ? '#fff' : 'var(--muted2)', transition: 'all 0.15s' }}>
                {key.toUpperCase()}
              </span>
              {optionText}
            </button>
          );
        })}
      </div>
    </div>
  );
}
