"""Money calculations for refunds."""

from __future__ import annotations

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from refund_checker.rules import Order

RESTOCKING_FEE_RATE = 0.10


def restocking_fee(price: float, opened: bool) -> float:
    """10% of the price for opened items, nothing for unopened ones."""
    if not opened:
        return 0.0
    return round(price * RESTOCKING_FEE_RATE, 2)


def refund_amount(order: Order) -> float:
    """Price minus the restocking fee, plus shipping if the item was faulty."""
    fee = 0.0 if order.faulty else restocking_fee(order.price, order.opened)
    shipping = order.shipping if order.faulty else 0.0
    return round(order.price - fee + shipping, 2)
