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
        basedir = raw_input("input the portable path: ")
        if os.path.isdir(basedir):
            break
        if basedir == "exit":
            sys.exit(1)

g_basemap = {
    u"basedir": os.path.normpath(basedir).split("\\"),
}

# 文件配置
g_files = [
    #templatefile               , destfile                 , separator, encoding,
    (u"environment.reg.tmp"     , u"environment.reg"     , u"\\\\"  , "gbk")  ,
    (u"ahkfile.reg.tmp"         , u"ahkfile.reg"         , u"\\\\"  , "gbk")  ,
    (u"notepad2.reg.tmp"        , u"notepad2.reg"        , u"\\\\"  , "gbk")  ,
    (u"vimfile.reg.tmp"         , u"vimfile.reg"         , u"\\\\"  , "gbk")  ,
    (u"vimfile.reg.tmp"         , u"vimfile.reg"         , u"\\\\"  , "gbk")  ,
    (u"vs2008_for_scons.reg.tmp", u"vs2008_for_scons.reg", u"\\\\"  , "gbk")  ,
    (u"vs2010_for_scons.reg.tmp", u"vs2010_for_scons.reg", u"\\\\"  , "gbk")  ,
    (u"vs2012_for_scons.reg.tmp", u"vs2012_for_scons.reg", u"\\\\"  , "gbk")  ,
]

OFF_TEMP = 0
OFF_DEST = 1
OFF_SEP = 2
OFF_ENC = 3


def getmap(sep):
    ret = {}
    for k, v in g_basemap.items():
        if isinstance(v, (list, tuple)):
            ret[k] = sep.join(v)
        else:
            ret[k] = v
    return ret

g_maps = {
    u"/": getmap(u"/"),
    u"\\": getmap(u"\\"),
    u"\\\\": getmap(u"\\\\"),
}

import re
pattern = re.compile(u"<reg_ext_sz>(.+?)</reg_ext_sz>")


def reg_ext_sz_repl(mobj):
    s = mobj.group(1).replace(u"\\\\", u"\\")
    ret = []
    for c in s:
        ret.append(u"%02x" % (ord(c) & 0xff))
        ret.append(u"%02x" % ((ord(c) >> 8) & 0xff))
    ret.append("00")
    ret.append("00")

    return u"hex(2):" + u",".join(ret)


def reg_ext_sz_change(content):
    return pattern.sub(reg_ext_sz_repl, content)


def main():
    if not os.path.exists("regs"):
        os.mkdir("regs")
    for tf, df, sep, enc in g_files:
        content = open("./templatefile/" + tf, 'r').read().decode('utf-8')
        content = content.format(**g_maps[sep])
        content = reg_ext_sz_change(content)
        filename = "regs/" + df
        print "write file %s begin" % filename
        with open(filename, 'w') as f:
            f.write(content.encode(enc))
        print "write file %s over" % filename

if __name__ == '__main__':
    main()
