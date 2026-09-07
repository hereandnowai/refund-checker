from refund_checker.money import restocking_fee


def test_unopened_items_have_no_fee():
    assert restocking_fee(100.0, opened=False) == 0.0


def test_opened_items_pay_ten_percent():
    assert restocking_fee(100.0, opened=True) == 10.0
