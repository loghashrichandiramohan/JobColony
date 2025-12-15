import sqlite3

conn = sqlite3.connect("back.db")
cursor = conn.cursor()

# Check if 'password' exists
cursor.execute("PRAGMA table_info(user)")
columns = [col[1] for col in cursor.fetchall()]

if "password" not in columns:
    cursor.execute("ALTER TABLE user ADD COLUMN password TEXT")
    print("Password column added")
else:
    print("Password column already exists")

conn.commit()
conn.close()
