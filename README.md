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

## About this repository

Built by [HERE AND NOW AI](https://hereandnowai.com) for the GitHub Copilot Expert Track — Day 6, *Testing, Reviews and Collaboration*. The reusable Copilot prompt files used in the session are in [`prompts/`](prompts/).

Licensed under the [MIT License](LICENSE).

---

<p align="center">
  <a href="https://hereandnowai.com"><img src="https://raw.githubusercontent.com/hereandnowai/images/refs/heads/main/logos/logo-of-here-and-now-ai.png" alt="HERE AND NOW AI" width="320"></a><br>
  <em>AI is Good</em><br>
  <a href="https://hereandnowai.com">hereandnowai.com</a> · <a href="mailto:info@hereandnowai.com">info@hereandnowai.com</a> · +91 996 296 1000<br>
  <a href="https://www.linkedin.com/company/hereandnowai/">LinkedIn</a> · <a href="https://github.com/hereandnowai">GitHub</a> · <a href="https://youtube.com/@hereandnow_ai">YouTube</a> · <a href="https://x.com/hereandnow_ai">X</a> · <a href="https://instagram.com/hereandnow_ai">Instagram</a> · <a href="https://hereandnowai.com/blog">Blog</a>
</p>
