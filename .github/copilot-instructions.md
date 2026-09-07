# Copilot instructions — Refund Checker

- Python 3.12+, FastAPI, pytest. No other frameworks.
- Business rules live in `refund_checker/rules.py`; money maths in `refund_checker/money.py`.
  `app.py` is a thin HTTP layer and must not contain policy.
- The refund policy is documented in `README.md` under "Refund policy". Code and README
  must agree; if you change one, change the other.
- Tests go in the top-level `tests/` directory, one file per module, using plain `assert`.
  Do not create test files inside `refund_checker/`.
- Run tests with `pytest -q` from the repo root.
