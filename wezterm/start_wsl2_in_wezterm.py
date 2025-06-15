#!/usr/bin/env python3
# -*- coding:utf-8 -*-

import os
import re
import subprocess as sp

cwd = os.getcwd()


def repl(mobj):
    return "/" + mobj.group(1).lower()


cwd_wsl = re.sub(r"""^([A-Z]):""", repl, cwd).replace("\\", "/")

ret = sp.Popen(["wezterm-gui.exe", "start", "wsl", "--cd", cwd_wsl, "--", "zsh"])
