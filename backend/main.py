# main.py
from fastapi import FastAPI, Form
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from sqlmodel import Session, select
import json
from pydantic import BaseModel
from fastapi import Query
import requests

from models import User, Profile, Job
from openai_client import generate_structured_profile, get_embedding
from matching import score_match
from database import engine  # make sure you have init_db() called somewhere
import openai
# Initialize FastAPI app
app = FastAPI()
from urllib.parse import urlparse
from dotenv import load_dotenv
import os

load_dotenv()  # <-- loads variables from .env

JOOBLE_API_KEY = os.getenv("JOOBLE_API_KEY")
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
GOOGLE_CX_ID = os.getenv("GOOGLE_CX_ID")
def extract_source_name(url: str) -> str:
    domain = urlparse(url).netloc.lower()

    if "linkedin" in domain:
        return "LinkedIn"
    if "naukri" in domain:
        return "Naukri"
    if "glassdoor" in domain:
        return "Glassdoor"
    if "indeed" in domain:
        return "Indeed"
    if "monster" in domain:
        return "Monster"
    if "wellfound" in domain or "angel" in domain:
        return "Wellfound"
    if "company" in domain or "careers" in domain:
        return "Company Website"

    # fallback → clean domain
    return domain.replace("www.", "").split(".")[0].capitalize()


# Enable CORS for Flutter Web
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Create DB tables (if not exists)
from database import init_db
init_db()



# ------------------------------------------------------
# SEARCH JOBS ENDPOINT (Jooble + Google)
# ------------------------------------------------------

@app.get("/search_jobs")
def search_jobs(
    role: str,
    skills: str = "",
    country: str = "Any",
    work_type: str = "Any",
    experience: int = 0,
):
    jobs = []
    skill_list = [s.strip().lower() for s in skills.split(",") if s.strip()]

    # -----------------------
    # 1. FETCH FROM JOOBLE
    # -----------------------
    try:
        jooble_url = f"https://jooble.org/api/{JOOBLE_API_KEY}"
        payload = {"keywords": role + " " + " ".join(skill_list), "datePosted": 30}
        if country != "Any":
            payload["location"] = country
        res = requests.post(jooble_url, json=payload).json()

        for j in res.get("jobs", []):
            jobs.append({
                "title": j.get("title", ""),
                "company": j.get("company", ""),
                "location": j.get("location", ""),
                "description": j.get("snippet", ""),
                "url": j.get("link"),
                "source": "Jooble"
            })
    except Exception as e:
        print("Jooble error:", e)

    # -----------------------
    # 2. FETCH FROM GOOGLE
    # -----------------------
    try:
        q = f"{role} {' '.join(skill_list)} jobs"

        if country != "Any":
            q += f" {country}"

        google_url = (
            f"https://www.googleapis.com/customsearch/v1?"
            f"key={GOOGLE_API_KEY}&cx={GOOGLE_CX_ID}"
            f"&q={q.replace(' ', '+')}&dateRestrict=m3"  # last 3 months
        )
        g_res = requests.get(google_url).json()

        for item in g_res.get("items", []):
            link = item.get("link", "")
            jobs.append({
                "title": item.get("title", ""),
                "company": extract_source_name(link),  # LinkedIn, Glassdoor, etc.
                "location": country if country != "Any" else "Global",
                "description": item.get("snippet", ""),
                "url": link,
                "source": "Google"
            })
    except Exception as e:
        print("Google error:", e)

    # -----------------------
    # 3. SMART FILTER + SCORING
    # -----------------------
    ranked = []
    for j in jobs:
        title = j["title"].lower()
        desc = j["description"].lower()
        location = j["location"].lower()

        score = 0

        # Role relevance
        if role.lower() in title:
            score += 4

        # Skill relevance
        for skill in skill_list:
            if skill in title or skill in desc:
                score += 2

        # Country relevance
        if country != "Any" and country.lower() in location:
            score += 1

        # Work type relevance
        if work_type != "Any" and work_type.lower() in title:
            score += 1

        # -----------------------
        # Experience filter (0–30 years)
        # -----------------------
        exp_matched = False
        combined_text = f"{title} {desc}"

        if experience <= 2 and ("intern" in combined_text or "fresher" in combined_text):
            exp_matched = True
        elif 1 <= experience <= 3 and "junior" in combined_text:
            exp_matched = True
        elif 3 <= experience <= 7 and ("mid" in combined_text or "associate" in combined_text):
            exp_matched = True
        elif experience >= 5 and ("senior" in combined_text or "lead" in combined_text or "manager" in combined_text):
            exp_matched = True
        elif experience == 0:
            exp_matched = True  # if slider = 0, include all

        if not exp_matched:
            continue

        # Only include jobs with positive score
        if score > 0:
            j["score"] = score
            ranked.append(j)

    # -----------------------
    # 4. SORT BY SCORE DESC
    # -----------------------
    ranked.sort(key=lambda x: x["score"], reverse=True)

    return {"total": len(ranked), "jobs": ranked}

class RegisterRequest(BaseModel):
    email: str
    password: str

@app.post("/auth/register")
async def register_user(req: RegisterRequest):
    user = User(email=req.email, password=req.password)
    with Session(engine) as session:
        session.add(user)
        session.commit()
        session.refresh(user)
    return {"status": "ok", "user_id": user.id}

class LoginRequest(BaseModel):
    email: str
    password: str

@app.post("/auth/login")
async def login_user(req: LoginRequest):
    with Session(engine) as session:
        user = session.exec(select(User).where(User.email == req.email)).first()
        if not user or user.password != req.password:  # Add hashing later
            return JSONResponse({"error": "Invalid credentials"}, status_code=401)
        return {"status": "ok", "user_id": user.id}
     
@app.post('/type_experience')
async def type_experience(email: str = Form(...), experience: str = Form(...)):
    structured = {}
    try:
        structured = generate_structured_profile(experience)
    except Exception:
        structured = {"summary": experience}

    emb = None
    try:
        emb = get_embedding(experience)
    except Exception:
        emb = None

    with Session(engine) as session:
        user = User(email=email)
        session.add(user)
        session.commit()
        session.refresh(user)

        profile = Profile(
            user_id=user.id,
            raw_text=experience,
            structured_json=json.dumps(structured),
            embedding=json.dumps(emb) if emb else None
        )
        session.add(profile)
        session.commit()
        session.refresh(profile)

        return JSONResponse({"status": "ok", "profile_id": profile.id})


@app.get('/profiles/{profile_id}/matches')
def get_matches(profile_id: int, threshold: float = 0.7):
    with Session(engine) as session:
        profile = session.get(Profile, profile_id)
        if not profile:
            return JSONResponse({'error': 'not found'}, status_code=404)
        if not profile.embedding:
            return JSONResponse({'error': 'profile has no embedding'}, status_code=400)

        p_emb = json.loads(profile.embedding)
        jobs = session.exec(select(Job)).all()
        matches = []

        for j in jobs:
            if not j.embedding:
                continue
            j_emb = json.loads(j.embedding)
            try:
                sc = score_match(p_emb, j_emb)
            except Exception:
                continue
            if sc >= threshold:
                matches.append({
                    'job_id': j.id,
                    'title': j.title,
                    'company': j.company,
                    'location': j.location,
                    'score': sc,
                    'url': j.url
                })

        return {'matches': sorted(matches, key=lambda x: -x['score'])}


@app.get('/')
def root():
    return {'msg': 'JobColony MVP running'}
