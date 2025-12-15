# JobColony
JobColony is a smart job search platform that matches professionals with relevant roles using AI-driven profile analysis. It aggregates jobs from multiple sources, filters outdated or irrelevant listings, and ranks opportunities by role, skills, experience, and location. Built with FastAPI and SQLModel, it’s ready for web or mobile integration.


# JobColony

**JobColony** is an intelligent job search and recommendation platform that connects professionals with opportunities tailored to their skills, experience, and career goals. Unlike traditional job boards, JobColony focuses on precision and relevance, aggregating listings from reliable sources such as Jooble, Google Jobs, LinkedIn, and company websites. Users create profiles and input their experience, which is processed into structured data and AI-powered embeddings, enabling semantic matching with relevant jobs. Each listing is scored based on role alignment, skill relevance, location, work type, and experience, while outdated or irrelevant postings are automatically filtered out.

## Features
- Aggregates jobs from multiple legal sources (Jooble, Google Jobs, LinkedIn, company websites)
- AI-powered profile analysis for personalized recommendations
- Role- and skill-aware matching
- Filters by experience, work type, and location
- Match scoring and ranking for high-quality results
- Secure user registration and profile management
- REST API ready for web and mobile integration

## Tech Stack
- **Backend:** FastAPI, SQLModel
- **Database:** SQLite/PostgreSQL
- **AI/ML:** OpenAI embeddings for semantic job matching
- **Frontend Integration:** Flutter Web/Mobile, React
- **Environment Management:** Configurable via `.env` for API keys

## Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/jobcolony.git

2. Create a virtual environment:

   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```
3. Install dependencies:

   ```bash
   pip install -r requirements.txt
   ```
4. Add a `.env` file with your API keys:

   ```
   JOOBLE_API_KEY=your_jooble_api_key
   GOOGLE_API_KEY=your_google_api_key
   GOOGLE_CX_ID=your_google_cx_id
   ```

## Usage

* Run the FastAPI backend:

  ```bash
  uvicorn main:app --reload
  ```
* Access the API at `http://127.0.0.1:8000/`
* Endpoints include:

  * `/search_jobs` – Search and filter jobs
  * `/auth/register` – Register a user
  * `/auth/login` – Login
  * `/type_experience` – Add experience to profile
  * `/profiles/{profile_id}/matches` – Get job matches

## License

This project is licensed under the MIT License.

