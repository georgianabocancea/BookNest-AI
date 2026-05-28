# BookNest AI — Short Documentation

A small full-stack app to manage a personal book library with backend APIs and a React + TypeScript frontend.

**Overview**
- Backend: Python web API that handles book data, auth, and profile routes.
- Frontend: React + TypeScript SPA providing UI for library, discover, and profile pages.

**Project structure (high level)**
- backend/: Python backend and database schema
  - backend/run.py — app entrypoint
  - backend/requirements.txt — Python dependencies
  - backend/import_books.py — helper to load book data
  - backend/migrations/booknest_schema.sql — DB schema
  - backend/app/__init__.py — Flask app factory and setup
  - backend/app/models.py — data models
  - backend/app/routes/ — API routes (add_book.py, auth.py, books.py, profile.py, nestie.py)
- frontend/: React + TypeScript frontend
  - frontend/package.json — npm scripts & deps
  - frontend/src/ — React source files
  - frontend/src/pages/ — pages (Library, Discover, AddBook, Profile, Auth flows)
  - frontend/src/components/ — UI components (Header, NestieWidget)
  - frontend/src/services/api.ts — API client

**Key files**
- [backend/run.py](backend/run.py)
- [backend/app/__init__.py](backend/app/__init__.py)
- [backend/app/models.py](backend/app/models.py)
- [backend/app/routes/books.py](backend/app/routes/books.py)
- [frontend/package.json](frontend/package.json)
- [frontend/src/App.tsx](frontend/src/App.tsx)
- [frontend/src/pages/LibraryPage.tsx](frontend/src/pages/LibraryPage.tsx)

**Technologies used**
- Backend: Python (3.x), Flask (web framework)
- Database: relational SQL (schema in `backend/migrations/booknest_schema.sql`)
- Frontend: React, TypeScript, Tailwind CSS, PostCSS
- Tooling: npm / Node.js for frontend, pip and virtualenv for backend

**Run (quick start)**
Backend (from repo root):
```bash
cd backend
# create + activate venv (if needed)
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python run.py
```

Frontend (from repo root):
```bash
cd frontend
npm install
npm start
```

**Notes**
- The database schema is provided in `backend/migrations/booknest_schema.sql`.
- API client code is in `frontend/src/services/api.ts` — update base URL if backend runs on a different host/port.

If you want, I can expand this into a more detailed `CONTRIBUTING.md`, add example env files, or generate API docs. Which would you prefer next?
