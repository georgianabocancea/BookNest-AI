from flask import Flask, app
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager
from flask_cors import CORS
from dotenv import load_dotenv
from sqlalchemy import text
import os

load_dotenv()

db = SQLAlchemy()
jwt = JWTManager()


def _apply_progress_constraint_patch(app):
    # Auto-fix legacy DB schema where progress was limited to 0..100.
    with app.app_context():
        if db.engine.dialect.name != 'postgresql':
            return

        try:
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
        except Exception as exc:
            app.logger.warning('Could not auto-patch user_books.progress constraint: %s', exc)

def create_app():
    app = Flask(__name__)
    
    app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URL')
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    app.config['JWT_SECRET_KEY'] = os.getenv('JWT_SECRET_KEY')

    db.init_app(app)
    jwt.init_app(app)
    CORS(app, origins=["http://localhost:3000", "http://localhost:3001"])
    _apply_progress_constraint_patch(app)

    from app.routes.auth import auth_bp
    from app.routes.books import books_bp
    app.register_blueprint(auth_bp, url_prefix='/api/auth')
    app.register_blueprint(books_bp, url_prefix='/api/books')
    from app.routes.nestie import nestie_bp
    app.register_blueprint(nestie_bp, url_prefix='/api/nestie')
    from app.routes.profile import profile_bp
    app.register_blueprint(profile_bp, url_prefix='/api/profile')

    return app