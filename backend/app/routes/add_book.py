from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models import Book, Genre
from dotenv import load_dotenv
from groq import Groq
import os
import requests
import json

load_dotenv()
add_book_bp = Blueprint('add_book', __name__)
client = Groq(api_key=os.getenv('OPENAI_API_KEY'))

HEADERS = {'User-Agent': 'BookNest/1.0 (contact@booknest.app)'}

def fetch_cover(title, author, isbn=None):
    try:
        # Try Open Library with ISBN first
        if isbn:
            url = f"https://covers.openlibrary.org/b/isbn/{isbn}-L.jpg?default=false"
            r = requests.get(url, timeout=5, headers=HEADERS)
            print(f"ISBN cover status: {r.status_code}, size: {len(r.content)}")
            if r.status_code == 200 and len(r.content) > 1000:
                return url

        # Try Open Library search
        search_url = f"https://openlibrary.org/search.json?title={requests.utils.quote(title)}&author={requests.utils.quote(author)}&limit=3"
        r = requests.get(search_url, timeout=8, headers=HEADERS)
        print(f"Open Library search status: {r.status_code}")
        if r.status_code == 200:
            data = r.json()
            docs = data.get('docs', [])
            print(f"Open Library docs found: {len(docs)}")
            for doc in docs:
                cover_id = doc.get('cover_i')
                print(f"Cover ID: {cover_id}")
                if cover_id:
                    return f"https://covers.openlibrary.org/b/id/{cover_id}-L.jpg"

        # Try Google Books
        import time
        time.sleep(1)
        query = f"{title} {author}"
        google_url = f"https://www.googleapis.com/books/v1/volumes?q={requests.utils.quote(query)}&maxResults=1"
        r = requests.get(google_url, timeout=8, headers=HEADERS)
        print(f"Google Books status: {r.status_code}")
        if r.status_code == 200:
            data = r.json()
            items = data.get('items', [])
            print(f"Google Books items: {len(items)}")
            if items:
                image_links = items[0].get('volumeInfo', {}).get('imageLinks', {})
                print(f"Image links: {image_links}")
                cover = image_links.get('extraLarge') or image_links.get('large') or image_links.get('thumbnail')
                if cover:
                    return cover.replace('http://', 'https://')

    except Exception as e:
        print(f"Cover fetch error: {e}")
    return None

@add_book_bp.route('/verify', methods=['POST'])
@jwt_required()
def verify_book():
    data = request.get_json()
    title = data.get('title', '').strip()
    author = data.get('author', '').strip()
    year = data.get('year', '')

    if not title or not author:
        return jsonify({'error': 'Title and author are required'}), 400

    prompt = f"""You are a book database assistant. The user wants to add a book to a reading app.

Book provided: "{title}" by {author}{f', published in {year}' if year else ''}

Your task:
1. Verify if this book and author combination is real and correct
2. If real, provide accurate information about it
3. If the title or author seems incorrect or doesn't match, say so

Respond ONLY with a valid JSON object, no markdown, no explanation:
{{
  "is_valid": true or false,
  "reason": "explain if invalid, or 'Book verified' if valid",
  "title": "correct title",
  "author": "correct full author name",
  "year": year as integer,
  "pages": number of pages as integer,
  "description": "2-3 sentence description of the book",
  "genres": ["genre1", "genre2"],
  "isbn": "ISBN-13 if known, or null"
}}

Only include real, accurate information. If you're not sure about pages or ISBN, use null."""

    try:
        response = client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[{"role": "user", "content": prompt}],
            max_tokens=500,
            temperature=0.1,
        )
        raw = response.choices[0].message.content.strip()
        raw = raw.replace('```json', '').replace('```', '').strip()
        book_data = json.loads(raw)

        if book_data.get('is_valid'):
            print(f"Book is valid, fetching cover for: {book_data.get('title')}")
            cover_url = fetch_cover(
                book_data.get('title', title),
                book_data.get('author', author),
                book_data.get('isbn')
            )
            print(f"Cover URL result: {cover_url}")
            book_data['cover_url'] = cover_url

        return jsonify(book_data)

    except json.JSONDecodeError:
        return jsonify({'error': 'AI response could not be parsed. Try again.'}), 500
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@add_book_bp.route('/confirm', methods=['POST'])
@jwt_required()
def confirm_book():
    user_id = int(get_jwt_identity())
    data = request.get_json()

    existing = Book.query.filter(
        db.func.lower(db.func.trim(Book.title)) == data['title'].strip().lower(),
        db.func.lower(db.func.trim(Book.author)) == data['author'].strip().lower()
    ).first()

    if existing:
        return jsonify({'error': 'This book already exists in the database', 'book_id': existing.id}), 409

    book = Book(
        title=data['title'],
        author=data['author'],
        year=data.get('year'),
        description=data.get('description'),
        cover_url=data.get('cover_url'),
        isbn=str(data.get('isbn')) if data.get('isbn') else None,
        pages=data.get('pages'),
        added_by_user_id=user_id
    )
    db.session.add(book)
    db.session.flush()

    for genre_name in data.get('genres', []):
        if not genre_name:
            continue
        genre = Genre.query.filter(Genre.name.ilike(genre_name)).first()
        if not genre:
            genre = Genre(name=genre_name)
            db.session.add(genre)
            db.session.flush()
        if genre not in book.genres:
            book.genres.append(genre)

    db.session.commit()
    return jsonify({'message': 'Book added successfully', 'book_id': book.id}), 201