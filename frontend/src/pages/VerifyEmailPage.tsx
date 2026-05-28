import React, { useEffect, useState, useCallback } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import API from '../services/api';

const VerifyEmailPage = () => {
  const [searchParams] = useSearchParams();
  const { login } = useAuth();
  const navigate = useNavigate();
  const [status, setStatus] = useState<'loading' | 'success' | 'error'>('loading');
  const [message, setMessage] = useState('');

  const verifyEmail = useCallback(async (token: string) => {
    try {
      const res = await API.post('/auth/verify-email', { token });
      login(res.data.token, res.data.username);
      setStatus('success');
      setMessage(res.data.message);
      setTimeout(() => navigate('/library'), 2000);
    } catch (err: any) {
      setStatus('error');
      setMessage(err.response?.data?.error || 'Verification failed.');
    }
  }, [login, navigate]);

  useEffect(() => {
    const token = searchParams.get('token');
    if (!token) {
      setStatus('error');
      setMessage('Invalid verification link.');
      return;
    }
    verifyEmail(token);
  }, [searchParams, verifyEmail]);

  return (
    <div className="min-h-screen bg-amber-50 flex items-center justify-center px-4">
      <div className="bg-white rounded-2xl shadow-md p-8 w-full max-w-md text-center">
        <div className="text-6xl mb-4">🪺</div>
        <h1 className="text-2xl font-bold text-amber-800 mb-4">BookNest</h1>

        {status === 'loading' && (
          <>
            <p className="text-gray-500">Verifying your email...</p>
            <div className="mt-4 flex justify-center gap-1">
              <span className="w-2 h-2 bg-amber-500 rounded-full animate-bounce" style={{ animationDelay: '0ms' }} />
              <span className="w-2 h-2 bg-amber-500 rounded-full animate-bounce" style={{ animationDelay: '150ms' }} />
              <span className="w-2 h-2 bg-amber-500 rounded-full animate-bounce" style={{ animationDelay: '300ms' }} />
            </div>
          </>
        )}

        {status === 'success' && (
          <>
            <p className="text-green-600 font-medium text-lg mb-2">✅ {message}</p>
            <p className="text-gray-400 text-sm">Redirecting you to your library...</p>
          </>
        )}

        {status === 'error' && (
          <>
            <p className="text-red-500 font-medium mb-4">❌ {message}</p>
            <button
              onClick={() => navigate('/login')}
              className="bg-amber-700 hover:bg-amber-800 text-white px-6 py-2.5 rounded-xl text-sm font-medium transition-colors"
            >
              Go to Login
            </button>
          </>
        )}
      </div>
    </div>
  );
};

export default VerifyEmailPage;