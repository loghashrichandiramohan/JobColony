from sqlmodel import SQLModel, create_engine
from models import User, Profile, Job

engine = create_engine("sqlite:///back.db")  # same DB path as in main.py

SQLModel.metadata.create_all(engine)  # creates all tables
print("Tables created successfully")
