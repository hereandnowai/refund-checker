"""Refund eligibility rules for the returns desk.

The policy this module implements is written in README.md under
"Refund policy". Keep the two in step.
"""

from dataclasses import dataclass
from datetime import date, datetime
from enum import Enum

from refund_checker.money import refund_amount

REFUND_WINDOW_DAYS = 30
OPENED_WINDOW_DAYS = 14
FINAL_SALE_CATEGORIES = {"clearance", "gift-card", "perishable"}


class Verdict(str, Enum):
    APPROVED = "approved"
    DENIED = "denied"


@dataclass
class Order:
    order_id: str
    price: float
    category: str
    delivered_on: date
    opened: bool = False
    faulty: bool = False
    shipping: float = 0.0
    quantity: int = 1


@dataclass
class Decision:
    verdict: Verdict
    reason: str
    refund_amount: float = 0.0


def days_since_delivery(order: Order) -> int:
    """Whole days between delivery and today."""
    today = datetime.now().date()
    return (today - order.delivered_on).days


def check_refund(order: Order) -> Decision:
    """Apply the refund policy to one order and return a decision."""
    if order.category in FINAL_SALE_CATEGORIES:
        return Decision(Verdict.DENIED, "final-sale items cannot be refunded")

    days = days_since_delivery(order)

    if days < 0:
        return Decision(Verdict.DENIED, "delivery date is in the future")

    if days < REFUND_WINDOW_DAYS:
        return Decision(
            Verdict.APPROVED,
            f"within the {REFUND_WINDOW_DAYS}-day refund window",
            refund_amount(order),
        )

    if order.opened and days > OPENED_WINDOW_DAYS:
        return Decision(
            Verdict.DENIED,
            f"opened items must be returned within {OPENED_WINDOW_DAYS} days",
        )

    return Decision(Verdict.DENIED, "the refund window has closed")


def partial_refund(order: Order, returned_quantity: int) -> Decision:
    """Refund for returning some of the units in a multi-unit order.

    The refund is the returned share of the order, then the normal policy applies.
    """
    try:
        share = returned_quantity / order.quantity
    except (ZeroDivisionError, TypeError):
        return Decision(Verdict.DENIED, "could not work out the returned share")

    if share > 1:
        return Decision(Verdict.DENIED, "cannot return more units than were delivered")

    order.price = round(order.price * share, 2)
    order.shipping = round(order.shipping * share, 2)
    return check_refund(order)
