#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys

path = "/root/mds-check-log"
log_file = "/root/mds-check-log/mds-check-err.log"
result = "/root/mds-result.log"

darray = [
    "superblock tenant",
    "superblock fsName",
    "filesystem exist error",
    "UsedFiles",
    "UsedBytes",
    "UNUSED_FILENAME",
    "file read error: EEOF",
    "dir backend load error",
    "file not exist",
    "file read error"
]


def isInArray(array, line):
    for item in array:
        if item in line:
            return True
    return False


def access_log():
    print "path is: %s" % path
    print "log file is: %s" % log_file

    res = os.path.isdir(path)
    if res is False:
        sys.exit("%s no exist!!" % path)

    res = os.path.isfile(log_file)
    if res is False:
        sys.exit("%s no exist!!" % log_file)

    with open(log_file, 'r') as f:
        with open(result, 'w') as g:
            for line in f.readlines():
                if not isInArray(darray, line):
                    g.write(line)


if __name__ == "__main__":
    access_log()
