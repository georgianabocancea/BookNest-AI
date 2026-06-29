import React, { useEffect, useState } from 'react';
import { useLocation, useNavigate, useSearchParams } from 'react-router-dom';
import API from '../services/api';
import Header from '../components/Header';
import { useAuth } from '../context/AuthContext';

interface Book {
  id: number;
  title: string;
  author: string;
  year: number;
  description: string;
  cover_url: string | null;
  genres: string[];
  pages: number;
  isbn: string;
}

const SORT_OPTIONS = [
  { value: 'az', label: 'A–Z' },
  { value: 'top_rated', label: 'Top Rated' },
  { value: 'newest', label: 'Newest' },
  { value: 'oldest', label: 'Oldest' },
];

const STATUS_LABELS: Record<string, string> = {
  to_read: '📚 To Read',
  reading: '📖 Reading',
  read: '✅ Read',
};

const DiscoverPage = () => {
  const [books, setBooks] = useState<Book[]>([]);
  const [loading, setLoading] = useState(true);
  const [libraryMap, setLibraryMap] = useState<Record<number, { status: string; ubId: number }>>({});
  const [selectedBook, setSelectedBook] = useState<Book | null>(null);
  const [selectedStatus, setSelectedStatus] = useState<string>('to_read');
  const [searchParams, setSearchParams] = useSearchParams();
  const { isAuthenticated } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const search = searchParams.get('q') || '';
  const genre = searchParams.get('genre') || '';
  const author = searchParams.get('author') || '';
  const sort = searchParams.get('sort') || 'az';
  const longestSortLabel = Math.max(...SORT_OPTIONS.map(opt => opt.label.length));

  useEffect(() => {
    fetchBooks();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [search, genre, author, sort]);

  useEffect(() => {
    if (isAuthenticated) fetchLibrary();
  }, [isAuthenticated]);

  const fetchBooks = async () => {
    setLoading(true);
    try {
      const params = new URLSearchParams();
      if (search) params.set('q', search);
      if (genre) params.set('genre', genre);
      if (author) params.set('author', author);
      if (sort) params.set('sort', sort);
      const res = await API.get(`/books/?${params.toString()}`);
      setBooks(res.data);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const fetchLibrary = async () => {
    try {
      const res = await API.get('/books/library');
      const map: Record<number, { status: string; ubId: number }> = {};
      res.data.forEach((ub: any) => {
        map[ub.book.id] = { status: ub.status, ubId: ub.id };
      });
      setLibraryMap(map);
    } catch (err) {
      console.error(err);
    }
  };

  const updateParam = (key: string, value: string) => {
    const next = new URLSearchParams(searchParams);
    if (value) next.set(key, value);
    else next.delete(key);
    if (key !== 'q') next.delete('q');
    setSearchParams(next);
  };

  const openModal = (book: Book) => {
    setSelectedBook(book);
    setSelectedStatus(libraryMap[book.id]?.status || 'to_read');
  };

  const goToLogin = () => {
    navigate(`/login?redirect=${encodeURIComponent(location.pathname + location.search)}`);
  };

  const addToLibrary = async () => {
    if (!selectedBook) return;
    try {
      const existing = libraryMap[selectedBook.id];
      if (existing) {
        await API.put(`/books/library/${existing.ubId}`, {
          status: selectedStatus
        });
      } else {
        const res = await API.post('/books/library', {
          book_id: selectedBook.id,
          status: selectedStatus
        });
        setLibraryMap(prev => ({
          ...prev,
          [selectedBook.id]: {
            status: selectedStatus,
            ubId: res.data.id,
          },
        }));
        setSelectedBook(null);
        return;
      }
      setLibraryMap(prev => ({
        ...prev,
        [selectedBook.id]: {
          status: selectedStatus,
          ubId: existing.ubId,
        },
      }));
      setSelectedBook(null);
    } catch (err: any) {
      console.error(err);
    }
  };

  return (
    <div className="min-h-screen bg-amber-50">
      <Header />

      <div className="max-w-5xl mx-auto px-6 py-8">
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-2xl font-bold text-gray-800">Discover books</h2>
          <button
            onClick={() => navigate('/add-book')}
            className="bg-amber-700 hover:bg-amber-800 text-white px-4 py-2 rounded-xl text-sm font-medium transition-colors"
          >
            + Add Book
          </button>
        </div>

        <input
          type="text"
          value={search}
          onChange={e => updateParam('q', e.target.value)}
          placeholder="Search by title or author..."
          className="w-full border border-gray-200 rounded-xl px-4 py-3 mb-4 focus:outline-none focus:ring-2 focus:ring-amber-300 bg-white"
        />

        {(genre || author) && (
          <div className="flex gap-2 mb-4 flex-wrap">
            {genre && (
              <span className="flex items-center gap-1 bg-amber-100 text-amber-800 px-3 py-1 rounded-full text-sm font-medium">
                Genre: {genre}
                <button onClick={() => updateParam('genre', '')} className="ml-1 hover:text-red-500">✕</button>
              </span>
            )}
            {author && (
              <span className="flex items-center gap-1 bg-amber-100 text-amber-800 px-3 py-1 rounded-full text-sm font-medium">
                Author: {author}
                <button onClick={() => updateParam('author', '')} className="ml-1 hover:text-red-500">✕</button>
              </span>
            )}
          </div>
        )}

        <div className="mb-6 flex items-center gap-3">
          <span className="text-sm font-medium text-gray-700">Filter by:</span>
          <div className="relative" style={{ width: `${longestSortLabel + 4}ch` }}>
            <select
              value={sort}
              onChange={e => updateParam('sort', e.target.value)}
              className="w-full appearance-none rounded-xl border border-gray-200 bg-white px-3 py-2.5 pr-8 text-sm text-gray-700 focus:outline-none focus:ring-2 focus:ring-amber-300"
            >
              {SORT_OPTIONS.map(opt => (
                <option key={opt.value} value={opt.value}>{opt.label}</option>
              ))}
            </select>
            <span className="pointer-events-none absolute inset-y-0 right-3 flex items-center text-gray-500">▾</span>
          </div>
        </div>

        {!loading && (
          <p className="text-sm text-gray-400 mb-4">{books.length} books found</p>
        )}

        {loading ? (
          <p className="text-center text-gray-400 py-12">Loading...</p>
        ) : books.length === 0 ? (
          <div className="text-center py-16 text-gray-400">
            <p className="text-5xl mb-4">🔍</p>
            <p className="text-lg">No books found.</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {books.map(book => {
              const bookStatus = libraryMap[book.id]?.status;
              return (
                <div
                  key={book.id}
                  className="bg-white rounded-2xl shadow-sm p-4 flex gap-4 cursor-pointer hover:shadow-md transition-shadow"
                  onClick={() => openModal(book)}
                >
                  <div className="w-16 h-24 flex-shrink-0 relative">
                    {book.cover_url ? (
                      <img src={book.cover_url} alt={book.title} className="w-full h-full object-cover rounded-lg" />
                    ) : (
                      <div className="w-full h-full bg-amber-100 rounded-lg flex items-center justify-center text-2xl">📖</div>
                    )}
                  </div>
                  <div className="flex-1 min-w-0">
                    <h3 className="font-semibold text-gray-800 truncate">{book.title}</h3>
                    <button
                      onClick={e => { e.stopPropagation(); updateParam('author', book.author); }}
                      className="text-sm text-amber-700 hover:underline text-left"
                    >
                      {book.author}
                    </button>
                    <p className="text-xs text-gray-400">{book.year} · {book.pages} pages</p>
                    <div className="flex flex-wrap gap-1 mt-1">
                      {book.genres.slice(0, 2).map(g => (
                        <button
                          key={g}
                          onClick={e => { e.stopPropagation(); updateParam('genre', g); }}
                          className="text-xs bg-amber-100 hover:bg-amber-200 text-amber-700 px-2 py-0.5 rounded-full transition-colors"
                        >
                          {g}
                        </button>
                      ))}
                    </div>
                    {bookStatus ? (
                      <p className="text-xs text-green-600 mt-2 font-medium">
                        ✓ In library — {STATUS_LABELS[bookStatus]}
                      </p>
                    ) : (
                      <p className="text-xs text-amber-600 mt-2">Click to add →</p>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>

      {/* Modal */}
      {selectedBook && (
        <div
          className="fixed inset-0 bg-black bg-opacity-40 flex items-center justify-center z-50 px-4 py-6"
          onClick={() => setSelectedBook(null)}
        >
          <div
            className="bg-white rounded-2xl p-6 w-full max-w-2xl shadow-xl"
            onClick={e => e.stopPropagation()}
          >
            <div className="flex justify-between items-start mb-4">
              <div className="flex gap-3">
                {selectedBook.cover_url && (
                  <img src={selectedBook.cover_url} alt={selectedBook.title} className="w-14 h-20 object-cover rounded-lg" />
                )}
                <div>
                  <h3 className="font-bold text-gray-800 text-lg">{selectedBook.title}</h3>
                  <p className="text-sm text-gray-500">{selectedBook.author} · {selectedBook.year}</p>
                  <p className="text-xs text-gray-400">{selectedBook.pages} pages</p>
                </div>
              </div>
              <button onClick={() => setSelectedBook(null)} className="text-gray-400 hover:text-gray-600 text-xl">✕</button>
            </div>

            <p className="text-sm text-gray-600 mb-4 leading-relaxed">{selectedBook.description}</p>

            <div className="flex flex-wrap gap-1 mb-4">
              {selectedBook.genres.map(g => (
                <span key={g} className="text-xs bg-amber-100 text-amber-700 px-2 py-0.5 rounded-full">{g}</span>
              ))}
            </div>

            <button
              onClick={e => { e.stopPropagation(); navigate(`/books/${selectedBook.id}/reviews`); }}
              className="w-full text-sm text-gray-500 hover:text-amber-700 border border-gray-200 hover:border-amber-300 py-2 rounded-xl transition-colors mb-4"
            >
              📝 View community reviews
            </button>

            <label className="block text-sm font-medium text-gray-700 mb-2">
              {libraryMap[selectedBook.id] ? 'Change status:' : 'Add to:'}
            </label>
            <div className="flex gap-2 mb-5">
              {[
                { value: 'to_read', label: '📚 To Read' },
                { value: 'reading', label: '📖 Reading' },
                { value: 'read', label: '✅ Read' },
              ].map(opt => (
                <button
                  key={opt.value}
                  onClick={() => setSelectedStatus(opt.value)}
                  className={`flex-1 py-2 rounded-xl text-sm font-medium transition-all ${
                    selectedStatus === opt.value
                      ? 'bg-amber-700 text-white'
                      : 'bg-gray-100 text-gray-600 hover:bg-amber-100'
                  }`}
                >
                  {opt.label}
                </button>
              ))}
            </div>

            <button
              onClick={isAuthenticated ? addToLibrary : goToLogin}
              className="w-full py-3 rounded-xl text-sm font-medium transition-colors bg-amber-700 hover:bg-amber-800 text-white"
            >
              {isAuthenticated
                ? (libraryMap[selectedBook.id] ? 'Update status' : 'Add to library')
                : 'Sign in to add to library'}
            </button>

            {!isAuthenticated && (
              <p className="mt-3 text-center text-xs text-gray-500">
                You need to sign in before adding books to your library.
              </p>
            )}
          </div>
        </div>
      )}
    </div>
  );
};

export default DiscoverPage;