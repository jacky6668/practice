#!/usr/bin/env python
# -*- coding: utf-8 -*-

import unittest
from ..lib.ebsbase import EBSBase


class TestExample(EBSBase):
    """test cases"""

    def setUp(self):
        print "this is setup"

    def tearDown(self):
        print "this is teardown"

    def test_1(self):
        EBSBase.b(self)
        print "this is a test case1"

    def test_2(self):
        EBSBase.c(self, "yibo")
        print "this is a test case2"


if __name__ == '__main__':
    unittest.TestSuite()
