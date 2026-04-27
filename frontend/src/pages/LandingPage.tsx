import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import Header from '../components/Header';

const QUOTES = [
  { text: "A reader lives a thousand lives before he dies. The man who never reads lives only one.", author: "George R.R. Martin" },
  { text: "Not all those who wander are lost.", author: "J.R.R. Tolkien" },
  { text: "It is our choices that show what we truly are, far more than our abilities.", author: "J.K. Rowling" },
  { text: "So it goes.", author: "Kurt Vonnegut" },
  { text: "We accept the love we think we deserve.", author: "Stephen Chbosky" },
  { text: "The truth is rarely pure and never simple.", author: "Oscar Wilde" },
];

const LandingPage = () => {
  const navigate = useNavigate();
  const { isAuthenticated } = useAuth();
  const [quoteIndex, setQuoteIndex] = useState(0);
  const [fade, setFade] = useState(true);

  useEffect(() => {
    if (isAuthenticated) navigate('/library');
  }, [isAuthenticated]);

  useEffect(() => {
    const interval = setInterval(() => {
      setFade(false);
      setTimeout(() => {
        setQuoteIndex(prev => (prev + 1) % QUOTES.length);
        setFade(true);
      }, 500);
    }, 5000);
    return () => clearInterval(interval);
  }, []);

  const quote = QUOTES[quoteIndex];

  return (
    <div className="min-h-screen flex flex-col" style={{ background: 'linear-gradient(135deg, #7B3F00 0%, #C17B3B 50%, #E8C99A 100%)' }}>
      <Header />

      {/* Hero */}
      <div className="flex-1 flex flex-col items-center justify-center text-center px-6 py-20">
        <div className="mb-8">
          <span className="text-8xl">🪺</span>
        </div>
        <h1 className="text-6xl font-bold text-white mb-4">BookNest AI</h1>
        <p className="text-xl text-amber-100 mb-12 max-w-lg">
          Your personal reading sanctuary. Track your books, discover new ones, and chat with Nestie — your AI reading assistant.
        </p>

        <div className="flex gap-4 mb-16">
          <button
            onClick={() => navigate('/login?mode=register')}
            className="bg-white text-amber-800 font-semibold px-8 py-3 rounded-2xl hover:bg-amber-50 transition-colors shadow-lg"
          >
            Get started
          </button>
          <button
            onClick={() => navigate('/discover')}
            className="border-2 border-white text-white font-semibold px-8 py-3 rounded-2xl hover:bg-white hover:text-amber-800 transition-colors"
          >
            Browse books
          </button>
        </div>

        {/* Rotating quote */}
        <div
          className="max-w-xl transition-opacity duration-500"
          style={{ opacity: fade ? 1 : 0 }}
        >
          <p className="text-white text-lg italic mb-2">"{quote.text}"</p>
          <p className="text-amber-200 text-sm">— {quote.author}</p>
        </div>
      </div>

      {/* Features */}
      <div className="bg-white bg-opacity-10 backdrop-blur-sm px-6 py-12">
        <div className="max-w-4xl mx-auto grid grid-cols-1 md:grid-cols-3 gap-6">
          {[
            { emoji: '📚', title: 'Your Library', desc: 'Organize books into To Read, Reading, and Read. Track progress, rate and review.' },
            { emoji: '🔍', title: 'Discover', desc: 'Browse 138 curated books. Filter by genre, author, or sort by top rated.' },
            { emoji: '🪺', title: 'Meet Nestie', desc: 'Your AI reading assistant. Get personalized recommendations and help writing reviews.' },
          ].map(f => (
            <div key={f.title} className="bg-white bg-opacity-20 rounded-2xl p-6 text-center">
              <span className="text-4xl mb-3 block">{f.emoji}</span>
              <h3 className="text-white font-bold text-lg mb-2">{f.title}</h3>
              <p className="text-amber-100 text-sm">{f.desc}</p>
            </div>
          ))}
        </div>
      </div>

      {/* Footer */}
      <div className="text-center py-6">
        <p className="text-amber-200 text-sm">BookNest AI © 2026 · Built with 🧡 for readers</p>
      </div>
    </div>
  );
};

export default LandingPage;