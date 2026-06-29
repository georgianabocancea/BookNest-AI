import React, { useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import API from '../services/api';
import { useAuth } from '../context/AuthContext';

const LoginPage = () => {
  const [searchParams] = useSearchParams();
  const [isRegister, setIsRegister] = useState(searchParams.get('mode') === 'register');
  const [email, setEmail] = useState('');
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');
  const [successMessage, setSuccessMessage] = useState('');
  const { login } = useAuth();
  const navigate = useNavigate();
  const redirectPath = searchParams.get('redirect') || '/library';

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setSuccessMessage('');
    try {
      const endpoint = isRegister ? '/auth/register' : '/auth/login';
      const payload = isRegister
        ? { email, username, password }
        : { email, password };
      const res = await API.post(endpoint, payload);

      if (isRegister) {
        setSuccessMessage(res.data.message || 'Account created! Please check your email to verify your account.');
        setEmail('');
        setUsername('');
        setPassword('');
      } else {
        login(res.data.token, res.data.username);
        navigate(redirectPath);
      }
    } catch (err: any) {
      if (err.response?.data?.not_verified) {
        setError('Please verify your email before logging in. Check your inbox!');
      } else {
        setError(err.response?.data?.error || 'Something went wrong. Try again.');
      }
    }
  };

  return (
    <div className="min-h-screen bg-amber-50 flex items-center justify-center">
      <div className="bg-white rounded-2xl shadow-md p-8 w-full max-w-md">
        <div className="text-center mb-8">
        <h1
          className="text-4xl font-bold text-amber-800 cursor-pointer"
          onClick={() => navigate('/')}
        >
          🪺 BookNest AI
        </h1>
        </div>

        <div className="flex bg-amber-100 rounded-xl p-1 mb-6">
          <button
            className={`flex-1 py-2 rounded-lg text-sm font-medium transition-all ${
              !isRegister ? 'bg-white shadow text-amber-800' : 'text-gray-500'
            }`}
            onClick={() => { setIsRegister(false); setError(''); setSuccessMessage(''); }}
          >
            Sign in
          </button>
          <button
            className={`flex-1 py-2 rounded-lg text-sm font-medium transition-all ${
              isRegister ? 'bg-white shadow text-amber-800' : 'text-gray-500'
            }`}
            onClick={() => { setIsRegister(true); setError(''); setSuccessMessage(''); }}
          >
            New account
          </button>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm text-gray-600 mb-1">Email</label>
            <input
              type="email"
              value={email}
              onChange={e => setEmail(e.target.value)}
              className="w-full border border-gray-200 rounded-xl px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-amber-300"
              placeholder="email@example.com"
              required
            />
          </div>

          {isRegister && (
            <div>
              <label className="block text-sm text-gray-600 mb-1">Username</label>
              <input
                type="text"
                value={username}
                onChange={e => setUsername(e.target.value)}
                className="w-full border border-gray-200 rounded-xl px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-amber-300"
                placeholder="username"
                required
              />
            </div>
          )}

          <div>
            <label className="block text-sm text-gray-600 mb-1">Password</label>
            <div className="relative">
              <input
                type={showPassword ? 'text' : 'password'}
                value={password}
                onChange={e => setPassword(e.target.value)}
                className="w-full border border-gray-200 rounded-xl px-4 py-2.5 pr-12 focus:outline-none focus:ring-2 focus:ring-amber-300"
                placeholder="••••••••"
                required
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 transition-colors"
              >
                {showPassword ? '🙈' : '👁️'}
              </button>
            </div>
          </div>

          {error && <p className="text-red-500 text-sm text-center">{error}</p>}

          {successMessage && (
            <div className="bg-green-50 border border-green-200 rounded-xl p-4">
              <p className="text-green-700 text-sm text-center">{successMessage}</p>
            </div>
          )}

          <button
            type="submit"
            className="w-full bg-amber-700 hover:bg-amber-800 text-white font-medium py-2.5 rounded-xl transition-colors"
          >
            {isRegister ? 'Create account' : 'Sign in'}
          </button>

          {!isRegister && (
            <button
              type="button"
              onClick={() => navigate('/forgot-password')}
              className="w-full text-sm text-gray-400 hover:text-amber-700 transition-colors mt-1"
            >
              Forgot your password?
            </button>
          )}
        </form>
      </div>
    </div>
  );
};

export default LoginPage;