import React from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

const Header = () => {
  const { isAuthenticated, username, logout } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const isLanding = location.pathname === '/';

  return (
    <nav className={`px-6 py-4 flex justify-between items-center ${isLanding ? 'bg-transparent absolute w-full z-10' : 'bg-white shadow-sm'}`}>
      <h1
        className={`text-2xl font-bold cursor-pointer ${isLanding ? 'text-white' : 'text-amber-800'}`}
        onClick={() => navigate('/')}
      >
        🪺 BookNest AI
      </h1>

      <div className="flex items-center gap-3">
        <button
          onClick={() => navigate('/discover')}
          className={`text-sm font-medium transition-colors ${isLanding ? 'text-white hover:text-amber-200' : 'text-gray-600 hover:text-amber-700'}`}
        >
          Discover Books
        </button>

        {isAuthenticated ? (
          <>
            <button
              onClick={() => navigate('/profile')}
              className={`text-sm font-medium transition-colors ${isLanding ? 'text-white hover:text-amber-200' : 'text-gray-600 hover:text-amber-700'}`}
            >
              My Profile
            </button>
            <button
              onClick={() => navigate('/library')}
              className={`text-sm font-medium transition-colors ${isLanding ? 'text-white hover:text-amber-200' : 'text-gray-600 hover:text-amber-700'}`}
            >
              My Library
            </button>
            <button
              onClick={logout}
              className="text-sm bg-red-50 hover:bg-red-100 text-red-500 px-3 py-1.5 rounded-xl transition-colors"
            >
              Sign out
            </button>
          </>
        ) : (
          <>
            <button
              onClick={() => navigate('/login')}
              className={`text-sm font-medium transition-colors ${isLanding ? 'text-white hover:text-amber-200' : 'text-gray-600 hover:text-amber-700'}`}
            >
              Log in
            </button>
            <button
              onClick={() => navigate('/login?mode=register')}
              className="text-sm bg-amber-700 hover:bg-amber-800 text-white px-4 py-1.5 rounded-xl transition-colors"
            >
              Sign up
            </button>
          </>
        )}
      </div>
    </nav>
  );
};

export default Header;