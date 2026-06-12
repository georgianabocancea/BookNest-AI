import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import API from '../services/api';
import Header from '../components/Header';

interface ReviewStats {
  avg_rating: number | null;
  total_ratings: number;
  total_reviews: number;
  distribution: Record<string, number>;
}

interface Review {
  username: string;
  rating: number | null;
  review: string;
  date: string | null;
}

interface BookInfo {
  id: number;
  title: string;
  author: string;
  cover_url: string | null;
  year: number;
  pages: number;
}

const BookReviewsPage = () => {
  const { bookId } = useParams();
  const navigate = useNavigate();
  const [book, setBook] = useState<BookInfo | null>(null);
  const [stats, setStats] = useState<ReviewStats | null>(null);
  const [reviews, setReviews] = useState<Review[]>([]);
  const [loading, setLoading] = useState(true);
  const [ratingFilter, setRatingFilter] = useState<string>('');
  const [sort, setSort] = useState('newest');

  useEffect(() => {
    fetchReviews();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [bookId, ratingFilter, sort]);

  const fetchReviews = async () => {
    try {
      const params = new URLSearchParams();
      if (ratingFilter) params.set('rating', ratingFilter);
      params.set('sort', sort);
      const res = await API.get(`/books/${bookId}/reviews?${params.toString()}`);
      setBook(res.data.book);
      setStats(res.data.stats);
      setReviews(res.data.reviews);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const maxCount = stats
    ? Math.max(...Object.values(stats.distribution), 1)
    : 1;

  return (
    <div className="min-h-screen bg-amber-50">
      <Header />

      <div className="max-w-3xl mx-auto px-6 py-8">

        {/* Book header */}
        {book && (
          <div className="flex gap-4 mb-8">
            {book.cover_url ? (
              <img src={book.cover_url} alt={book.title} className="w-20 h-28 object-cover rounded-xl shadow" />
            ) : (
              <div className="w-20 h-28 bg-amber-100 rounded-xl flex items-center justify-center text-3xl">📖</div>
            )}
            <div>
              <h1 className="text-2xl font-bold text-gray-800">{book.title}</h1>
              <p className="text-gray-500">{book.author} · {book.year}</p>
              <p className="text-sm text-gray-400">{book.pages} pages</p>
              <button
                onClick={() => navigate(-1)}
                className="text-sm text-amber-700 hover:underline mt-2"
              >
                ← Back
              </button>
            </div>
          </div>
        )}

        {/* Stats */}
        {stats && (
          <div className="bg-white rounded-2xl shadow-sm p-6 mb-6">
            <h2 className="text-lg font-bold text-gray-800 mb-4">
              {stats.total_reviews} Community Reviews
            </h2>

            {stats.avg_rating ? (
              <div className="flex items-center gap-3 mb-6">
                <div className="flex gap-1">
                  {[1, 2, 3, 4, 5].map(star => (
                    <span
                      key={star}
                      className={`text-2xl ${star <= Math.round(stats.avg_rating!) ? 'opacity-100' : 'opacity-20'}`}
                    >
                      ⭐
                    </span>
                  ))}
                </div>
                <span className="text-xl font-bold text-gray-800">{stats.avg_rating}</span>
                <span className="text-gray-400 text-sm">({stats.total_ratings} ratings)</span>
              </div>
            ) : (
              <p className="text-gray-400 text-sm mb-6">No ratings yet</p>
            )}

            {/* Distribution bars */}
            <div className="space-y-2">
              {[5, 4, 3, 2, 1].map(star => {
                const count = stats.distribution[star] || 0;
                const percent = maxCount > 0 ? (count / maxCount) * 100 : 0;
                return (
                  <button
                    key={star}
                    onClick={() => setRatingFilter(ratingFilter === String(star) ? '' : String(star))}
                    className={`w-full flex items-center gap-3 group ${ratingFilter === String(star) ? 'opacity-100' : 'opacity-80 hover:opacity-100'}`}
                  >
                    <span className="text-sm text-gray-500 w-12 text-right">{star} star</span>
                    <div className="flex-1 bg-gray-100 rounded-full h-3">
                      <div
                        className={`h-3 rounded-full transition-all ${ratingFilter === String(star) ? 'bg-amber-600' : 'bg-amber-400'}`}
                        style={{ width: `${percent}%` }}
                      />
                    </div>
                    <span className="text-xs text-gray-400 w-6">{count}</span>
                  </button>
                );
              })}
            </div>

            {ratingFilter && (
              <button
                onClick={() => setRatingFilter('')}
                className="text-xs text-amber-700 hover:underline mt-3"
              >
                Clear filter
              </button>
            )}
          </div>
        )}

        {/* Sort + Reviews */}
        <div className="flex justify-between items-center mb-4">
          <h3 className="font-semibold text-gray-700">
            {ratingFilter ? `${ratingFilter}-star reviews` : 'All reviews'}
            {reviews.length > 0 && <span className="text-gray-400 font-normal ml-1">({reviews.length})</span>}
          </h3>
          <select
            value={sort}
            onChange={e => setSort(e.target.value)}
            className="text-sm border border-gray-200 rounded-xl px-3 py-1.5 focus:outline-none focus:ring-2 focus:ring-amber-300 bg-white"
          >
            <option value="newest">Newest first</option>
            <option value="oldest">Oldest first</option>
          </select>
        </div>

        {loading ? (
          <p className="text-center text-gray-400 py-12">Loading...</p>
        ) : reviews.length === 0 ? (
          <div className="text-center py-12 text-gray-400">
            <p className="text-4xl mb-3">📝</p>
            <p>{ratingFilter ? `No ${ratingFilter}-star reviews yet.` : 'No reviews yet. Be the first!'}</p>
          </div>
        ) : (
          <div className="space-y-4">
            {reviews.map((r, i) => (
              <div key={i} className="bg-white rounded-2xl shadow-sm p-5">
                <div className="flex justify-between items-start mb-2">
                  <div>
                    <span className="font-semibold text-gray-800">{r.username}</span>
                    {r.rating && (
                      <span className="ml-2 text-sm">{'⭐'.repeat(r.rating)}</span>
                    )}
                  </div>
                  <span className="text-xs text-gray-400">{r.date}</span>
                </div>
                <p className="text-sm text-gray-600 leading-relaxed">{r.review}</p>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default BookReviewsPage;