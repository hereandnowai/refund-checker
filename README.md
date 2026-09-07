# Refund Checker

A small returns-desk tool: describe an order, get a refund decision. FastAPI backend,
one static page, no database, no API keys.

## Run it

```bash
python3 -m venv .venv
source .venv/bin/activate          # Windows: .venv\Scripts\activate
pip install -r requirements.txt
uvicorn app:app --reload
```

Open http://127.0.0.1:8000. Tests:

```bash
pytest -q
```
