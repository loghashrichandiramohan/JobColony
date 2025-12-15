import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
import json


def embedding_to_np(emb):
    return np.array(emb, dtype=float)


def score_match(profile_embedding, job_embedding):
    a = embedding_to_np(profile_embedding)
    b = embedding_to_np(job_embedding)
    sim = cosine_similarity([a], [b])[0][0]
    return float(sim)
