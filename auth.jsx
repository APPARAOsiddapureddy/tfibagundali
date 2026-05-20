/* TFI Bagundali — Auth + Onboarding screens
   Splash / Login / OTP share a "welcome to the show" concept:
   a tilted poster wall behind a frosted card. */

// Reusable: tilted 3-column scrolling poster wall (decorative bg)
const PosterWall = ({ tint = 0.6 }) => (
  <div style={{ position: 'absolute', inset: 0, overflow: 'hidden', pointerEvents: 'none' }}>
    <div style={{
      position: 'absolute', top: '-12%', left: '-18%', right: '-18%', bottom: '-12%',
      transform: 'rotate(-14deg)', display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 14,
    }}>
      {[
        ['peddi','devara','spirit','pushpa'],
        ['salaar','kuberaa','thandel','gametime','peddi'],
        ['spirit','devara','pushpa','salaar'],
      ].map((col, ci) => (
        <div key={ci} style={{ display: 'flex', flexDirection: 'column', gap: 14, transform: `translateY(${ci===1 ? -60 : ci===2 ? -30 : 0}px)` }}>
          {col.map((c, i) => (
            <div key={i} className={`poster ${c}`} style={{ width: '100%', aspectRatio: '2/3', borderRadius: 14 }} />
          ))}
        </div>
      ))}
    </div>
    {/* dark wash */}
    <div style={{ position: 'absolute', inset: 0, background: `linear-gradient(180deg, rgba(6,7,13,${tint+0.2}) 0%, rgba(6,7,13,${tint}) 40%, rgba(6,7,13,${tint+0.25}) 100%)` }} />
    {/* warm spotlight from above */}
    <div style={{ position: 'absolute', top: -120, left: '50%', transform: 'translateX(-50%)', width: 520, height: 520, borderRadius: '50%', background: 'radial-gradient(circle, rgba(245,165,36,0.32), transparent 60%)', filter: 'blur(20px)' }} />
  </div>
);

// Brand wordmark with logo + Telugu
const Brandmark = ({ size = 'lg' }) => {
  const big = size === 'lg';
  return (
    <div style={{ textAlign: 'center', position: 'relative', zIndex: 2 }}>
      <div style={{
        display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
        width: big ? 76 : 52, height: big ? 76 : 52,
        borderRadius: big ? 22 : 14,
        background: 'linear-gradient(160deg, #FFB52E, #E5484D 70%, #8B5CF6)',
        boxShadow: '0 18px 60px rgba(245,165,36,0.45), inset 0 1px 0 rgba(255,255,255,0.3), 0 0 0 1px rgba(255,255,255,0.15)',
        marginBottom: big ? 18 : 10,
      }}>
        <svg width={big ? 42 : 28} height={big ? 42 : 28} viewBox="0 0 42 42" fill="none">
          <path d="M5 8h32a3 3 0 013 3v20a3 3 0 01-3 3H5a3 3 0 01-3-3V11a3 3 0 013-3z" stroke="#fff" strokeWidth="2.2" fill="rgba(0,0,0,0.15)"/>
          <circle cx="7.5" cy="12.5" r="1.2" fill="#fff"/><circle cx="34.5" cy="12.5" r="1.2" fill="#fff"/>
          <circle cx="7.5" cy="29.5" r="1.2" fill="#fff"/><circle cx="34.5" cy="29.5" r="1.2" fill="#fff"/>
          <path d="M14 16h14M14 21h10M14 26h8" stroke="#fff" strokeWidth="2.4" strokeLinecap="round"/>
        </svg>
      </div>
      <div className="h-display" style={{
        fontSize: big ? 44 : 22, lineHeight: 1, letterSpacing: -0.02,
        background: 'linear-gradient(180deg, #FFFFFF, #FFB36C)',
        WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent',
      }}>TFI Bagundali</div>
      <div className="te" style={{ fontSize: big ? 16 : 12, color: '#FFD7A0', marginTop: 4 }}>టీఎఫ్‌ఐ బాగుందలి</div>
    </div>
  );
};

// ───────── 1. Splash ─────────
const Splash = () => (
  <PhoneFrame>
    <div style={{ position: 'relative', flex: 1, background: '#06070D', overflow: 'hidden' }} className="grain">
      <PosterWall tint={0.55} />

      {/* Centered brand */}
      <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', zIndex: 5, padding: '0 28px' }}>
        {/* Marquee chip */}
        <div style={{ display: 'inline-flex', alignItems: 'center', gap: 6, padding: '6px 12px', borderRadius: 999, background: 'rgba(245,165,36,0.18)', border: '1px solid rgba(245,165,36,0.4)', marginBottom: 26 }}>
          <span style={{ width: 6, height: 6, borderRadius: 999, background: '#FFB52E', boxShadow: '0 0 10px #FFB52E' }} />
          <span style={{ fontSize: 11, color: '#FFD7A0', fontWeight: 700, letterSpacing: 0.18, textTransform: 'uppercase' }}>Now Showing · Daily</span>
        </div>

        <Brandmark size="lg" />

        <div style={{ marginTop: 24, padding: '12px 22px', borderRadius: 999, background: 'rgba(0,0,0,0.4)', backdropFilter: 'blur(10px)', border: '1px solid rgba(255,255,255,0.1)' }}>
          <div style={{ fontSize: 13, color: 'rgba(255,255,255,0.92)', fontWeight: 600, letterSpacing: 0.06, textAlign: 'center' }}>
            Mana Cinema · Mana Updates · Mana Pride
          </div>
        </div>
      </div>

      {/* Bottom strip — live ticker of today's pulse */}
      <div style={{ position: 'absolute', bottom: 60, left: 22, right: 22, zIndex: 5 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '10px 12px', borderRadius: 14, background: 'rgba(20,22,40,0.6)', backdropFilter: 'blur(12px)', border: '1px solid rgba(255,255,255,0.08)' }}>
          <div style={{ display: 'flex' }}>
            {['#FFB52E','#E5484D','#8B5CF6'].map((c, i) => (
              <div key={i} style={{ width: 22, height: 22, borderRadius: 999, background: c, border: '2px solid #0B0D17', marginLeft: i ? -8 : 0 }} />
            ))}
          </div>
          <div style={{ flex: 1, fontSize: 11.5, color: 'rgba(255,255,255,0.75)' }}>
            <b style={{ color: '#fff' }}>12 fresh updates</b> in TFI today
          </div>
          <div style={{ display: 'flex', gap: 3 }}>
            {[0,1,2].map(i => (
              <div key={i} style={{ width: 5, height: 5, borderRadius: 999, background: 'rgba(255,255,255,0.3)', animation: `pulse 1.4s ${i*0.2}s infinite` }} />
            ))}
          </div>
        </div>
        <div style={{ marginTop: 12, fontSize: 10, color: 'rgba(255,255,255,0.35)', textAlign: 'center', fontWeight: 600, letterSpacing: 0.2, textTransform: 'uppercase' }}>● Powered by fans</div>
      </div>
    </div>
  </PhoneFrame>
);

// ───────── 2. Phone login ─────────
const Login = () => (
  <PhoneFrame>
    <div style={{ position: 'relative', flex: 1, background: '#06070D', overflow: 'hidden', display: 'flex', flexDirection: 'column' }} className="grain">
      <PosterWall tint={0.62} />

      {/* Top brand */}
      <div style={{ position: 'relative', zIndex: 5, padding: '20px 24px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <div style={{ width: 36, height: 36, borderRadius: 10, background: 'linear-gradient(160deg, #FFB52E, #E5484D 70%, #8B5CF6)', boxShadow: '0 4px 12px rgba(245,165,36,0.4)' }} />
          <div>
            <div className="h2" style={{ fontSize: 14, color: '#fff' }}>TFI Bagundali</div>
            <div className="te" style={{ fontSize: 10, color: '#FFD7A0' }}>మన సినిమా</div>
          </div>
        </div>
        <div style={{ display: 'inline-flex', alignItems: 'center', gap: 5, padding: '4px 10px', borderRadius: 999, background: 'rgba(48,199,108,0.16)', border: '1px solid rgba(48,199,108,0.3)' }}>
          <span style={{ width: 6, height: 6, borderRadius: 999, background: '#6FE3A0', boxShadow: '0 0 8px #6FE3A0' }} />
          <span style={{ fontSize: 10, color: '#6FE3A0', fontWeight: 700, letterSpacing: 0.08 }}>FREE FOREVER</span>
        </div>
      </div>

      {/* Spacer */}
      <div style={{ flex: 1 }} />

      {/* Frosted card */}
      <div style={{ position: 'relative', zIndex: 5, padding: '0 22px 28px' }}>
        <div style={{
          padding: 22, borderRadius: 28,
          background: 'linear-gradient(180deg, rgba(20,22,40,0.72), rgba(10,12,24,0.92))',
          backdropFilter: 'blur(20px) saturate(180%)',
          WebkitBackdropFilter: 'blur(20px) saturate(180%)',
          border: '1px solid rgba(255,255,255,0.1)',
          boxShadow: '0 30px 60px rgba(0,0,0,0.5), inset 0 1px 0 rgba(255,255,255,0.06)',
        }}>
          {/* Eyebrow */}
          <div className="label-eyebrow" style={{ color: 'var(--gold)', marginBottom: 6 }}>● WELCOME FAN</div>
          <div className="h-display" style={{ fontSize: 34, lineHeight: 1, color: '#fff', marginBottom: 4 }}>Login to the<br/>show.</div>
          <div className="te" style={{ fontSize: 14, color: '#FFD7A0', marginTop: 6 }}>మీ ఫేవరెట్ సినిమా అప్‌డేట్స్ ఇక్కడ.</div>
          <div style={{ fontSize: 12.5, color: 'var(--t-lo)', marginTop: 4 }}>Latest TFI updates, trivia, polls & wallpapers.</div>

          {/* Phone input */}
          <div style={{ marginTop: 22 }}>
            <div style={{ fontSize: 10.5, color: 'var(--t-lo)', fontWeight: 700, letterSpacing: 0.1, marginBottom: 8 }}>PHONE NUMBER</div>
            <div style={{ display: 'flex', gap: 10 }}>
              <div style={{
                display: 'flex', alignItems: 'center', padding: '0 14px', height: 56,
                fontWeight: 700, gap: 6, borderRadius: 16,
                background: 'rgba(255,255,255,0.05)', border: '1px solid var(--line)',
              }}>
                <span style={{ fontSize: 18 }}>🇮🇳</span>
                <span style={{ fontFamily: 'var(--f-mono)', color: '#fff' }}>+91</span>
                <svg width="10" height="10" viewBox="0 0 12 12" fill="none" stroke="currentColor" strokeWidth="2" opacity="0.5"><path d="M2 4l4 4 4-4"/></svg>
              </div>
              <div style={{
                flex: 1, display: 'flex', alignItems: 'center', padding: '0 16px', height: 56,
                borderRadius: 16,
                background: 'rgba(255,255,255,0.05)', border: '1.5px solid var(--gold)',
                boxShadow: '0 0 0 4px rgba(245,165,36,0.12)',
              }}>
                <span style={{ fontFamily: 'var(--f-mono)', fontSize: 19, fontWeight: 600, color: '#fff', letterSpacing: 0.04 }}>98765 43210</span>
                <span style={{ marginLeft: 'auto', width: 2, height: 22, background: 'var(--gold)', animation: 'blink 1s infinite' }} />
              </div>
            </div>
          </div>

          <button className="btn btn-primary" style={{ width: '100%', height: 56, fontSize: 16, marginTop: 16 }}>
            Send OTP
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round"><path d="M5 12h14M13 6l6 6-6 6"/></svg>
          </button>

          <div style={{ marginTop: 14, display: 'flex', alignItems: 'center', gap: 8 }}>
            <div style={{ width: 28, height: 28, borderRadius: 999, background: 'rgba(48,199,108,0.16)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#6FE3A0" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M12 1l3 6 6 1-4.5 4.5L18 19l-6-3-6 3 1.5-6.5L3 8l6-1z"/></svg>
            </div>
            <div style={{ fontSize: 11.5, color: 'var(--t-mid)', lineHeight: 1.4 }}>
              <b style={{ color: '#fff' }}>No password.</b> One quick OTP and you're in.
            </div>
          </div>
        </div>

        <div style={{ textAlign: 'center', marginTop: 14, fontSize: 11, color: 'rgba(255,255,255,0.4)' }}>
          By continuing you agree to our <span style={{ color: '#fff', textDecoration: 'underline' }}>Terms</span> & <span style={{ color: '#fff', textDecoration: 'underline' }}>Privacy</span>
        </div>
      </div>
    </div>
  </PhoneFrame>
);

// ───────── 3. OTP verify (ticket-stub treatment) ─────────
const OTPVerify = () => (
  <PhoneFrame>
    <div style={{ position: 'relative', flex: 1, background: '#06070D', overflow: 'hidden', display: 'flex', flexDirection: 'column' }} className="grain">
      <PosterWall tint={0.7} />

      <div style={{ position: 'relative', zIndex: 5, padding: '14px 20px 0', display: 'flex', alignItems: 'center', gap: 12 }}>
        <button className="btn btn-secondary glass" style={{ width: 40, height: 40, padding: 0, borderRadius: 999, color: '#fff' }}>
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round"><path d="M14 6l-6 6 6 6"/></svg>
        </button>
        <div style={{ flex: 1, fontSize: 12, color: 'rgba(255,255,255,0.6)', fontWeight: 600 }}>● Step 2 of 2 · Verify</div>
      </div>

      <div style={{ flex: 1 }} />

      {/* Ticket-stub card */}
      <div style={{ position: 'relative', zIndex: 5, padding: '0 20px 24px' }}>
        <div style={{
          position: 'relative',
          background: 'linear-gradient(180deg, #FFF5E0 0%, #FFE5B8 100%)',
          color: '#1A0F00',
          borderRadius: 24,
          padding: '22px 22px 18px',
          boxShadow: '0 30px 60px rgba(0,0,0,0.5), inset 0 1px 0 rgba(255,255,255,0.5)',
        }}>
          {/* Perforation notches on left/right */}
          {[true, false].map((left, k) => (
            <div key={k} style={{
              position: 'absolute', [left ? 'left' : 'right']: -10, top: '46%',
              width: 20, height: 20, borderRadius: 999, background: '#06070D',
            }} />
          ))}

          {/* Header strip */}
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', paddingBottom: 14, borderBottom: '1.5px dashed rgba(26,15,0,0.35)' }}>
            <div>
              <div style={{ fontSize: 9.5, fontWeight: 700, letterSpacing: 0.18, color: 'rgba(26,15,0,0.65)' }}>● TFI BAGUNDALI</div>
              <div style={{ fontFamily: 'var(--f-display)', fontSize: 24, fontWeight: 800, lineHeight: 1.05, color: '#1A0F00', marginTop: 2 }}>FAN TICKET</div>
            </div>
            <div style={{ textAlign: 'right' }}>
              <div style={{ fontSize: 9, fontWeight: 700, letterSpacing: 0.12, color: 'rgba(26,15,0,0.6)' }}>HALL</div>
              <div style={{ fontFamily: 'var(--f-mono)', fontSize: 24, fontWeight: 800, color: '#1A0F00', lineHeight: 1 }}>A1</div>
            </div>
          </div>

          {/* Phone row */}
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', paddingTop: 14, paddingBottom: 14 }}>
            <div>
              <div style={{ fontSize: 9, fontWeight: 700, color: 'rgba(26,15,0,0.6)', letterSpacing: 0.12 }}>SENT TO</div>
              <div style={{ fontFamily: 'var(--f-mono)', fontSize: 15, fontWeight: 700, color: '#1A0F00', marginTop: 2 }}>+91 98765 43210</div>
            </div>
            <button style={{ fontSize: 11, fontWeight: 700, color: '#B43A12', background: 'rgba(180,58,18,0.12)', border: 'none', padding: '6px 10px', borderRadius: 8 }}>Edit</button>
          </div>

          {/* OTP boxes — punched in the ticket */}
          <div style={{ fontSize: 9, fontWeight: 700, color: 'rgba(26,15,0,0.65)', letterSpacing: 0.18, marginBottom: 6 }}>ENTER 6-DIGIT CODE</div>
          <div className="te" style={{ fontSize: 11.5, color: '#8B6A2A', marginBottom: 12 }}>OTP మీ మొబైల్ కి పంపించాం</div>

          <div style={{ display: 'flex', gap: 8, justifyContent: 'space-between', marginBottom: 16 }}>
            {['4','8','3','7','','',].map((d, i) => (
              <div key={i} style={{
                flex: 1, height: 56,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontFamily: 'var(--f-display)', fontWeight: 800, fontSize: 26,
                color: d ? '#1A0F00' : 'rgba(26,15,0,0.2)',
                background: d ? '#fff' : 'rgba(26,15,0,0.04)',
                border: i === 4 ? '2px solid #B43A12' : '1.5px solid rgba(26,15,0,0.18)',
                boxShadow: i === 4 ? '0 0 0 4px rgba(180,58,18,0.15)' : 'inset 0 1px 2px rgba(26,15,0,0.04)',
                borderRadius: 12,
                position: 'relative',
              }}>
                {d || (i === 4 && <span style={{ width: 2, height: 26, background: '#B43A12', animation: 'blink 1s infinite' }} />)}
              </div>
            ))}
          </div>

          {/* Status row */}
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingBottom: 14 }}>
            <span style={{ fontSize: 11.5, color: 'rgba(26,15,0,0.6)' }}>Didn't get it?</span>
            <span style={{ fontSize: 11.5, fontWeight: 700, color: '#1A0F00' }}>Resend in <b style={{ fontFamily: 'var(--f-mono)', color: '#B43A12' }}>0:24</b></span>
          </div>

          {/* Verify CTA */}
          <button className="btn btn-primary" style={{ width: '100%', height: 54, fontSize: 15, background: 'linear-gradient(180deg, #1A0F00, #2B1900)', color: '#FFD7A0', boxShadow: '0 10px 22px rgba(26,15,0,0.45), inset 0 1px 0 rgba(255,255,255,0.18)' }}>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round"><path d="M4 12l5 5L20 6"/></svg>
            Verify & Enter
          </button>

          {/* Barcode line */}
          <div style={{ marginTop: 18, paddingTop: 14, borderTop: '1.5px dashed rgba(26,15,0,0.35)', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <div style={{ display: 'flex', gap: 1.5, alignItems: 'flex-end' }}>
              {[2,3,1,4,2,3,5,2,1,3,4,2,3,1,2,5,3,2,4,1,3,2,4,2].map((w, i) => (
                <div key={i} style={{ width: w, height: 26, background: '#1A0F00' }} />
              ))}
            </div>
            <div style={{ fontFamily: 'var(--f-mono)', fontSize: 10, color: 'rgba(26,15,0,0.6)', fontWeight: 700 }}>TFI · 6:00 AM</div>
          </div>
        </div>

        {/* Sub note */}
        <div style={{ marginTop: 16, fontSize: 11, color: 'rgba(255,255,255,0.5)', textAlign: 'center' }}>
          Auto-detecting OTP from SMS…
        </div>
      </div>
    </div>
  </PhoneFrame>
);

// keyframes (added once)
if (typeof document !== 'undefined' && !document.getElementById('auth-keyframes')) {
  const s = document.createElement('style');
  s.id = 'auth-keyframes';
  s.textContent = '@keyframes blink { 0%, 50% { opacity: 1 } 51%, 100% { opacity: 0 } } @keyframes pulse { 0%, 100% { opacity: 0.3 } 50% { opacity: 1 } }';
  document.head.appendChild(s);
}

// ───────── 4. Favourite Hero (optional) ─────────
const HeroSelection = () => (
  <PhoneFrame>
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
      <div style={{ padding: '8px 20px 0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div style={{ display: 'flex', gap: 6 }}>
          {[1,1,0,0].map((on,i) => <div key={i} style={{ width: 22, height: 4, borderRadius: 2, background: on ? 'var(--gold)' : 'rgba(255,255,255,0.1)' }} />)}
        </div>
        <div style={{ fontSize: 12, color: 'var(--t-lo)', fontWeight: 600 }}>Skip for now</div>
      </div>

      <div style={{ padding: '24px 20px 16px' }}>
        <div className="te" style={{ fontSize: 11, color: 'var(--gold)', fontWeight: 700, letterSpacing: 0.06, marginBottom: 4 }}>STEP 2 OF 4</div>
        <div className="h1" style={{ fontSize: 26, lineHeight: 1.05, marginBottom: 4 }}>
          <span className="te">Nee Favourite Hero Evaru?</span>
        </div>
        <div style={{ fontSize: 13, color: 'var(--t-mid)', lineHeight: 1.4 }}>Mee favourite hero updates ni mundu chupistam. Optional — anytime change cheyochu.</div>
      </div>

      <div className="scroll" style={{ padding: '0 16px' }}>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: 10 }}>
          {HEROES.map((h, i) => (
            <div key={h.id} className="card" style={{
              padding: 12,
              border: i === 0 ? '2px solid var(--gold)' : '1px solid var(--line)',
              background: i === 0 ? 'linear-gradient(180deg, rgba(245,165,36,0.18), var(--bg-2))' : undefined,
              position: 'relative',
            }}>
              {i === 0 && <div style={{ position: 'absolute', top: 6, right: 6, width: 22, height: 22, borderRadius: 999, background: 'var(--gold)', color: '#1A0F00', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 800, fontSize: 12 }}>✓</div>}
              <HeroAvatar hero={h} size={56} />
              <div className="h2" style={{ fontSize: 13.5, marginTop: 8, lineHeight: 1.1 }}>{h.name}</div>
              <div className="te" style={{ fontSize: 11, color: 'var(--t-lo)', lineHeight: 1.1 }}>{h.te}</div>
              <div style={{ marginTop: 6, display: 'flex', alignItems: 'center', gap: 5, fontSize: 11, fontWeight: 600 }}>
                <span style={{ fontSize: 13 }}>{h.emoji}</span>
                <span style={{ color: 'var(--t-mid)' }}>{h.army}</span>
              </div>
              <div style={{ fontSize: 10, color: 'var(--t-faint)', marginTop: 2 }}>{h.members} fans</div>
            </div>
          ))}
        </div>
        <div style={{ height: 16 }} />
      </div>

      <div style={{ padding: '12px 20px 24px', borderTop: '1px solid var(--line)', background: 'var(--bg-0)' }}>
        <PrimaryCTA label="Continue with Pawan Kalyan" icon={<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round"><path d="M5 12h14M13 6l6 6-6 6"/></svg>} />
      </div>
    </div>
  </PhoneFrame>
);

Object.assign(window, { Splash, Login, OTPVerify, HeroSelection });
