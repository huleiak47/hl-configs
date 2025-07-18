#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import re
from pathlib import Path

# settings = "SumatraPDF-settings.txt"
settings = os.environ.get("USERPROFILE") + r"\AppData\Local\SumatraPDF\SumatraPDF-settings.txt"

content = Path(settings).read_text(encoding="utf-8")


def repl(mobj):
    if mobj.group(1) == "#ffffff":
        return "BackgroundColor = #d8e8d8"
    else:
        return "BackgroundColor = #ffffff"


content2 = re.sub(r"""BackgroundColor = (.*)\s*$""", repl, content, flags=re.MULTILINE)

if content2 != content:
    Path(settings).write_text(content2, encoding="utf-8")
