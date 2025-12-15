# JobColony - FastAPI MVP (local)

This repo is an MVP backend for the "JobColony" app. It runs locally with SQLite and demonstrates:
- Resume upload (PDF/DOCX/TXT) and text extraction
- Experience typed -> AI-structured profile (uses OpenAI)
- Embedding-based profile <-> job matching (uses OpenAI embeddings)
- Simple job fetcher (placeholder / API connector)
- Background scanner (async, polling)

python -m venv venv        
.\venv\Scripts\Activate.ps1
 
flutter devices
flutter run