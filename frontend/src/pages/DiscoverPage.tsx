import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
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
  isbn: string;
}

const DiscoverPage = () => {
  const [books, setBooks] = useState<Book[]>([]);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);
  const [addedBooks, setAddedBooks] = useState<number[]>([]);
  const [selectedBook, setSelectedBook] = useState<Book | null>(null);
  const [selectedStatus, setSelectedStatus] = useState<string>('to_read');
  const navigate = useNavigate();

  useEffect(() => {
    fetchBooks();
  }, []);

  const fetchBooks = async () => {
    try {
      const res = await API.get('/books/');
      setBooks(res.data);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = async (e: React.ChangeEvent<HTMLInputElement>) => {
    setSearch(e.target.value);
    if (e.target.value.length > 1) {
      const res = await API.get(`/books/search?q=${e.target.value}`);
      setBooks(res.data);
    } else if (e.target.value.length === 0) {
      fetchBooks();
    }
  };

  const openModal = (book: Book) => {
    setSelectedBook(book);
    setSelectedStatus('to_read');
  };

  const addToLibrary = async () => {
    if (!selectedBook) return;
    try {
      await API.post('/books/library', {
        book_id: selectedBook.id,
        status: selectedStatus
      });
      setAddedBooks(prev => [...prev, selectedBook.id]);
      setSelectedBook(null);
    } catch (err: any) {
      if (err.response?.data?.error === 'Cartea e deja în bibliotecă') {
        setAddedBooks(prev => [...prev, selectedBook.id]);
        setSelectedBook(null);
      }
    }
  };

  const filteredBooks = books.filter(b =>
    b.title.toLowerCase().includes(search.toLowerCase()) ||
    b.author.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="min-h-screen bg-amber-50">
      {/* Navbar */}
      <nav className="bg-white shadow-sm px-6 py-4 flex justify-between items-center">
        <h1
          className="text-2xl font-bold text-amber-800 cursor-pointer"
          onClick={() => navigate('/library')}
        >
          🪺 BookNest
        </h1>
        <button
          onClick={() => navigate('/library')}
          className="text-sm text-gray-500 hover:text-amber-700 transition-colors"
        >
          ← Back to library
        </button>
      </nav>

      <div className="max-w-5xl mx-auto px-6 py-8">
        <h2 className="text-2xl font-bold text-gray-800 mb-6">Discover books</h2>

        <input
          type="text"
          value={search}
          onChange={handleSearch}
          placeholder="Search by title or author..."
          className="w-full border border-gray-200 rounded-xl px-4 py-3 mb-6 focus:outline-none focus:ring-2 focus:ring-amber-300 bg-white"
        />

        {loading ? (
          <p className="text-center text-gray-400 py-12">Loading...</p>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {filteredBooks.map(book => (
              <div
                key={book.id}
                className="bg-white rounded-2xl shadow-sm p-4 flex gap-4 cursor-pointer hover:shadow-md transition-shadow"
                onClick={() => !addedBooks.includes(book.id) && openModal(book)}
              >
                <div className="w-16 h-24 flex-shrink-0">
                  {book.cover_url ? (
                    <img src={book.cover_url} alt={book.title} className="w-full h-full object-cover rounded-lg" />
                  ) : (
                    <div className="w-full h-full bg-amber-100 rounded-lg flex items-center justify-center text-2xl">📖</div>
                  )}
                </div>
                <div className="flex-1 min-w-0">
                  <h3 className="font-semibold text-gray-800 truncate">{book.title}</h3>
                  <p className="text-sm text-gray-500">{book.author} · {book.year}</p>
                  <p className="text-xs text-gray-400">{book.pages} pages</p>
                  <div className="flex flex-wrap gap-1 mt-1">
                    {book.genres.slice(0, 2).map(g => (
                      <span key={g} className="text-xs bg-amber-100 text-amber-700 px-2 py-0.5 rounded-full">{g}</span>
                    ))}
                  </div>
                  {addedBooks.includes(book.id) ? (
                    <p className="text-xs text-green-500 mt-2 font-medium">✓ Added to library</p>
                  ) : (
                    <p className="text-xs text-amber-600 mt-2">Click to add →</p>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Modal */}
      {selectedBook && (
        <div className="fixed inset-0 bg-black bg-opacity-40 flex items-center justify-center z-50 px-4">
          <div className="bg-white rounded-2xl p-6 w-full max-w-md shadow-xl">
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

            <p className="text-sm text-gray-600 mb-4 line-clamp-3">{selectedBook.description}</p>

            <label className="block text-sm font-medium text-gray-700 mb-2">Add to:</label>
            <div className="flex gap-2 mb-6">
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
              onClick={addToLibrary}
              className="w-full bg-amber-700 hover:bg-amber-800 text-white py-2.5 rounded-xl text-sm font-medium transition-colors"
            >
              Add to library
            </button>
          </div>
        </div>
      )}
      <NestieWidget />
    </div>
  );
};

export default DiscoverPage;