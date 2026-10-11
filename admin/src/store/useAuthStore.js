import { create } from 'zustand';
import axios from 'axios';

// Create a configured axios instance for the API
export const api = axios.create({
  baseURL: '/api/admin',
  withCredentials: true, // Needed to send and receive httpOnly cookies
});

export const useAuthStore = create((set) => ({
  admin: null,
  isAuthenticated: false,
  isLoading: false,
  error: null,

  login: async (email, password) => {
    set({ isLoading: true, error: null });
    try {
      const { data } = await api.post('/auth/login', { email, password });
      set({ admin: data.admin, isAuthenticated: true, isLoading: false });
    } catch (err) {
      set({ 
        error: err.response?.data?.error?.message || 'Login failed', 
        isLoading: false 
      });
      throw err;
    }
  },

  logout: async () => {
    try {
      await api.post('/auth/logout');
      set({ admin: null, isAuthenticated: false });
    } catch (err) {
      console.error('Logout error', err);
    }
  },
}));
