#!/usr/bin/env python3
"""
Booknest AI — Script to import data from Excel into PostgreSQL
Usage: python import_books.py

Requires the DATABASE_URL environment variable or adjusted connection parameters.
"""
import pandas as pd
import psycopg2
import os
import sys

DATABASE_URL = os.environ.get(
    "DATABASE_URL",
    "postgresql://user:password@localhost:5432/booknest"
)

def import_books(excel_path="Book1.xlsx"):
    df = pd.read_excel(excel_path)
    df["title"]       = df["title"].str.strip()
    df["author"]      = df["author"].str.strip()
    df["genre"]       = df["genre"].str.strip()
    df["description"] = df["description"].str.strip()
    df["cover_url"]   = df["cover_url"].where(df["cover_url"].notna(), None)
    df["year"]        = df["year"].astype(int)

    conn = psycopg2.connect(DATABASE_URL)
    cur  = conn.cursor()

    # Unique genres
    all_genres = set()
    for g in df["genre"]:
        for part in str(g).split(","):
            all_genres.add(part.strip())

    for genre in sorted(all_genres):
        cur.execute(
            "INSERT INTO genres (name) VALUES (%s) ON CONFLICT (name) DO NOTHING",
            (genre,)
        )

    # Books
    for _, row in df.iterrows():
        cur.execute(
            """INSERT INTO books (title, author, year, description, cover_url)
               VALUES (%s, %s, %s, %s, %s)
               ON CONFLICT DO NOTHING
               RETURNING id""",
            (row["title"], row["author"], int(row["year"]),
             row["description"], row["cover_url"])
        )
        result = cur.fetchone()
        if not result:
            cur.execute("SELECT id FROM books WHERE title=%s AND author=%s",
                        (row["title"], row["author"]))
            result = cur.fetchone()
        book_id = result[0]

        # Book genres
        for genre in [g.strip() for g in str(row["genre"]).split(",")]:
            cur.execute("SELECT id FROM genres WHERE name=%s", (genre,))
            genre_row = cur.fetchone()
            if genre_row:
                cur.execute(
                    "INSERT INTO book_genres (book_id, genre_id) VALUES (%s,%s) ON CONFLICT DO NOTHING",
                    (book_id, genre_row[0])
                )

    conn.commit()
    cur.close()
    conn.close()
    print(f"Import complete: {len(df)} books, {len(all_genres)} genres.")

if __name__ == "__main__":
    path = sys.argv[1] if len(sys.argv) > 1 else "Book1.xlsx"
    import_books(path)