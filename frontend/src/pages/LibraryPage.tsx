import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import API from '../services/api';
import NestieWidget from '../components/NestieWidget';

interface Book {
  id: number;
  title: string;
  author: string;
  year: number;
  description: string;
  cover_url: string | null;
  genres: string[];
  pages: number;
}

interface UserBook {
  id: number;
  book: Book;
  status: 'to_read' | 'reading' | 'read';
  rating: number | null;
  review: string | null;
  progress: number;
}

const LibraryPage = () => {
  const { username, logout } = useAuth();
  const navigate = useNavigate();
  const [userBooks, setUserBooks] = useState<UserBook[]>([]);
  const [activeTab, setActiveTab] = useState<'to_read' | 'reading' | 'read'>('reading');
  const [loading, setLoading] = useState(true);
  const [selectedBook, setSelectedBook] = useState<UserBook | null>(null);
  const [editProgress, setEditProgress] = useState(0);
  const [editRating, setEditRating] = useState(0);
  const [editReview, setEditReview] = useState('');
  const [editStatus, setEditStatus] = useState('');

  useEffect(() => { fetchLibrary(); }, []);

  const fetchLibrary = async () => {
    try {
      const res = await API.get('/books/library');
      setUserBooks(res.data);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const openEdit = (ub: UserBook) => {
    setSelectedBook(ub);
    setEditProgress(ub.progress || 0);
    setEditRating(ub.rating || 0);
    setEditReview(ub.review || '');
    setEditStatus(ub.status);
  };

  const saveEdit = async () => {
    if (!selectedBook) return;
    try {
      await API.put(`/books/library/${selectedBook.id}`, {
        progress: editProgress,
        rating: editRating || null,
        review: editReview || null,
        status: editStatus,
      });
      await fetchLibrary();
      setSelectedBook(null);
    } catch (err) {
      console.error(err);
    }
  };

  const deleteBook = async (ubId: number) => {
    try {
      await API.delete(`/books/library/${ubId}`);
      await fetchLibrary();
      setSelectedBook(null);
    } catch (err) {
      console.error(err);
    }
  };

  const filteredBooks = userBooks.filter(ub => ub.status === activeTab);

  const tabCounts = {
    to_read: userBooks.filter(ub => ub.status === 'to_read').length,
    reading: userBooks.filter(ub => ub.status === 'reading').length,
    read: userBooks.filter(ub => ub.status === 'read').length,
  };

  const progressPercent = (progress: number, pages: number) =>
    pages > 0 ? Math.min(Math.round((progress / pages) * 100), 100) : 0;

  return (
    <div className="min-h-screen bg-amber-50">
      <nav className="bg-white shadow-sm px-6 py-4 flex justify-between items-center">
        <h1 className="text-2xl font-bold text-amber-800">🪺 BookNest</h1>
        <div className="flex items-center gap-4">
          <span className="text-gray-600">Hello, <strong>{username}</strong>!</span>
          <button onClick={() => navigate('/discover')} className="text-sm text-amber-700 hover:text-amber-900 font-medium transition-colors">
            + Discover books
          </button>
          <button onClick={logout} className="text-sm text-gray-500 hover:text-red-500 transition-colors">
            Sign out
          </button>
        </div>
      </nav>

      <div className="max-w-5xl mx-auto px-6 py-8">
        <h2 className="text-2xl font-bold text-gray-800 mb-6">My Library</h2>

        <div className="flex gap-2 mb-6">
          {([['to_read', '📚 To Read'], ['reading', '📖 Reading'], ['read', '✅ Read']] as const).map(([tab, label]) => (
            <button
              key={tab}
              onClick={() => setActiveTab(tab)}
              className={`px-4 py-2 rounded-xl text-sm font-medium transition-all ${
                activeTab === tab ? 'bg-amber-700 text-white' : 'bg-white text-gray-600 hover:bg-amber-100'
              }`}
            >
              {label}
              <span className={`ml-2 px-2 py-0.5 rounded-full text-xs ${
                activeTab === tab ? 'bg-amber-600' : 'bg-gray-100 text-gray-500'
              }`}>
                {tabCounts[tab]}
              </span>
            </button>
          ))}
        </div>

        {loading ? (
          <p className="text-center text-gray-400 py-12">Loading...</p>
        ) : filteredBooks.length === 0 ? (
          <div className="text-center py-16 text-gray-400">
            <p className="text-5xl mb-4">📭</p>
            <p className="text-lg">No books here yet.</p>
            <p className="text-sm mt-1">Discover and add books to your library!</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {filteredBooks.map(ub => (
              <div
                key={ub.id}
                className="bg-white rounded-2xl shadow-sm p-4 flex gap-4 cursor-pointer hover:shadow-md transition-shadow"
                onClick={() => openEdit(ub)}
              >
                <div className="w-16 h-24 flex-shrink-0">
                  {ub.book.cover_url ? (
                    <img src={ub.book.cover_url} alt={ub.book.title} className="w-full h-full object-cover rounded-lg" />
                  ) : (
                    <div className="w-full h-full bg-amber-100 rounded-lg flex items-center justify-center text-2xl">📖</div>
                  )}
                </div>
                <div className="flex-1 min-w-0">
                  <h3 className="font-semibold text-gray-800 truncate">{ub.book.title}</h3>
                  <p className="text-sm text-gray-500">{ub.book.author}</p>
                  <p className="text-xs text-gray-400">{ub.book.pages} pages</p>
                  <div className="flex flex-wrap gap-1 mt-1">
                    {ub.book.genres.slice(0, 2).map(g => (
                      <span key={g} className="text-xs bg-amber-100 text-amber-700 px-2 py-0.5 rounded-full">{g}</span>
                    ))}
                  </div>
                  {ub.status === 'reading' && (
                    <div className="mt-2">
                      <div className="w-full bg-gray-100 rounded-full h-1.5">
                        <div
                          className="bg-amber-500 h-1.5 rounded-full"
                          style={{ width: `${progressPercent(ub.progress, ub.book.pages)}%` }}
                        />
                      </div>
                      <p className="text-xs text-gray-400 mt-1">
                        Page {ub.progress} of {ub.book.pages}
                      </p>
                    </div>
                  )}
                  {ub.rating ? <p className="text-sm mt-1">{'⭐'.repeat(ub.rating)}</p> : null}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Modal */}
      {selectedBook && (
        <div
          className="fixed inset-0 bg-black bg-opacity-40 flex items-center justify-center z-50 px-4"
          onClick={() => setSelectedBook(null)}
        >
          <div
            className="bg-white rounded-2xl p-6 w-full max-w-md shadow-xl"
            onClick={e => e.stopPropagation()}
          >
            <div className="flex justify-between items-start mb-4">
              <div className="flex gap-3">
                {selectedBook.book.cover_url && (
                  <img src={selectedBook.book.cover_url} alt={selectedBook.book.title} className="w-14 h-20 object-cover rounded-lg" />
                )}
                <div>
                  <h3 className="font-bold text-gray-800">{selectedBook.book.title}</h3>
                  <p className="text-sm text-gray-500">{selectedBook.book.author}</p>
                  <p className="text-xs text-gray-400">{selectedBook.book.pages} pages</p>
                </div>
              </div>
              <button onClick={() => setSelectedBook(null)} className="text-gray-400 hover:text-gray-600 text-xl">✕</button>
            </div>

            {/* Status */}
            <div className="mb-4">
              <label className="block text-sm font-medium text-gray-700 mb-2">Status</label>
              <div className="flex gap-2">
                {[
                  { value: 'to_read', label: 'To Read' },
                  { value: 'reading', label: 'Reading' },
                  { value: 'read', label: 'Read' },
                ].map(s => (
                  <button
                    key={s.value}
                    onClick={() => setEditStatus(s.value)}
                    className={`flex-1 py-1.5 rounded-lg text-xs font-medium transition-all ${
                      editStatus === s.value ? 'bg-amber-700 text-white' : 'bg-gray-100 text-gray-600 hover:bg-amber-100'
                    }`}
                  >
                    {s.label}
                  </button>
                ))}
              </div>
            </div>

            {/* Progress — only for Reading */}
            {editStatus === 'reading' && (
              <div className="mb-4">
                <label className="block text-sm font-medium text-gray-700 mb-2">Current page</label>
                <div className="flex items-center gap-3">
                  <input
                    type="number"
                    min="0"
                    max={selectedBook.book.pages ?? 9999}
                    onChange={e => setEditProgress(Math.min(Number(e.target.value), selectedBook.book.pages ?? 9999))}
                    value={editProgress}
                    onClick={e => e.stopPropagation()}
                    className="w-28 border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-amber-300"
                  />
                  <span className="text-sm text-gray-500">of {selectedBook.book.pages ?? '?'} pages</span>
                </div>
                <div className="w-full bg-gray-100 rounded-full h-1.5 mt-2">
                  <div
                    className="bg-amber-500 h-1.5 rounded-full transition-all"
                    style={{ width: `${selectedBook.book.pages ? progressPercent(editProgress, selectedBook.book.pages) : 0}%` }}
                  />
                </div>
              </div>
            )}

            {/* Rating & Review — only for Read */}
            {editStatus === 'read' && (
              <>
                <div className="mb-4">
                  <label className="block text-sm font-medium text-gray-700 mb-2">Rating</label>
                  <div className="flex gap-2">
                    {[1, 2, 3, 4, 5].map(star => (
                      <button
                        key={star}
                        onClick={() => setEditRating(star === editRating ? 0 : star)}
                        className={`text-2xl transition-transform hover:scale-110 ${
                          star <= editRating ? 'opacity-100' : 'opacity-30'
                        }`}
                      >
                        ⭐
                      </button>
                    ))}
                  </div>
                </div>
                <div className="mb-4">
                  <label className="block text-sm font-medium text-gray-700 mb-2">Review</label>
                  <textarea
                    value={editReview}
                    onChange={e => setEditReview(e.target.value)}
                    onClick={e => e.stopPropagation()}
                    rows={3}
                    placeholder="Write your thoughts about this book..."
                    className="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-amber-300 resize-none"
                  />
                </div>
              </>
            )}

            <div className="flex gap-2 mt-4">
              <button
                onClick={saveEdit}
                className="flex-1 bg-amber-700 hover:bg-amber-800 text-white py-2.5 rounded-xl text-sm font-medium transition-colors"
              >
                Save
              </button>
              <button
                onClick={() => deleteBook(selectedBook.id)}
                className="px-4 py-2.5 bg-red-50 hover:bg-red-100 text-red-500 rounded-xl text-sm font-medium transition-colors"
              >
                Remove
              </button>
            </div>
          </div>
        </div>

      )}
      <NestieWidget />
    </div>
  );
};

export default LibraryPage;