from datetime import date, timedelta

import refund_checker.rules as rules
from refund_checker.rules import Decision, Order, Verdict, check_refund, partial_refund


def delivered(days_ago: int) -> date:
    return date.today() - timedelta(days=days_ago)


def make_order(**overrides) -> Order:
    defaults = dict(
        order_id="ORD-1",
        price=100.0,
        category="electronics",
        delivered_on=delivered(10),
    )
    defaults.update(overrides)
    return Order(**defaults)


def test_unopened_item_inside_window_is_approved():
    decision = check_refund(make_order())

    assert decision.verdict == Verdict.APPROVED
    assert decision.refund_amount == 100.0


def test_opened_item_inside_window_is_approved_with_fee():
    decision = check_refund(make_order(opened=True))

    assert decision.verdict == Verdict.APPROVED
    assert decision.refund_amount == 90.0


def test_final_sale_item_is_denied():
    decision = check_refund(make_order(category="clearance"))

    assert decision.verdict == Verdict.DENIED
    assert "final-sale" in decision.reason


def test_refund_denied_on_day_30():
    decision = check_refund(make_order(delivered_on=delivered(30)))

    assert decision.verdict == Verdict.DENIED


def test_refund_denied_on_day_31():
    decision = check_refund(make_order(delivered_on=delivered(31)))

    assert decision.verdict == Verdict.DENIED
    assert decision.reason == "the refund window has closed"


def test_faulty_item_refunds_shipping_and_waives_fee():
    decision = check_refund(make_order(opened=True, faulty=True, shipping=8.0))

    assert decision.verdict == Verdict.APPROVED
    assert decision.refund_amount == 108.0


def test_partial_refund_rejects_more_units_than_delivered():
    decision = partial_refund(make_order(quantity=2), returned_quantity=3)

    assert decision.verdict == Verdict.DENIED


def test_partial_refund_approves_half_of_the_order(monkeypatch):
    monkeypatch.setattr(
        rules, "check_refund", lambda order: Decision(Verdict.APPROVED, "ok", 50.0)
    )

    decision = partial_refund(make_order(price=100.0, quantity=2), returned_quantity=1)

    assert decision.verdict == Verdict.APPROVED
    assert decision.refund_amount == 50.0
