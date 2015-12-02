#coding:gbk

import os

pyexts = os.path.dirname(__file__) + "/pyexts"

for root, dirs, files in os.walk(pyexts):
    for f in files:
        if f.endswith(".py"):
            execfile(root + "/" + f, globals())
