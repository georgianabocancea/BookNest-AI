from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models import Book, Genre, UserBook

books_bp = Blueprint('books', __name__)

@books_bp.route('/', methods=['GET'])
def get_books():
    books = Book.query.all()
    return jsonify([b.to_dict() for b in books])

@books_bp.route('/<int:book_id>', methods=['GET'])
def get_book(book_id):
    book = Book.query.get_or_404(book_id)
    return jsonify(book.to_dict())

@books_bp.route('/search', methods=['GET'])
def search_books():
    q = request.args.get('q', '')
    books = Book.query.filter(
        Book.title.ilike(f'%{q}%') | Book.author.ilike(f'%{q}%')
    ).all()
    return jsonify([b.to_dict() for b in books])

@books_bp.route('/library', methods=['GET'])
@jwt_required()
def get_library():
    user_id = get_jwt_identity()
    user_books = UserBook.query.filter_by(user_id=user_id).all()

    return jsonify([{
        "id": ub.id,
        "status": ub.status,
        "rating": ub.rating,
        "review": ub.review,
        "progress": ub.progress,
        "book": {
            "id": ub.book.id,
            "title": ub.book.title,
            "author": ub.book.author,
            "year": ub.book.year,
            "description": ub.book.description,
            "cover_url": ub.book.cover_url,
            "genres": [g.name for g in ub.book.genres] if ub.book.genres else []
        }
    } for ub in user_books])

@books_bp.route('/library', methods=['POST'])
@jwt_required()
def add_to_library():
    user_id = get_jwt_identity()
    data = request.get_json()
    
    existing = UserBook.query.filter_by(
        user_id=user_id, book_id=data['book_id']
    ).first()
    if existing:
        return jsonify({'error': 'Book is already in the library'}), 409
    
    ub = UserBook(
        user_id=user_id,
        book_id=data['book_id'],
        status=data.get('status', 'de_citit')
    )
    db.session.add(ub)
    db.session.commit()
    return jsonify(ub.to_dict()), 201

@books_bp.route('/library/<int:ub_id>', methods=['PUT'])
@jwt_required()
def update_library(ub_id):
    user_id = get_jwt_identity()
    ub = UserBook.query.filter_by(id=ub_id, user_id=user_id).first_or_404()
    data = request.get_json()
    
    if 'status' in data:
        ub.status = data['status']
    if 'rating' in data:
        ub.rating = data['rating']
    if 'review' in data:
        ub.review = data['review']
    if 'progress' in data:
        ub.progress = data['progress']
    
    db.session.commit()
    return jsonify(ub.to_dict())

@books_bp.route('/library/<int:ub_id>', methods=['DELETE'])
@jwt_required()
def remove_from_library(ub_id):
    user_id = get_jwt_identity()
    ub = UserBook.query.filter_by(id=ub_id, user_id=user_id).first_or_404()
    db.session.delete(ub)
    db.session.commit()
    return jsonify({'message': 'Book removed from library'})