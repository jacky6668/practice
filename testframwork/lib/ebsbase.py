# -*- coding: utf-8 -*-

from common import Common


class EBSBase(Common):
    """This is ebsbase class"""

    def b(self):
        Common.a(self)
        print "this is ebsbase:b"

    def c(self, name):
        print "ebsbase.c' name is %s" % name
