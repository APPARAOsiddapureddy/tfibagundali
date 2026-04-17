import { useEffect } from 'react';
import { useApp } from '../context/AppContext';

const EMBER_COUNT = 28;

export default function SplashScreen() {
  const { setScreen, isLoggedIn } = useApp();

  const handleTap = () => setScreen(isLoggedIn ? 'home' : 'auth');

  return (
    <div
      style={{
        position: 'relative', width: '100%', height: '100%',
        background: '#020202', overflow: 'hidden',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        cursor: 'pointer',
      }}
      onClick={handleTap}
    >
      <style>{`
        @keyframes spFire {
          from{opacity:0.82;transform:translateX(-50%) scaleY(1);}
          to{opacity:1;transform:translateX(-50%) scaleY(1.07);}
        }
        @keyframes spBloom {
          from{opacity:0.5;transform:translateX(-50%) translateY(0);}
          to{opacity:1;transform:translateX(-50%) translateY(-20px);}
        }
        @keyframes spBurnIn {
          0%{opacity:0;transform:translateY(14px);filter:blur(10px);}
          100%{opacity:1;transform:translateY(0);filter:blur(0);}
        }
        @keyframes spRedFlicker {
          0%,87%,100%{text-shadow:0 0 22px rgba(230,57,70,1),0 0 55px rgba(230,57,70,0.75),0 0 120px rgba(230,57,70,0.38),0 5px 0 rgba(0,0,0,0.7);}
          88%{text-shadow:0 0 8px rgba(230,57,70,0.5),0 5px 0 rgba(0,0,0,0.7);}
          89%{text-shadow:0 0 38px rgba(230,57,70,1),0 0 100px rgba(230,57,70,0.9),0 0 200px rgba(230,57,70,0.5),0 5px 0 rgba(0,0,0,0.7);}
          90%{text-shadow:0 0 8px rgba(230,57,70,0.5),0 5px 0 rgba(0,0,0,0.7);}
        }
        @keyframes spGoldFlicker {
          0%,90%,100%{text-shadow:0 0 16px rgba(244,166,26,1),0 0 48px rgba(244,166,26,0.60),0 0 100px rgba(244,166,26,0.25),0 4px 0 rgba(0,0,0,0.65);opacity:1;}
          91%{opacity:0.78;}
          92%{opacity:1;}
          95%{text-shadow:0 0 28px rgba(244,166,26,1),0 0 80px rgba(244,166,26,0.75),0 0 160px rgba(244,166,26,0.38),0 4px 0 rgba(0,0,0,0.65);opacity:1;}
        }
        @keyframes spRuleBreath {
          from{opacity:0.5;transform:scaleX(0.93);}to{opacity:1;transform:scaleX(1);}
        }
        @keyframes spRise {
          0%{transform:translateY(0) translateX(0) scale(1);opacity:0.95;}
          75%{opacity:0.45;}
          100%{transform:translateY(-380px) translateX(var(--d,0px)) scale(0.2);opacity:0;}
        }
        @keyframes spRayPulse {
          0%,100%{opacity:var(--op,0.1);}50%{opacity:calc(var(--op,0.1)*1.75);}
        }
        @keyframes tapHint {
          0%,100%{opacity:0.4;}50%{opacity:0.8;}
        }
      `}</style>

      {/* Radial bg */}
      <div style={{
        position: 'absolute', inset: 0,
        background: 'radial-gradient(ellipse 70% 55% at 50% 30%,rgba(40,8,8,0.95) 0%,transparent 70%),radial-gradient(ellipse 100% 50% at 50% 100%,rgba(180,20,0,0.28) 0%,transparent 65%)',
        pointerEvents: 'none',
      }} />

      {/* Fire layers */}
      <div style={{ position: 'absolute', bottom: -50, left: '50%', transform: 'translateX(-50%)', width: 540, height: 380, background: 'radial-gradient(ellipse 100% 60% at 50% 100%,rgba(200,25,0,0.42) 0%,rgba(160,15,0,0.20) 45%,transparent 72%)', animation: 'spFire 2.6s ease-in-out infinite alternate', pointerEvents: 'none' }} />
      <div style={{ position: 'absolute', bottom: -20, left: '50%', transform: 'translateX(-50%)', width: 220, height: 580, background: 'radial-gradient(ellipse 50% 100% at 50% 100%,rgba(255,55,0,0.65) 0%,rgba(230,57,70,0.40) 25%,rgba(180,20,0,0.18) 55%,transparent 78%)', animation: 'spFire 1.8s ease-in-out infinite alternate-reverse', pointerEvents: 'none' }} />
      <div style={{ position: 'absolute', bottom: 80, left: '50%', transform: 'translateX(-50%)', width: 90, height: 300, background: 'radial-gradient(ellipse 40% 100% at 50% 100%,rgba(255,120,0,0.50) 0%,rgba(255,60,0,0.25) 40%,transparent 72%)', animation: 'spFire 1.4s ease-in-out infinite alternate', animationDelay: '0.25s', pointerEvents: 'none' }} />
      <div style={{ position: 'absolute', bottom: 220, left: '50%', transform: 'translateX(-50%)', width: 280, height: 160, background: 'radial-gradient(ellipse,rgba(244,166,26,0.20) 0%,rgba(255,90,0,0.10) 50%,transparent 78%)', animation: 'spBloom 3s ease-in-out infinite alternate', pointerEvents: 'none' }} />

      {/* SVG Rays */}
      <svg style={{ position: 'absolute', inset: 0, width: '100%', height: '100%', pointerEvents: 'none' }} viewBox="0 0 375 760" preserveAspectRatio="none">
        <defs>
          <linearGradient id="srg" x1="0" y1="1" x2="0" y2="0">
            <stop offset="0%" stopColor="#E63946" stopOpacity="1"/>
            <stop offset="65%" stopColor="#E63946" stopOpacity="0.25"/>
            <stop offset="100%" stopColor="#E63946" stopOpacity="0"/>
          </linearGradient>
          <linearGradient id="sgg" x1="0" y1="1" x2="0" y2="0">
            <stop offset="0%" stopColor="#F4A61A" stopOpacity="1"/>
            <stop offset="60%" stopColor="#F4A61A" stopOpacity="0.18"/>
            <stop offset="100%" stopColor="#F4A61A" stopOpacity="0"/>
          </linearGradient>
        </defs>
        {[{a:0,w:8,op:0.22,d:2.2},{a:-7,w:4.5,op:0.15,d:2.5},{a:7,w:4.5,op:0.15,d:2.4},
          {a:-18,w:3,op:0.10,d:3.0},{a:18,w:3,op:0.10,d:2.8},{a:-32,w:2,op:0.07,d:3.4},
          {a:32,w:2,op:0.07,d:3.2},{a:-48,w:1.2,op:0.05,d:3.8},{a:48,w:1.2,op:0.05,d:3.6},
          {a:-66,w:0.8,op:0.03,d:4.2},{a:66,w:0.8,op:0.03,d:4.0}
        ].map((r, i) => {
          const rad = (r.a * Math.PI) / 180;
          return <line key={i} x1="187.5" y1="762"
            x2={187.5 + Math.sin(rad) * 900} y2={762 - Math.cos(rad) * 900}
            stroke={Math.abs(r.a) < 25 ? 'url(#srg)' : 'url(#sgg)'}
            strokeWidth={r.w}
            style={{ '--op': r.op, animation: `spRayPulse ${r.d}s ease-in-out infinite`, animationDelay: `${i * 0.14}s` }}
          />;
        })}
        <ellipse cx="187.5" cy="762" rx="250" ry="100" fill="url(#srg)" opacity="0.30" />
      </svg>

      {/* Embers */}
      {[...Array(EMBER_COUNT)].map((_, i) => {
        const size = 1.5 + ((i * 7.3) % 3.5);
        const left = 80 + ((i * 41) % 215);
        const delay = (i * 1.3) % 4;
        const dur = 2.4 + ((i * 0.7) % 2.6);
        const drift = ((i * 23) % 90) - 45;
        const gold = i % 2 === 0;
        return <div key={i} style={{
          position: 'absolute', borderRadius: '50%', pointerEvents: 'none',
          width: size, height: size, left, bottom: 8,
          background: gold ? 'rgba(244,166,26,0.92)' : 'rgba(255,85,15,0.92)',
          boxShadow: `0 0 ${size * 2.5}px ${gold ? 'rgba(244,166,26,0.8)' : 'rgba(255,55,0,0.8)'}`,
          animation: `spRise ${dur}s linear infinite`,
          animationDelay: `${delay}s`,
          '--d': `${drift}px`,
        }} />;
      })}

      {/* Vignette */}
      <div style={{ position: 'absolute', inset: 0, background: 'radial-gradient(ellipse 90% 90% at 50% 44%,transparent 30%,rgba(0,0,0,0.80) 100%)', pointerEvents: 'none' }} />
      <div style={{ position: 'absolute', top: 0, left: 0, right: 0, height: 220, background: 'linear-gradient(180deg,rgba(2,2,2,0.95) 0%,transparent 100%)', pointerEvents: 'none' }} />

      {/* Title */}
      <div style={{ position: 'absolute', bottom: 80, left: 0, right: 0, zIndex: 30, textAlign: 'center', opacity: 0, animation: 'spBurnIn 1s cubic-bezier(0.22,1,0.36,1) forwards', animationDelay: '0.4s' }}>
        <span style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 130, lineHeight: 0.88, letterSpacing: 20, color: '#fff', display: 'block', textShadow: '0 0 22px rgba(230,57,70,1),0 0 55px rgba(230,57,70,0.75),0 0 120px rgba(230,57,70,0.38),0 5px 0 rgba(0,0,0,0.7)', animation: 'spRedFlicker 5s ease-in-out infinite', animationDelay: '2.2s' }}>TFI</span>
        <div style={{ width: 'calc(100% - 48px)', height: 1.5, margin: '10px auto 12px', background: 'linear-gradient(90deg,transparent 0%,rgba(244,166,26,0.4) 15%,rgba(244,166,26,1) 50%,rgba(244,166,26,0.4) 85%,transparent 100%)', animation: 'spRuleBreath 2.8s ease-in-out infinite alternate', animationDelay: '1.2s' }} />
        <span style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 56, lineHeight: 1, letterSpacing: 13, color: '#fff', display: 'block', textShadow: '0 0 16px rgba(244,166,26,1),0 0 48px rgba(244,166,26,0.60),0 0 100px rgba(244,166,26,0.25),0 4px 0 rgba(0,0,0,0.65)', animation: 'spGoldFlicker 4.5s ease-in-out infinite', animationDelay: '2.8s' }}>BAGUNDALI</span>
      </div>

      <div style={{ position: 'absolute', bottom: 28, left: 0, right: 0, textAlign: 'center', fontSize: 11, color: 'rgba(255,255,255,0.3)', letterSpacing: 2, animation: 'tapHint 2s ease-in-out infinite', animationDelay: '1.5s' }}>
        TAP TO ENTER
      </div>
    </div>
  );
}
