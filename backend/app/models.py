from app import db
from datetime import datetime

class User(db.Model):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(255), unique=True, nullable=False)
    username = db.Column(db.String(100), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    avatar_url = db.Column(db.Text)
    bio = db.Column(db.Text)
    daily_notification = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    user_books = db.relationship('UserBook', backref='user', lazy=True)

class Book(db.Model):
    __tablename__ = 'books'

    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(500), nullable=False)
    author = db.Column(db.String(255), nullable=False)
    year = db.Column(db.Integer)
    description = db.Column(db.Text)
    cover_url = db.Column(db.Text)
    isbn = db.Column(db.String(20))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    pages = db.Column(db.Integer)
    genres = db.relationship('Genre', secondary='book_genres', backref='books', lazy=True)

    def to_dict(self):
        return {
            'id': self.id,
            'title': self.title,
            'author': self.author,
            'year': self.year,
            'description': self.description,
            'cover_url': self.cover_url,
            'isbn': self.isbn,
            'pages': self.pages,
            'genres': [g.name for g in self.genres]
        }

class Genre(db.Model):
    __tablename__ = 'genres'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), unique=True, nullable=False)

book_genres = db.Table('book_genres',
    db.Column('book_id', db.Integer, db.ForeignKey('books.id'), primary_key=True),
    db.Column('genre_id', db.Integer, db.ForeignKey('genres.id'), primary_key=True)
)

class UserBook(db.Model):
    __tablename__ = 'user_books'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    book_id = db.Column(db.Integer, db.ForeignKey('books.id'), nullable=False)
    status = db.Column(db.String(20), nullable=False)
    rating = db.Column(db.SmallInteger)
    review = db.Column(db.Text)
    progress = db.Column(db.SmallInteger, default=0)
    start_date = db.Column(db.Date)
    finish_date = db.Column(db.Date)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    book = db.relationship('Book', backref='user_books', lazy=True)

    def to_dict(self):
        return {
            'id': self.id,
            'book': self.book.to_dict(),
            'status': self.status,
            'rating': self.rating,
            'review': self.review,
            'progress': self.progress,
            'start_date': str(self.start_date) if self.start_date else None,
            'finish_date': str(self.finish_date) if self.finish_date else None,
        }