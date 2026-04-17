import { useApp } from '../context/AppContext';
import BottomNav from '../components/BottomNav';

const PLANS = [
  {
    id: 'basic',
    name: 'Basic',
    price: '₹29',
    duration: '1 Month',
    featured: false,
    features: [
      { text: 'Ad-free experience', check: true },
      { text: 'HD downloads (with watermark)', check: true },
      { text: 'All daily share cards', check: true },
    ],
  },
  {
    id: 'super',
    name: 'Super Fan',
    price: '₹79',
    duration: '3 Months',
    featured: true,
    badge: 'POPULAR',
    features: [
      { text: 'Ad-free experience', check: true },
      { text: 'HD downloads WITHOUT watermark', check: true, gold: true },
      { text: 'Exclusive hero content packs', check: true, gold: true },
      { text: 'Fan Army Gold badge', check: true, gold: true },
    ],
  },
  {
    id: 'mass',
    name: 'Mass Maharaja',
    price: '₹199',
    duration: '1 Year',
    featured: false,
    features: [
      { text: 'All Super Fan benefits', check: true },
      { text: 'Early access content', check: true, gold: true },
      { text: 'Gold Fan Army badge + priority rank', check: true, gold: true },
      { text: 'Only ₹16.6/month!', check: true, gold: true },
    ],
  },
];

export default function PremiumScreen({ onQuiz }) {
  const { setScreen, user } = useApp();

  if (user?.is_premium) {
    return (
      <>
        <div style={{ padding: 24, textAlign: 'center' }}>
          <div style={{ fontSize: 48 }}>👑</div>
          <div style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 28, color: 'var(--gold)', letterSpacing: 2, margin: '12px 0 8px' }}>YOU'RE PREMIUM!</div>
          <div style={{ fontSize: 13, color: 'var(--muted2)' }}>Nee subscription active ga undi. All premium features enjoy cheyyi!</div>
        </div>
        <BottomNav active="profile" onQuiz={onQuiz} />
      </>
    );
  }

  return (
    <>
      <div style={{ height: '100%', overflowY: 'auto', paddingBottom: 72 }}>
        <div style={{ padding: 16 }}>
          {/* Header */}
          <div style={{ textAlign: 'center', padding: '16px 0 24px' }}>
            <div style={{ position: 'absolute', top: 12, left: 12, cursor: 'pointer', color: 'var(--muted2)', fontSize: 20 }} onClick={() => setScreen('profile')}>←</div>
            <div style={{ fontSize: 52, filter: 'drop-shadow(0 0 16px rgba(244,166,26,0.4))' }}>👑</div>
            <div style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 32, color: 'var(--gold)', letterSpacing: 2, marginTop: 8 }}>
              PREMIUM AVVU
            </div>
            <div style={{ fontSize: 12, color: 'var(--muted2)', marginTop: 4 }}>
              Ad-free • HD content • Exclusive packs
            </div>
          </div>

          {/* Plan cards */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10, marginBottom: 16 }}>
            {PLANS.map(plan => (
              <div
                key={plan.id}
                style={{
                  background: plan.featured ? 'var(--gold-dim)' : 'var(--bg3)',
                  border: `1.5px solid ${plan.featured ? 'var(--gold)' : 'var(--border)'}`,
                  borderRadius: 18, padding: 16, cursor: 'pointer', transition: 'all 0.2s',
                }}
              >
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 10 }}>
                  <div>
                    <div style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 22, color: 'var(--text)', letterSpacing: 1 }}>{plan.name}</div>
                    <div style={{ fontSize: 11, color: 'var(--muted2)' }}>{plan.duration}</div>
                  </div>
                  <div style={{ textAlign: 'right' }}>
                    {plan.badge && <div style={{ background: 'var(--gold)', color: '#0d0d0d', fontSize: 9, fontWeight: 700, padding: '3px 8px', borderRadius: 6, marginBottom: 4 }}>{plan.badge}</div>}
                    <div style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 28, color: plan.featured ? 'var(--gold)' : 'var(--red)' }}>{plan.price}</div>
                  </div>
                </div>
                <div style={{ display: 'flex', flexDirection: 'column', gap: 5 }}>
                  {plan.features.map(f => (
                    <div key={f.text} style={{ fontSize: 11, color: f.gold ? 'var(--gold)' : 'var(--muted2)', display: 'flex', alignItems: 'center', gap: 6 }}>
                      <span style={{ color: 'var(--green)', fontSize: 12 }}>✓</span>
                      {f.text}
                    </div>
                  ))}
                </div>
              </div>
            ))}
          </div>

          <button
            style={{ background: 'var(--gold)', border: 'none', borderRadius: 16, padding: 16, color: '#0d0d0d', fontFamily: "'Bebas Neue',sans-serif", fontSize: 22, letterSpacing: 1, cursor: 'pointer', width: '100%', boxShadow: '0 8px 24px rgba(244,166,26,0.25)' }}
          >
            👑 Subscribe Avvu — Super Fan ₹79
          </button>

          <div style={{ textAlign: 'center', marginTop: 12, fontSize: 11, color: 'var(--muted)' }}>
            Cancel anytime • Secure payment via Razorpay
          </div>
        </div>
      </div>

      <BottomNav active="profile" onQuiz={onQuiz} />
    </>
  );
}
