import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { authApi } from '@/api/endpoints';
import type { AuthUser } from '@/types/api.types';

interface AuthContextType {
  user: AuthUser | null;
  token: string | null;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Restore session dari localStorage
  useEffect(() => {
    const storedToken = localStorage.getItem('foodler_dashboard_token');
    const storedUser = localStorage.getItem('foodler_dashboard_user');
    if (storedToken && storedUser) {
      try {
        setToken(storedToken);
        setUser(JSON.parse(storedUser));
      } catch {
        localStorage.removeItem('foodler_dashboard_token');
        localStorage.removeItem('foodler_dashboard_user');
      }
    }
    setIsLoading(false);
  }, []);

  const login = async (email: string, password: string) => {
    const res = await authApi.login(email, password);
    const { token: newToken, user: newUser } = res.data.data;
    localStorage.setItem('foodler_dashboard_token', newToken);
    localStorage.setItem('foodler_dashboard_user', JSON.stringify(newUser));
    setToken(newToken);
    setUser(newUser);
  };

  const logout = () => {
    localStorage.removeItem('foodler_dashboard_token');
    localStorage.removeItem('foodler_dashboard_user');
    setToken(null);
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, token, isLoading, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth harus digunakan dalam AuthProvider');
  return ctx;
}
