import io
from typing import Tuple
from PyPDF2 import PdfReader
import docx


def extract_text_from_pdf(file_bytes: bytes) -> str:
    reader = PdfReader(io.BytesIO(file_bytes))
    text = []
    for page in reader.pages:
        text.append(page.extract_text() or "")
    return "\n".join(text)


def extract_text_from_docx(file_bytes: bytes) -> str:
    f = io.BytesIO(file_bytes)
    doc = docx.Document(f)
    paragraphs = [p.text for p in doc.paragraphs]
    return "\n".join(paragraphs)


def extract_text_from_txt(file_bytes: bytes) -> str:
    return file_bytes.decode(errors='ignore')


def extract_text(file_name: str, file_bytes: bytes) -> Tuple[str, str]:
    """
    Detect file type from filename and extract its text.
    Returns a tuple of (file_type, extracted_text)
    """
    low = file_name.lower()
    if low.endswith('.pdf'):
        return 'pdf', extract_text_from_pdf(file_bytes)
    if low.endswith('.docx') or low.endswith('.doc'):
        return 'docx', extract_text_from_docx(file_bytes)
    return 'txt', extract_text_from_txt(file_bytes)
