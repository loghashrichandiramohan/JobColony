# === file: jobs_scraper.py ===
# Placeholder: implement connectors to job APIs or scrapers. Example with Adzuna / Jooble / Indeed.
# For MVP we'll provide a simple HTTP fetcher that expects the user to configure an API.

import requests


def fetch_jobs_from_api(query: str, api_key: str = None) -> list:
    """
    Return a list of job dicts: {title, company, location, description, url, source_id}.
    Replace this with real API connector code.
    """
    # Example placeholder: return empty list
    return []
