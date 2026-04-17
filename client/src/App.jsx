import { useEffect } from 'react';
import { AppProvider, useApp } from './context/AppContext';
import { useQuiz } from './hooks/useQuiz';

import SplashScreen from './screens/SplashScreen';
import AuthScreen from './screens/AuthScreen';
import OnboardScreen from './screens/OnboardScreen';
import HomeScreen from './screens/HomeScreen';
import QuizScreen from './screens/QuizScreen';
import ResultsScreen from './screens/ResultsScreen';
import ShareZoneScreen from './screens/ShareZoneScreen';
import FanArmyScreen from './screens/FanArmyScreen';
import ProfileScreen from './screens/ProfileScreen';
import MovieDetailScreen from './screens/MovieDetailScreen';
import PremiumScreen from './screens/PremiumScreen';

const SCREEN_LIST = [
  { id: 'splash', label: 'Splash' },
  { id: 'auth', label: 'Auth' },
  { id: 'onboard', label: 'Onboard' },
  { id: 'home', label: 'Home' },
  { id: 'quiz', label: 'Quiz' },
  { id: 'results', label: 'Results' },
  { id: 'sharezone', label: 'Share Zone' },
  { id: 'fanarmy', label: 'Fan Army' },
  { id: 'profile', label: 'Profile' },
  { id: 'moviedetail', label: 'Movie Detail' },
  { id: 'premium', label: 'Premium' },
];

function AppInner() {
  const { screen, setScreen, loading } = useApp();
  const quizHook = useQuiz();

  // Auto-advance splash after 3s on first load
  useEffect(() => {
    if (screen === 'splash') {
      const t = setTimeout(() => {}, 3000);
      return () => clearTimeout(t);
    }
  }, []);

  // When quiz completes, show results
  useEffect(() => {
    if (quizHook.results && screen === 'quiz') {
      if (!quizHook.results.already_completed) {
        setScreen('results');
      }
    }
  }, [quizHook.results]);

  function goQuiz() {
    quizHook.initQuiz();
    setScreen('quiz');
  }

  function renderScreen() {
    if (loading) {
      return (
        <div style={{ height: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <div style={{ textAlign: 'center' }}>
            <div style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 36, color: 'var(--red)', letterSpacing: 3 }}>TFI</div>
            <div style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 18, color: 'var(--gold)', letterSpacing: 4 }}>BAGUNDALI</div>
          </div>
        </div>
      );
    }

    switch (screen) {
      case 'splash': return <SplashScreen />;
      case 'auth': return <AuthScreen />;
      case 'onboard': return <OnboardScreen />;
      case 'home': return <HomeScreen onQuiz={goQuiz} />;
      case 'quiz': return <QuizScreen quizHook={quizHook} />;
      case 'results': return <ResultsScreen results={quizHook.results} onQuiz={goQuiz} />;
      case 'sharezone': return <ShareZoneScreen onQuiz={goQuiz} />;
      case 'fanarmy': return <FanArmyScreen onQuiz={goQuiz} />;
      case 'profile': return <ProfileScreen onQuiz={goQuiz} />;
      case 'moviedetail': return <MovieDetailScreen onQuiz={goQuiz} />;
      case 'premium': return <PremiumScreen onQuiz={goQuiz} />;
      default: return <SplashScreen />;
    }
  }

  return (
    <div className="phone-wrap">
      {/* Screen navigation switcher (dev tool) */}
      <div className="screen-switcher">
        {SCREEN_LIST.map(s => (
          <button
            key={s.id}
            className={`sw-btn ${screen === s.id ? 'active' : ''}`}
            onClick={() => s.id === 'quiz' ? goQuiz() : setScreen(s.id)}
          >
            {s.label}
          </button>
        ))}
      </div>

      {/* Phone frame */}
      <div className="phone">
        {/* Status bar */}
        <div className="status-bar">
          <span className="status-time">
            {new Date().toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit', hour12: false })}
          </span>
          <span className="status-brand">TFI BAGUNDALI</span>
          <span className="status-icons">▲▲▲ 100%</span>
        </div>

        {/* Screen content */}
        <div className="screen-body">
          {renderScreen()}
        </div>
      </div>
    </div>
  );
}

export default function App() {
  return (
    <AppProvider>
      <AppInner />
    </AppProvider>
  );
}
