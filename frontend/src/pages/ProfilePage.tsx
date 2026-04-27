import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import API from '../services/api';
import Header from '../components/Header';

interface Stats {
  read: number;
  reading: number;
  to_read: number;
  total_pages: number;
  avg_rating: number | null;
  fav_genre: string | null;
  fav_author: string | null;
}

interface Review {
  book_title: string;
  book_cover: string | null;
  rating: number | null;
  review: string;
}

interface Profile {
  username: string;
  email: string;
  bio: string | null;
  stats: Stats;
  reviews: Review[];
}

const ProfilePage = () => {
  const { login } = useAuth();
  const navigate = useNavigate();
  const [profile, setProfile] = useState<Profile | null>(null);
  const [loading, setLoading] = useState(true);
  const [editing, setEditing] = useState(false);
  const [editUsername, setEditUsername] = useState('');
  const [editBio, setEditBio] = useState('');
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  useEffect(() => {
    fetchProfile();
  }, []);

  const fetchProfile = async () => {
    try {
      const res = await API.get('/profile/');
      setProfile(res.data);
      setEditUsername(res.data.username);
      setEditBio(res.data.bio || '');
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const saveProfile = async () => {
    setError('');
    setSuccess('');
    try {
      const res = await API.put('/profile/', {
        username: editUsername,
        bio: editBio,
      });
      setSuccess('Profile updated!');
      setEditing(false);
      login(localStorage.getItem('token')!, res.data.username);
      fetchProfile();
    } catch (err: any) {
      setError(err.response?.data?.error || 'Something went wrong.');
    }
  };

  if (loading) return <div className="min-h-screen bg-amber-50 flex items-center justify-center"><p className="text-gray-400">Loading...</p></div>;
  if (!profile) return null;

  const { stats, reviews } = profile;

  return (
    <div className="min-h-screen bg-amber-50">
      <Header />

      <div className="max-w-3xl mx-auto px-6 py-8">

        {/* Profile header */}
        <div className="bg-white rounded-2xl shadow-sm p-6 mb-6">
          <div className="flex justify-between items-start">
            <div className="flex items-center gap-4">
              <div className="w-16 h-16 bg-amber-100 rounded-full flex items-center justify-center text-3xl">
                🪺
              </div>
              <div>
                {editing ? (
                  <input
                    type="text"
                    value={editUsername}
                    onChange={e => setEditUsername(e.target.value)}
                    onClick={e => e.stopPropagation()}
                    className="text-xl font-bold border border-gray-200 rounded-xl px-3 py-1 focus:outline-none focus:ring-2 focus:ring-amber-300"
                  />
                ) : (
                  <h2 className="text-xl font-bold text-gray-800">{profile.username}</h2>
                )}
                <p className="text-sm text-gray-400">{profile.email}</p>
              </div>
            </div>
            <button
              onClick={() => editing ? saveProfile() : setEditing(true)}
              className="text-sm bg-amber-700 hover:bg-amber-800 text-white px-4 py-2 rounded-xl transition-colors"
            >
              {editing ? 'Save' : 'Edit profile'}
            </button>
          </div>

          {/* Bio */}
          <div className="mt-4">
            {editing ? (
              <textarea
                value={editBio}
                onChange={e => setEditBio(e.target.value)}
                onClick={e => e.stopPropagation()}
                rows={3}
                placeholder="Write something about yourself..."
                className="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-amber-300 resize-none"
              />
            ) : (
              <p className="text-sm text-gray-600">{profile.bio || 'No bio yet. Click Edit profile to add one!'}</p>
            )}
          </div>

          {error && <p className="text-red-500 text-sm mt-2">{error}</p>}
          {success && <p className="text-green-500 text-sm mt-2">{success}</p>}
        </div>

        {/* Stats */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
          {[
            { label: 'Books read', value: stats.read, emoji: '✅' },
            { label: 'Pages read', value: stats.total_pages.toLocaleString(), emoji: '📄' },
            { label: 'Avg rating', value: stats.avg_rating ? `${stats.avg_rating} ⭐` : '—', emoji: '⭐' },
            { label: 'Reading now', value: stats.reading, emoji: '📖' },
          ].map(stat => (
            <div key={stat.label} className="bg-white rounded-2xl shadow-sm p-4 text-center">
              <p className="text-2xl mb-1">{stat.emoji}</p>
              <p className="text-2xl font-bold text-amber-800">{stat.value}</p>
              <p className="text-xs text-gray-400 mt-1">{stat.label}</p>
            </div>
          ))}
        </div>

        {/* Favourites */}
        {(stats.fav_genre || stats.fav_author) && (
          <div className="grid grid-cols-2 gap-4 mb-6">
            {stats.fav_genre && (
              <button
                onClick={() => navigate(`/discover?genre=${encodeURIComponent(stats.fav_genre!)}`)}
                className="bg-white rounded-2xl shadow-sm p-4 text-left hover:shadow-md transition-shadow"
              >
                <p className="text-xs text-gray-400 mb-1">Favourite genre</p>
                <p className="font-semibold text-amber-800">{stats.fav_genre} →</p>
              </button>
            )}
            {stats.fav_author && (
              <button
                onClick={() => navigate(`/discover?author=${encodeURIComponent(stats.fav_author!)}`)}
                className="bg-white rounded-2xl shadow-sm p-4 text-left hover:shadow-md transition-shadow"
              >
                <p className="text-xs text-gray-400 mb-1">Favourite author</p>
                <p className="font-semibold text-amber-800">{stats.fav_author} →</p>
              </button>
            )}
          </div>
        )}

        {/* Reading list summary */}
        <div className="bg-white rounded-2xl shadow-sm p-4 mb-6">
          <div className="flex justify-around text-center">
            {[
              { status: 'to_read', label: 'To Read', value: stats.to_read },
              { status: 'reading', label: 'Reading', value: stats.reading },
              { status: 'read', label: 'Read', value: stats.read },
            ].map((item, i, arr) => (
              <React.Fragment key={item.status}>
                <button
                  onClick={() => navigate(`/library?status=${item.status}`)}
                  className="text-center hover:opacity-70 transition-opacity"
                >
                  <p className="text-xl font-bold text-amber-800">{item.value}</p>
                  <p className="text-xs text-gray-400">{item.label}</p>
                </button>
                {i < arr.length - 1 && <div className="w-px bg-gray-100" />}
              </React.Fragment>
            ))}
          </div>
        </div>

        {/* Reviews */}
        {reviews.length > 0 && (
          <div>
            <h3 className="text-lg font-bold text-gray-800 mb-4">My Reviews</h3>
            <div className="space-y-4">
              {reviews.map((r, i) => (
                <button
                  key={i}
                  onClick={() => navigate(`/library?status=read&book=${encodeURIComponent(r.book_title)}`)}
                  className="w-full bg-white rounded-2xl shadow-sm p-4 flex gap-4 text-left hover:shadow-md transition-shadow"
                >
                  {r.book_cover ? (
                    <img src={r.book_cover} alt={r.book_title} className="w-12 h-16 object-cover rounded-lg flex-shrink-0" />
                  ) : (
                    <div className="w-12 h-16 bg-amber-100 rounded-lg flex items-center justify-center flex-shrink-0">📖</div>
                  )}
                  <div>
                    <h4 className="font-semibold text-gray-800">{r.book_title}</h4>
                    {r.rating && <p className="text-sm">{'⭐'.repeat(r.rating)}</p>}
                    <p className="text-sm text-gray-600 mt-1">{r.review}</p>
                  </div>
                </button>
              ))}
            </div>
          </div>
        )}
      </div>

    </div>
  );
};

export default ProfilePage;