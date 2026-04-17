import { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { authApi, contentApi } from '../services/api';

const AppContext = createContext(null);

export function AppProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [screen, setScreen] = useState('splash');
  const [coinBalance, setCoinBalance] = useState(0);
  const [selectedHero, setSelectedHero] = useState('pawan');

  useEffect(() => {
    const token = authApi.getAccessToken();
    if (token) {
      authApi.getMe()
        .then(data => {
          setUser(data);
          setCoinBalance(data.coin_balance || 0);
          setScreen('home');
        })
        .catch(() => {
          authApi.clearTokens();
          setScreen('splash');
        })
        .finally(() => setLoading(false));
    } else {
      setLoading(false);
    }
  }, []);

  const login = useCallback(async (phone, code) => {
    const data = await authApi.verifyOtp(phone, code, 'web');
    authApi.setTokens(data.access_token, data.refresh_token);
    setUser(data.user);
    setCoinBalance(data.user.coin_balance || 0);
    return data;
  }, []);

  const logout = useCallback(async () => {
    const rt = authApi.getRefreshToken();
    if (rt) await authApi.logout(rt).catch(() => {});
    authApi.clearTokens();
    setUser(null);
    setScreen('splash');
  }, []);

  const refreshCoinBalance = useCallback(async () => {
    if (!user) return;
    const me = await authApi.getMe().catch(() => null);
    if (me) setCoinBalance(me.coin_balance || 0);
  }, [user]);

  const value = {
    user, setUser, loading,
    screen, setScreen,
    coinBalance, setCoinBalance, refreshCoinBalance,
    selectedHero, setSelectedHero,
    login, logout,
    isLoggedIn: !!user,
  };

  return <AppContext.Provider value={value}>{children}</AppContext.Provider>;
}

export function useApp() {
  const ctx = useContext(AppContext);
  if (!ctx) throw new Error('useApp must be used within AppProvider');
  return ctx;
}
