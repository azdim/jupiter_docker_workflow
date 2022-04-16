# -*- coding: utf-8 -*-
import sys
import circle
sys.path.insert(0, '..')


def test_radius_0():
    zero_circle = circle.Circle(float(0.0))
    assert round(zero_circle.area(), 2) == 0
    assert round(zero_circle.perimeter(), 2) == 0
