from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models import User, UserBook, Book
from collections import Counter
from werkzeug.security import generate_password_hash

profile_bp = Blueprint('profile', __name__)

@profile_bp.route('/', methods=['GET'])
@jwt_required()
def get_profile():
    user_id = int(get_jwt_identity())
    user = User.query.get_or_404(user_id)
    user_books = UserBook.query.filter_by(user_id=user_id).all()

    read_books = [ub for ub in user_books if ub.status == 'read']
    reading_books = [ub for ub in user_books if ub.status == 'reading']
    to_read_books = [ub for ub in user_books if ub.status == 'to_read']

    # Total pages read
    total_pages = sum(
        ub.book.pages for ub in read_books if ub.book.pages
    )

    # Average rating
    ratings = [ub.rating for ub in read_books if ub.rating]
    avg_rating = round(sum(ratings) / len(ratings), 1) if ratings else None

    # Favourite genre
    genres = []
    for ub in read_books:
        genres.extend([g.name for g in ub.book.genres])
    fav_genre = Counter(genres).most_common(1)[0][0] if genres else None

    # Favourite author
    authors = [ub.book.author for ub in read_books]
    fav_author = Counter(authors).most_common(1)[0][0] if authors else None

    # Reviews
    reviews = [
        {
            'book_title': ub.book.title,
            'book_cover': ub.book.cover_url,
            'rating': ub.rating,
            'review': ub.review,
        }
        for ub in read_books if ub.review
    ]

    return jsonify({
        'username': user.username,
        'email': user.email,
        'bio': user.bio,
        'stats': {
            'read': len(read_books),
            'reading': len(reading_books),
            'to_read': len(to_read_books),
            'total_pages': total_pages,
            'avg_rating': avg_rating,
            'fav_genre': fav_genre,
            'fav_author': fav_author,
        },
        'reviews': reviews
    })

@profile_bp.route('/', methods=['PUT'])
@jwt_required()
def update_profile():
    user_id = int(get_jwt_identity())
    user = User.query.get_or_404(user_id)
    data = request.get_json()

    if 'username' in data and data['username']:
        existing = User.query.filter_by(username=data['username']).first()
        if existing and existing.id != user_id:
            return jsonify({'error': 'Username already taken'}), 409
        user.username = data['username']

    if 'bio' in data:
        user.bio = data['bio']

    db.session.commit()
    return jsonify({'message': 'Profile updated', 'username': user.username})