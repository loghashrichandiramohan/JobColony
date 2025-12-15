# === file: openai_client.py ===
import os
import openai
import json

openai.api_key = os.getenv('OPENAI_API_KEY')


def generate_structured_profile(raw_text: str) -> dict:
    """
    Call OpenAI to convert freeform resume/experience text into structured JSON fields.
    This is a simple prompt; adjust in production.
    """
    prompt = (
        "Extract the following fields from the resume or experience text and output valid JSON:\n"
        "{full_name, title, skills:[...], experience_years, industries:[...], summary}\n\n"
        f"Text:\n````\n{raw_text}\n````\n\n"
    )
    res = openai.ChatCompletion.create(
        model="gpt-4o-mini",
        messages=[{"role": "user", "content": prompt}],
        temperature=0
    )
    text = res['choices'][0]['message']['content']
    try:
        data = json.loads(text)
    except Exception:
        # Fallback: return raw text under 'summary'
        data = {"summary": raw_text}
    return data


def get_embedding(text: str) -> list:
    """
    Generate an embedding for the given text using OpenAI embeddings.
    """
    resp = openai.Embedding.create(
        model='text-embedding-3-small',
        input=text
    )
    return resp['data'][0]['embedding']
