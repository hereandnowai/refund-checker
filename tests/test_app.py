from datetime import date, timedelta

from fastapi.testclient import TestClient

from app import app

client = TestClient(app)


def test_index_serves_the_page():
    response = client.get("/")

    assert response.status_code == 200
    assert "Refund Checker" in response.text


def test_check_endpoint_returns_a_decision():
    payload = {
        "order_id": "ORD-7",
        "price": 49.0,
        "category": "books",
        "delivered_on": (date.today() - timedelta(days=3)).isoformat(),
    }

    response = client.post("/api/check", json=payload)

    assert response.status_code == 200
    body = response.json()
    assert body["verdict"] == "approved"
    assert body["refund_amount"] == 49.0
