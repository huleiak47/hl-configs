# !/usr/bin/env python
#-*- coding:utf-8 -*-
##
# @file setprotablepath.py
# @brief set protable path
# @author hulei
# @version 1.0
# @date 2011-05-08

# 设置的变量
import os
import sys

for disk in "ABCDEFGHIJKLMN":
    if os.path.isdir(disk + ":\\portable"):
        basedir = disk + ":\\portable"
        break
else:
    while 1:
        basedir = input("input the portable path: ")
        if os.path.isdir(basedir):
            break
        if basedir == "exit":
            sys.exit(1)

g_basemap = {
    "basedir": os.path.normpath(basedir).split("\\"),
}

# 文件配置
g_files = [
    #templatefile               , destfile                 , separator, encoding,
    ("environment.reg.tmp"     , "environment.reg"     , "\\\\"  , "gbk")  ,
    ("ahkfile.reg.tmp"         , "ahkfile.reg"         , "\\\\"  , "gbk")  ,
    ("notepad2.reg.tmp"        , "notepad2.reg"        , "\\\\"  , "gbk")  ,
    ("vimfile.reg.tmp"         , "vimfile.reg"         , "\\\\"  , "gbk")  ,
]

OFF_TEMP = 0
OFF_DEST = 1
OFF_SEP = 2
OFF_ENC = 3


def getmap(sep):
    ret = {}
    for k, v in list(g_basemap.items()):
        if isinstance(v, (list, tuple)):
            ret[k] = sep.join(v)
        else:
            ret[k] = v
    return ret

g_maps = {
    "/": getmap("/"),
    "\\": getmap("\\"),
    "\\\\": getmap("\\\\"),
}

import re
pattern = re.compile("<reg_ext_sz>(.+?)</reg_ext_sz>")


def reg_ext_sz_repl(mobj):
    s = mobj.group(1).replace("\\\\", "\\")
    ret = []
    for c in s:
        ret.append("%02x" % (ord(c) & 0xff))
        ret.append("%02x" % ((ord(c) >> 8) & 0xff))
    ret.append("00")
    ret.append("00")

    return "hex(2):" + ",".join(ret)


def reg_ext_sz_change(content):
    return pattern.sub(reg_ext_sz_repl, content)


def main():
    if not os.path.exists("regs"):
        os.mkdir("regs")
    for tf, df, sep, enc in g_files:
        print("read file " + tf)
        content = open("./templatefile/" + tf, 'r').read()
        content = content.format(**g_maps[sep])
        content = reg_ext_sz_change(content)
        filename = "regs/" + df
        print("write file %s begin" % filename)
        with open(filename, 'w') as f:
            f.write(content)
        print("write file %s over" % filename)

if __name__ == '__main__':
    main()
