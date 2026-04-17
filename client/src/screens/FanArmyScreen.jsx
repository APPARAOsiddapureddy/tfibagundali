import { useState, useEffect } from 'react';
import { useApp } from '../context/AppContext';
import { fanArmyApi } from '../services/api';
import BottomNav from '../components/BottomNav';

const FALLBACK_LEADERBOARD = [
  { rank: 1, icon: '🦁', army_name: 'Power Army', pts: '8,24,350', pct: 100 },
  { rank: 2, icon: '👑', army_name: 'Mahesh Army', pts: '7,91,200', pct: 96 },
  { rank: 3, icon: '🔥', army_name: 'Bunny Army', pts: '7,44,800', pct: 90 },
  { rank: 4, icon: '🌊', army_name: 'Young Tiger Army', pts: '6,98,100', pct: 85 },
  { rank: 5, icon: '⚡', army_name: 'Charan Army', pts: '6,72,400', pct: 82 },
];

const FALLBACK_POLL = {
  id: 'p1',
  question: 'Best mass hero of the decade — yevaru?',
  options: [
    { id: 'a', label: 'Pawan Kalyan', vote_count: 4823 },
    { id: 'b', label: 'Mahesh Babu', vote_count: 3921 },
    { id: 'c', label: 'Allu Arjun', vote_count: 5104 },
    { id: 'd', label: 'Jr. NTR', vote_count: 2987 },
  ],
  total_votes: 16835,
};

export default function FanArmyScreen({ onQuiz }) {
  const { selectedHero, isLoggedIn } = useApp();
  const [leaderboard, setLeaderboard] = useState(FALLBACK_LEADERBOARD);
  const [poll, setPoll] = useState(FALLBACK_POLL);
  const [myVote, setMyVote] = useState(null);
  const [myArmy, setMyArmy] = useState(null);

  const HERO_ICONS = { pawan: '🦁', mahesh: '👑', allu: '🔥', charan: '⚡', ntr: '🌊', prabhas: '🐯', balayya: '🦅', chiranjeevi: '🌟' };
  const HERO_ARMIES = { pawan: 'Power Army', mahesh: 'Mahesh Army', allu: 'Bunny Army', charan: 'Charan Army', ntr: 'Young Tiger Army', prabhas: 'Rebel Army', balayya: 'Nandamuri Sena', chiranjeevi: 'Mega Army' };

  useEffect(() => {
    fanArmyApi.getLeaderboard().then(data => { if (data?.leaderboard?.length) setLeaderboard(data.leaderboard); }).catch(() => {});
    fanArmyApi.getActivePoll().then(data => { if (data?.question) setPoll(data); }).catch(() => {});
    if (isLoggedIn) {
      fanArmyApi.getMyArmy().then(setMyArmy).catch(() => {});
    }
  }, [isLoggedIn]);

  async function vote(optionId) {
    if (myVote) return;
    setMyVote(optionId);
    if (isLoggedIn && poll?.id) {
      await fanArmyApi.castVote(poll.id, optionId).catch(() => {});
    }
  }

  const totalVotes = poll.options.reduce((s, o) => s + (o.vote_count || 0), 0) || 1;

  return (
    <>
      <div className="topbar">
        <div className="app-logo">FAN ARMY</div>
        <div style={{ fontSize: 11, color: 'var(--muted2)' }}>⚔️ Weekly War</div>
      </div>

      <div className="scrollable">
        {/* My Army Card */}
        <div style={{ margin: 12, borderRadius: 18, padding: 16, background: 'linear-gradient(135deg, #0d080f, #180d20)', border: '1px solid rgba(155,50,220,0.2)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            <span style={{ fontSize: 44 }}>{HERO_ICONS[selectedHero] || '🦁'}</span>
            <div>
              <div style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 26, color: 'var(--text)', lineHeight: 1 }}>
                {HERO_ARMIES[selectedHero] || 'Power Army'}
              </div>
              <div style={{ fontSize: 11, color: 'var(--muted2)', marginTop: 2 }}>
                {myArmy ? `Rank #${myArmy.user_rank?.toLocaleString() || '?'} in ${myArmy.army_name}` : 'Select your army below'}
              </div>
            </div>
          </div>
          <div style={{ display: 'flex', gap: 6, marginTop: 10 }}>
            <div style={{ borderRadius: 8, padding: '4px 10px', fontSize: 10, fontWeight: 700, background: 'var(--red-dim)', border: '1px solid rgba(230,57,70,0.3)', color: 'var(--red)' }}>
              ⭐ Member
            </div>
            <div style={{ borderRadius: 8, padding: '4px 10px', fontSize: 10, fontWeight: 700, background: 'var(--bg4)', border: '1px solid var(--border)', color: 'var(--muted2)', cursor: 'pointer' }}>
              Change Army
            </div>
          </div>
        </div>

        {/* Leaderboard */}
        <div style={{ margin: '0 12px 12px', background: 'var(--bg3)', borderRadius: 16, border: '1px solid var(--border)', overflow: 'hidden' }}>
          <div style={{ background: 'rgba(230,57,70,0.08)', padding: '11px 14px', fontSize: 12, color: 'var(--text)', fontWeight: 700, borderBottom: '1px solid var(--border)', display: 'flex', alignItems: 'center', gap: 6 }}>
            🏆 Weekly Fan Army Leaderboard
          </div>
          {leaderboard.map((item, i) => {
            const max = leaderboard[0]?.weekly_points || leaderboard[0]?.pct || 100;
            const pct = item.pct ?? Math.round(((item.weekly_points || 0) / max) * 100);
            return (
              <div key={i} style={{ padding: '11px 14px', display: 'flex', alignItems: 'center', gap: 10, borderBottom: i < leaderboard.length - 1 ? '1px solid var(--border)' : 'none' }}>
                <div style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 20, width: 22, color: i < 3 ? 'var(--gold)' : 'var(--muted)', textAlign: 'center' }}>
                  {item.rank || i + 1}
                </div>
                <span style={{ fontSize: 22 }}>{item.icon || item.icon_emoji || '⭐'}</span>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 13, color: 'var(--text)', fontWeight: 700 }}>{item.army_name}</div>
                  <div style={{ fontSize: 10, color: 'var(--muted2)', marginTop: 1 }}>
                    {item.pts || (item.weekly_points ? item.weekly_points.toLocaleString() : '0')} points
                  </div>
                </div>
                <div style={{ width: 56, height: 4, background: 'var(--border)', borderRadius: 2, overflow: 'hidden' }}>
                  <div style={{ height: 4, background: 'var(--red)', borderRadius: 2, width: `${pct}%`, transition: 'width 0.5s' }} />
                </div>
              </div>
            );
          })}
        </div>

        {/* Weekly Poll */}
        <div style={{ margin: '0 12px 12px', background: 'var(--bg3)', borderRadius: 16, border: '1px solid var(--border)', padding: 14 }}>
          <div style={{ fontSize: 9, color: 'var(--red)', fontWeight: 700, letterSpacing: 2, textTransform: 'uppercase', marginBottom: 6 }}>
            WEEKLY POLL
          </div>
          <div style={{ fontSize: 14, color: 'var(--text)', fontWeight: 700, marginBottom: 14, lineHeight: 1.3, fontFamily: "'Noto Sans Telugu',sans-serif" }}>
            {poll.question}
          </div>

          {poll.options.map(opt => {
            const pct = Math.round((opt.vote_count / totalVotes) * 100);
            const isMyVote = myVote === opt.id;
            return (
              <div key={opt.id} style={{ marginBottom: 10, cursor: myVote ? 'default' : 'pointer' }} onClick={() => vote(opt.id)}>
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 4 }}>
                  <span style={{ fontSize: 12, color: isMyVote ? 'var(--red)' : 'var(--text)', fontWeight: isMyVote ? 700 : 600 }}>
                    {isMyVote ? '✓ ' : ''}{opt.label}
                  </span>
                  <span style={{ fontSize: 12, color: 'var(--muted2)', fontWeight: 600 }}>
                    {myVote ? `${pct}%` : '?'}
                  </span>
                </div>
                <div style={{ height: 6, background: 'var(--border)', borderRadius: 3, overflow: 'hidden' }}>
                  <div style={{ height: 6, borderRadius: 3, width: myVote ? `${pct}%` : '0%', background: isMyVote ? 'var(--red)' : 'var(--gold)', transition: 'width 0.5s' }} />
                </div>
              </div>
            );
          })}

          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: 12 }}>
            <span style={{ fontSize: 10, color: 'var(--muted2)' }}>{totalVotes.toLocaleString()} votes</span>
            <button
              style={{ background: 'var(--wa)', borderRadius: 8, padding: '5px 12px', fontSize: 10, color: '#fff', fontWeight: 700, cursor: 'pointer', border: 'none' }}
              onClick={() => {
                const text = `📊 TFI Poll: ${poll.question}\nVote cheyyi: tfi.app/poll 🎬`;
                navigator.share?.({ text }).catch(() => navigator.clipboard?.writeText(text));
              }}
            >
              📲 Share
            </button>
          </div>
        </div>
      </div>

      <BottomNav active="fanarmy" onQuiz={onQuiz} />
    </>
  );
}
