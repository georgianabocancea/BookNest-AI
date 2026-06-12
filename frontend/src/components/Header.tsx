import React from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

const Header = () => {
  const { isAuthenticated, username, logout } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const isLanding = location.pathname === '/';
  const isActive = (path: string) => location.pathname === path;

  const navBtn = (path: string, label: string) => (
    <button
      onClick={() => navigate(path)}
      className={`text-sm font-medium px-3 py-1.5 rounded-xl transition-all ${
        isLanding
          ? isActive(path)
            ? 'bg-white bg-opacity-20 text-white'
            : 'text-white hover:bg-white hover:bg-opacity-10'
          : isActive(path)
            ? 'bg-amber-100 text-amber-800 font-semibold'
            : 'text-gray-600 hover:bg-gray-100'
      }`}
    >
      {label}
    </button>
  );

  return (
    <nav className={`sticky top-0 z-40 px-6 py-3 flex justify-between items-center ${
      isLanding ? 'bg-transparent w-full' : 'bg-white border-b border-gray-100 shadow-sm'
    }`}>
      <h1
        className={`text-xl font-bold cursor-pointer tracking-tight ${isLanding ? 'text-white' : 'text-amber-800'}`}
        onClick={() => navigate('/')}
      >
        🪺 BookNest AI
      </h1>

      <div className="flex items-center gap-1">
        {navBtn('/discover', '🔍 Discover')}

        {isAuthenticated ? (
          <>
            {navBtn('/add-book', '➕ Add Book')}
            {navBtn('/library', '📚 My Library')}
            {navBtn('/profile', '👤 My Profile')}

            <div className={`w-px h-5 mx-2 ${isLanding ? 'bg-white bg-opacity-30' : 'bg-gray-200'}`} />

            <div className="flex items-center gap-2">
              <span className={`text-xs font-medium ${isLanding ? 'text-amber-200' : 'text-gray-400'}`}>
                {username}
              </span>
              <button
                onClick={logout}
                className={`text-sm font-medium px-3 py-1.5 rounded-xl transition-all ${
                  isLanding
                    ? 'border border-white border-opacity-40 text-white hover:bg-white hover:bg-opacity-10'
                    : 'border border-gray-200 text-gray-500 hover:border-red-200 hover:text-red-500 hover:bg-red-50'
                }`}
              >
                Sign out
              </button>
            </div>
          </>
        ) : (
          <>
            <div className={`w-px h-5 mx-2 ${isLanding ? 'bg-white bg-opacity-30' : 'bg-gray-200'}`} />
            <button
              onClick={() => navigate('/login')}
              className={`text-sm font-medium px-3 py-1.5 rounded-xl transition-all ${
                isLanding
                  ? 'text-white hover:bg-white hover:bg-opacity-10'
                  : 'text-gray-600 hover:bg-gray-100'
              }`}
            >
              Log in
            </button>
            <button
              onClick={() => navigate('/login?mode=register')}
              className={`text-sm font-semibold px-4 py-1.5 rounded-xl transition-all shadow-sm ${
                isLanding
                  ? 'bg-white text-amber-800 hover:bg-amber-50'
                  : 'bg-amber-700 text-white hover:bg-amber-800'
              }`}
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
