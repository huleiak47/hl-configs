#!/usr/bin/env python
# -*- coding:utf-8 -*-

import sys
import os
import re
import subprocess as sp
from pathlib import Path

line = open(sys.argv[1]).readline().strip()

cols = line.split("\t")

name = cols[0]
for col in cols[1:]:
    if re.match(r"^[A-Z]:\\.*", col):
        path = col
        break
else:
    raise Exception("Cannot find path")

file = Path(path) / name

if file.is_file():
    sp.Popen(["gvim.exe", str(file)])
elif file.is_dir():
    sp.Popen([os.environ["PORTABLE_HOME"] + r"\totalcmd\TOTALCMD.EXE", "/T", "/O", "/P=L", '/L=%s' % str(file)])
else:
    # maybe this is not a correct file or dir
    pass
