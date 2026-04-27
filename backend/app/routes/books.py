from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models import Book, Genre, UserBook
from sqlalchemy import func, text
from sqlalchemy.exc import IntegrityError

books_bp = Blueprint('books', __name__)


def _patch_legacy_progress_constraint():
    if db.engine.dialect.name != 'postgresql':
        return

    with db.engine.begin() as conn:
        conn.execute(text(
            "ALTER TABLE user_books ALTER COLUMN progress TYPE INTEGER USING progress::INTEGER;"
        ))
        conn.execute(text("""
            DO $$
            DECLARE
                constraint_name text;
            BEGIN
                FOR constraint_name IN
                    SELECT c.conname
                    FROM pg_constraint c
                    JOIN pg_class t ON t.oid = c.conrelid
                    WHERE t.relname = 'user_books'
                      AND c.contype = 'c'
                      AND pg_get_constraintdef(c.oid) ILIKE '%progress%'
                      AND pg_get_constraintdef(c.oid) ILIKE '%100%'
                LOOP
                    EXECUTE format('ALTER TABLE user_books DROP CONSTRAINT %I', constraint_name);
                END LOOP;
            END $$;
        """))
        conn.execute(text("""
            DO $$
            BEGIN
                IF NOT EXISTS (
                    SELECT 1
                    FROM pg_constraint c
                    JOIN pg_class t ON t.oid = c.conrelid
                    WHERE t.relname = 'user_books'
                      AND c.conname = 'user_books_progress_non_negative_check'
                ) THEN
                    ALTER TABLE user_books
                    ADD CONSTRAINT user_books_progress_non_negative_check CHECK (progress >= 0);
                END IF;
            END $$;
        """))

@books_bp.route('/', methods=['GET'])
def get_books():
    genre = request.args.get('genre')
    author = request.args.get('author')
    sort = request.args.get('sort', 'az')
    q = request.args.get('q')

    query = Book.query

    if q:
        query = query.filter(
            Book.title.ilike(f'%{q}%') | Book.author.ilike(f'%{q}%')
        )
    if author:
        query = query.filter(Book.author.ilike(f'%{author}%'))
    if genre:
        query = query.join(Book.genres).filter(Genre.name.ilike(f'%{genre}%'))

    if sort == 'top_rated':
        query = query.outerjoin(UserBook).group_by(Book.id).order_by(
            func.coalesce(func.avg(UserBook.rating), 0).desc()
        )
    elif sort == 'newest':
        query = query.order_by(Book.year.desc())
    elif sort == 'oldest':
        query = query.order_by(Book.year.asc())
    else:
        query = query.order_by(Book.title.asc())

    books = query.all()
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
    user_books = UserBook.query.filter_by(user_id=int(user_id)).all()
    return jsonify([ub.to_dict() for ub in user_books])

@books_bp.route('/library', methods=['POST'])
@jwt_required()
def add_to_library():
    user_id = get_jwt_identity()
    data = request.get_json()

    existing = UserBook.query.filter_by(
        user_id=int(user_id), book_id=data['book_id']
    ).first()
    if existing:
        return jsonify({'error': 'Cartea e deja în bibliotecă'}), 409

    ub = UserBook(
        user_id=int(user_id),
        book_id=data['book_id'],
        status=data.get('status', 'to_read')
    )
    db.session.add(ub)
    db.session.commit()
    return jsonify(ub.to_dict()), 201

@books_bp.route('/library/<int:ub_id>', methods=['PUT'])
@jwt_required()
def update_library(ub_id):
    user_id = get_jwt_identity()
    ub = UserBook.query.filter_by(id=ub_id, user_id=int(user_id)).first_or_404()
    data = request.get_json()

    if 'status' in data:
        ub.status = data['status']
    if 'rating' in data:
        ub.rating = data['rating']
    if 'review' in data:
        ub.review = data['review']
    if 'progress' in data:
        try:
            progress = int(data['progress'])
        except (TypeError, ValueError):
            return jsonify({'error': 'Progress must be a valid number of pages'}), 400

        if progress < 0:
            return jsonify({'error': 'Progress cannot be negative'}), 400

        max_pages = ub.book.pages
        if max_pages is not None and progress > max_pages:
            return jsonify({'error': f'Progress cannot be greater than total pages ({max_pages})'}), 400

        ub.progress = progress

    try:
        db.session.commit()
    except IntegrityError as err:
        db.session.rollback()
        error_text = str(getattr(err, 'orig', err)).lower()
        if 'progress' in error_text and ('100' in error_text or 'check' in error_text):
            try:
                _patch_legacy_progress_constraint()
                db.session.add(ub)
                db.session.commit()
            except Exception:
                db.session.rollback()
                return jsonify({'error': 'Could not update reading progress right now'}), 500
        else:
            return jsonify({'error': 'Could not update reading progress right now'}), 500

    return jsonify(ub.to_dict())

@books_bp.route('/library/<int:ub_id>', methods=['DELETE'])
@jwt_required()
def remove_from_library(ub_id):
    user_id = get_jwt_identity()
    ub = UserBook.query.filter_by(id=ub_id, user_id=int(user_id)).first_or_404()
    db.session.delete(ub)
    db.session.commit()
    return jsonify({'message': 'Carte ștearsă din bibliotecă'})