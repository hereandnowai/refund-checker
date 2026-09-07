# Refund Checker

A small returns-desk tool: describe an order, get a refund decision. FastAPI backend,
one static page, no database, no API keys.

## Run it

```bash
./run.sh           # makes the venv, installs, starts on :8000, opens the browser
./run.sh test      # runs pytest
```

Or by hand:

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

## Refund policy

This is the policy the returns desk applies. `refund_checker/rules.py` implements it.

1. **30-day window.** An item may be returned for a refund within 30 days of delivery.
   Day 30 counts — an item delivered on 1 September may be returned on 1 October.
2. **Opened items: 14 days.** If the item has been opened, the window is 14 days, not 30.
3. **Final sale.** Clearance, gift cards and perishables are never refundable.
4. **Restocking fee.** Opened items carry a 10% restocking fee, rounded half-up to the nearest
   paisa (a fee of ₹1.295 becomes ₹1.30). Unopened items have no fee.
5. **Faulty items.** If the item was faulty, there is no restocking fee and the shipping
   charge is refunded as well.

## API

`POST /api/check`

```json
{
  "order_id": "ORD-1042",
  "price": 12.95,
  "category": "electronics",
  "delivered_on": "2026-08-28",
  "opened": true,
  "faulty": false,
  "shipping": 0
}
```

```json
{
  "order_id": "ORD-1042",
  "verdict": "approved",
  "reason": "within the 30-day refund window",
  "refund_amount": 11.65
}
```

Categories: `electronics`, `clothing`, `books`, `clearance`, `gift-card`, `perishable`.

## Layout

```
app.py                      HTTP layer only
refund_checker/rules.py     the policy as code
refund_checker/money.py     fee and refund amount
static/index.html           the page
tests/                      pytest
```
