import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import API from '../services/api';

const ForgotPasswordPage = () => {
  const [email, setEmail] = useState('');
  const [sent, setSent] = useState(false);
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleSubmit = async () => {
    if (!email.trim()) return;
    setLoading(true);
    try {
      await API.post('/auth/forgot-password', { email });
      setSent(true);
    } catch {
      setSent(true);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-amber-50 flex items-center justify-center px-4">
      <div className="bg-white rounded-2xl shadow-md p-8 w-full max-w-md">
        <div className="text-center mb-6">
          <h1 className="text-3xl font-bold text-amber-800">🪺 BookNest AI</h1>
          <p className="text-gray-500 mt-2">Reset your password</p>
        </div>

        {sent ? (
          <div className="text-center">
            <p className="text-5xl mb-4">📧</p>
            <p className="text-gray-700 font-medium mb-2">Check your inbox!</p>
            <p className="text-gray-400 text-sm mb-6">
              If this email is registered, you'll receive a reset link shortly.
            </p>
            <button
              onClick={() => navigate('/login')}
              className="w-full bg-amber-700 hover:bg-amber-800 text-white py-2.5 rounded-xl text-sm font-medium transition-colors"
            >
              Back to Login
            </button>
          </div>
        ) : (
          <>
            <div className="mb-4">
              <label className="block text-sm text-gray-600 mb-1">Email address</label>
              <input
                type="email"
                value={email}
                onChange={e => setEmail(e.target.value)}
                placeholder="your@email.com"
                className="w-full border border-gray-200 rounded-xl px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-amber-300"
              />
            </div>
            <button
              onClick={handleSubmit}
              disabled={loading}
              className="w-full bg-amber-700 hover:bg-amber-800 disabled:opacity-50 text-white py-2.5 rounded-xl text-sm font-medium transition-colors mb-3"
            >
              {loading ? 'Sending...' : 'Send reset link'}
            </button>
            <button
              onClick={() => navigate('/login')}
              className="w-full text-sm text-gray-500 hover:text-amber-700 transition-colors"
            >
              ← Back to Login
            </button>
          </>
        )}
      </div>
    </div>
  );
};

export default ForgotPasswordPage;