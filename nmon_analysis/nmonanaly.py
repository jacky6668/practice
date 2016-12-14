#!/usr/bin/env python
# encoding: utf-8

import os
import sys
from collections import defaultdict

sysInfo = []
bbbInfo = []
processedData = {}
out = {}
key = {'ZZZZ','CPU_ALL'}

def processLine(header,line):
    tStamp = {}
    r = {}
    if "AAA" in header:
        sysInfo.append(line[1:])
    elif "BBB" in header:
        bbbInfo.append(line)
    elif "ZZZZ" in header:
        tStamp[line[1][1:]]=line[3]+","+line[2]
    elif 'CPU_ALL' in header:
        r[line[1][1:]]=line[2]

    for k,v in tStamp.items():
        if k in r.keys():
           r[k] = v+","+output[k]
        else:
            r[k] = v

    return r

def parse(fd):
    re = {}
    line = fd.readlines()
    for l in line:
        l = l.strip()
        bits = l.split(',')
        re = processLine(bits[0],bits)

    return re

def outfile(dic):
    dic_r = {}
    dic_r= sorted(dic.items(), key=lambda x:x[0])
    os.remove('out')
    out = open('out','w')
    #out.writelines(output)
    for item in dic_r:
        out.write(str(item)+'\n')
    out.close

def walk(direct):
    output = {}
    if not os.path.exists(direct):
        raise Exception("Error: %s not exists" % direct)
    result = defaultdict(list)
    for root, dirs, files in os.walk(direct):
        for f in files:
            path = os.path.join(root, f)
            f = f.rsplit("-", 1)[0]
            print path
            with open(path) as fp:
                output = parse(fp)
    outfile(output)

if __name__ == "__main__":
    walk('nmon_res')
