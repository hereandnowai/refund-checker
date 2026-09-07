"""Refund Checker web app — one page, one endpoint."""

from datetime import date
from pathlib import Path

from fastapi import FastAPI
from fastapi.responses import FileResponse
from pydantic import BaseModel, Field

from refund_checker.rules import Order, check_refund, partial_refund

STATIC_DIR = Path(__file__).resolve().parent / "static"

app = FastAPI(title="Refund Checker")


class CheckRequest(BaseModel):
    order_id: str = Field(min_length=1)
    price: float = Field(gt=0)
    category: str
    delivered_on: date
    opened: bool = False
    faulty: bool = False
    shipping: float = Field(default=0.0, ge=0)
    quantity: int = Field(default=1, ge=1)
    returned_quantity: int | None = None


class CheckResponse(BaseModel):
    order_id: str
    verdict: str
    reason: str
    refund_amount: float


@app.get("/")
def index() -> FileResponse:
    return FileResponse(STATIC_DIR / "index.html", media_type="text/html")


@app.post("/api/check", response_model=CheckResponse)
def check(request: CheckRequest) -> CheckResponse:
    payload = request.model_dump()
    returned = payload.pop("returned_quantity")
    order = Order(**payload)
    if returned is not None and returned < order.quantity:
        decision = partial_refund(order, returned)
    else:
        decision = check_refund(order)
    return CheckResponse(
        order_id=order.order_id,
        verdict=decision.verdict.value,
        reason=decision.reason,
        refund_amount=decision.refund_amount,
    )
