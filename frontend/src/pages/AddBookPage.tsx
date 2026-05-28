import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import API from '../services/api';
import Header from '../components/Header';

interface BookPreview {
  is_valid: boolean;
  reason: string;
  title: string;
  author: string;
  year: number | null;
  pages: number | null;
  description: string;
  genres: string[];
  isbn: string | null;
  cover_url: string | null;
}

const AddBookPage = () => {
  const navigate = useNavigate();
  const [title, setTitle] = useState('');
  const [author, setAuthor] = useState('');
  const [year, setYear] = useState('');
  const [loading, setLoading] = useState(false);
  const [preview, setPreview] = useState<BookPreview | null>(null);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [confirming, setConfirming] = useState(false);
  const [communityBooks, setCommunityBooks] = useState<any[]>([]);

  useEffect(() => {
    fetchCommunityBooks();
  }, []);

  const fetchCommunityBooks = async () => {
    try {
      const res = await API.get('/books/community');
      setCommunityBooks(res.data);
    } catch (err) {
      console.error(err);
    }
  };

  const verifyBook = async () => {
    if (!title.trim() || !author.trim()) {
      setError('Please enter both title and author.');
      return;
    }
    setLoading(true);
    setError('');
    setPreview(null);

    try {
      const res = await API.post('/add/verify', { title, author, year });
      setPreview(res.data);
    } catch (err: any) {
      setError(err.response?.data?.error || 'Something went wrong. Try again.');
    } finally {
      setLoading(false);
    }
  };

  const confirmBook = async () => {
    if (!preview) return;
    setConfirming(true);
    setError('');

    try {
      await API.post('/add/confirm', preview);
      setSuccess(`"${preview.title}" has been added to BookNest!`);
      setPreview(null);
      setTitle('');
      setAuthor('');
      setYear('');
      fetchCommunityBooks();
    } catch (err: any) {
      if (err.response?.data?.error?.includes('already exists')) {
        setError('This book already exists in the database.');
      } else {
        setError(err.response?.data?.error || 'Something went wrong.');
      }
    } finally {
      setConfirming(false);
    }
  };

  return (
    <div className="min-h-screen bg-amber-50">
      <Header />

      <div className="max-w-2xl mx-auto px-6 py-8">
        <div className="mb-6">
          <h2 className="text-2xl font-bold text-gray-800">Add a new book</h2>
          <p className="text-sm text-gray-500 mt-1">
            Enter the title and author — Nestie will verify and fill in the rest automatically.
          </p>
        </div>

        {/* Form */}
        <div className="bg-white rounded-2xl shadow-sm p-6 mb-6">
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Title *</label>
              <input
                type="text"
                value={title}
                onChange={e => setTitle(e.target.value)}
                placeholder="e.g. The Great Gatsby"
                className="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-amber-300"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Author *</label>
              <input
                type="text"
                value={author}
                onChange={e => setAuthor(e.target.value)}
                placeholder="e.g. F. Scott Fitzgerald"
                className="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-amber-300"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Year <span className="text-gray-400">(optional)</span>
              </label>
              <input
                type="number"
                value={year}
                onChange={e => setYear(e.target.value)}
                placeholder="e.g. 1925"
                className="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-amber-300"
              />
            </div>

            {error && <p className="text-red-500 text-sm">{error}</p>}

            {success && (
              <div className="bg-green-50 border border-green-200 rounded-xl p-4">
                <p className="text-green-700 text-sm font-medium">{success}</p>
                <div className="flex gap-2 mt-3">
                  <button
                    onClick={() => navigate('/discover')}
                    className="text-sm bg-green-600 hover:bg-green-700 text-white px-4 py-1.5 rounded-xl transition-colors"
                  >
                    Go to Discover
                  </button>
                  <button
                    onClick={() => { setSuccess(''); setError(''); }}
                    className="text-sm bg-gray-100 hover:bg-gray-200 text-gray-600 px-4 py-1.5 rounded-xl transition-colors"
                  >
                    Add another
                  </button>
                </div>
              </div>
            )}

            {!success && (
              <button
                onClick={verifyBook}
                disabled={loading}
                className="w-full bg-amber-700 hover:bg-amber-800 disabled:opacity-50 text-white py-2.5 rounded-xl text-sm font-medium transition-colors"
              >
                {loading ? '🪺 Nestie is verifying...' : 'Verify with Nestie'}
              </button>
            )}
          </div>
        </div>

        {/* Preview */}
        {preview && (
          <div className={`bg-white rounded-2xl shadow-sm p-6 mb-6 border-2 ${preview.is_valid ? 'border-green-200' : 'border-red-200'}`}>
            {!preview.is_valid ? (
              <div>
                <p className="text-red-500 font-medium mb-2">❌ Book not verified</p>
                <p className="text-sm text-gray-600">{preview.reason}</p>
                <button
                  onClick={() => setPreview(null)}
                  className="mt-4 text-sm text-amber-700 hover:underline"
                >
                  Try again
                </button>
              </div>
            ) : (
              <div>
                <p className="text-green-600 font-medium mb-4">✅ Book verified by Nestie</p>
                <div className="flex gap-4 mb-4">
                  {preview.cover_url ? (
                    <img
                      src={preview.cover_url}
                      alt={preview.title}
                      className="w-20 h-28 object-cover rounded-lg flex-shrink-0 shadow"
                    />
                  ) : (
                    <div className="w-20 h-28 bg-amber-100 rounded-lg flex items-center justify-center flex-shrink-0 text-3xl">📖</div>
                  )}
                  <div className="flex-1">
                    <h3 className="font-bold text-gray-800 text-lg">{preview.title}</h3>
                    <p className="text-gray-500 text-sm">{preview.author}</p>
                    {preview.year && <p className="text-gray-400 text-xs">{preview.year}</p>}
                    {preview.pages && <p className="text-gray-400 text-xs">{preview.pages} pages</p>}
                    {preview.isbn && <p className="text-gray-400 text-xs">ISBN: {preview.isbn}</p>}
                    <div className="flex flex-wrap gap-1 mt-2">
                      {preview.genres.map(g => (
                        <span key={g} className="text-xs bg-amber-100 text-amber-700 px-2 py-0.5 rounded-full">{g}</span>
                      ))}
                    </div>
                  </div>
                </div>
                <p className="text-sm text-gray-600 mb-6">{preview.description}</p>
                <div className="flex gap-2">
                  <button
                    onClick={confirmBook}
                    disabled={confirming}
                    className="flex-1 bg-amber-700 hover:bg-amber-800 disabled:opacity-50 text-white py-2.5 rounded-xl text-sm font-medium transition-colors"
                  >
                    {confirming ? 'Adding...' : 'Add to BookNest'}
                  </button>
                  <button
                    onClick={() => setPreview(null)}
                    className="px-4 py-2.5 bg-gray-100 hover:bg-gray-200 text-gray-600 rounded-xl text-sm font-medium transition-colors"
                  >
                    Cancel
                  </button>
                </div>
              </div>
            )}
          </div>
        )}

        {/* Community books */}
        {communityBooks.length > 0 && (
          <div className="mt-4">
            <h3 className="text-lg font-bold text-gray-800 mb-4">
              📚 Recently added by the community
            </h3>
            <div className="space-y-3">
              {communityBooks.map(book => (
                <div key={book.id} className="bg-white rounded-2xl shadow-sm p-4 flex gap-4">
                  {book.cover_url ? (
                    <img src={book.cover_url} alt={book.title} className="w-12 h-16 object-cover rounded-lg flex-shrink-0" />
                  ) : (
                    <div className="w-12 h-16 bg-amber-100 rounded-lg flex items-center justify-center flex-shrink-0 text-2xl">📖</div>
                  )}
                  <div className="flex-1 min-w-0">
                    <h4 className="font-semibold text-gray-800 truncate">{book.title}</h4>
                    <p className="text-sm text-gray-500">{book.author}</p>
                    <div className="flex flex-wrap gap-1 mt-1">
                      {book.genres.slice(0, 2).map((g: string) => (
                        <span key={g} className="text-xs bg-amber-100 text-amber-700 px-2 py-0.5 rounded-full">{g}</span>
                      ))}
                    </div>
                  </div>
                  <div className="text-right flex-shrink-0">
                    <p className="text-xs text-gray-400">Added by</p>
                    <p className="text-xs font-medium text-amber-700">{book.added_by}</p>
                    <p className="text-xs text-gray-400 mt-1">{book.added_at}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

      </div>
    </div>
  );
};

export default AddBookPage;