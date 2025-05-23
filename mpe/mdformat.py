#!/usr/bin/env python3
# -*- coding:utf-8 -*-
"""
format markdown after prettier.
"""

import re
import subprocess as sp
import sys
from typing import Sequence
from collections import defaultdict
from pathlib import Path
import json

import argparse

DEFAULT_CONFIG = {
    "prettier": True,
    "section_number": "no",
}


class MarkdownFormatter:

    def __init__(self, config: dict):
        self.code = False
        self.comment = False
        self.index = defaultdict(int)
        self.cap_index = defaultdict(int)
        self.__reset()
        self.__config = config

    def __reset(self):
        self.code = False
        self.comment = False
        self.index = defaultdict(int)
        self.cap_index = defaultdict(int)

    def __is_comment(self, line: str) -> bool:
        ret = self.comment
        if line.strip().startswith("<!--"):
            self.comment = True
            ret = True
        if line.strip().endswith("-->"):
            self.comment = False
            ret = True
        return ret

    def __is_code(self, line: str) -> bool:
        if line.startswith("```") or line.startswith("~~~"):
            self.code = not self.code
            return True
        return self.code

    @staticmethod
    def __repl_add_space(mobj):
        ret = []
        prefix, text, suffix = mobj.group(1), mobj.group(2), mobj.group(3)
        ret.append(prefix)
        if prefix and prefix not in " \n\r，。？：！）、":
            ret.append(" ")
        ret.append(text)
        if suffix and suffix not in (" \n\r,.?:!)，。？：！）、"):
            ret.append(" ")
        ret.append(suffix)
        return "".join(ret)

    def __add_space(self, line):
        line = re.sub(
            r"""([\u4e00-\u9fa5])([0-9a-zA-Z-+=<|&%$#@\[({])""", r"\1 \2", line
        )
        line = re.sub(r"""([0-9a-zA-Z-+=>|&%\])}])([\u4e00-\u9fa5])""", r"\1 \2", line)
        line = re.sub(r"""([^`]?)(`.+?`)([^`]?)""", self.__repl_add_space, line)
        return line

    def __update_index_and_gen_number(self, section: str) -> str:
        self.index[section] += 1
        for i in range(len(section) + 1, 10):
            self.index["#" * i] = 0
        if section == "#":
            self.cap_index = defaultdict(int)

        ret = []
        for i in range(1, len(section) + 1):
            ret.append(str(self.index["#" * i]))

        return ".".join(ret)

    def __add_index(self, line: str) -> str:
        # `#` 作为第一级章节
        if self.__config["section_number"] == "h1":
            ptn = r"""^(#+)\s*(?:(?:[0-9]{1,2}\.)*[0-9]{1,2}\s+)?(.*)"""
        else:
            ptn = r"""^#(#+)\s*(?:(?:[0-9]{1,2}\.)*[0-9]{1,2}\s+)?(.*)"""

        mobj = re.match(ptn, line, re.DOTALL)
        if not mobj:
            return line

        section = mobj.group(1)
        number = self.__update_index_and_gen_number(section)
        ret = " ".join((section, number, mobj.group(2)))
        if self.__config["section_number"] == "h2":
            ret = "#" + ret
        return ret

    def __add_caption(self, line: str) -> str:
        mobj = re.match(r"""^:\s*([^\s]+)\s+(?:[0-9]+[-][0-9]+\s+)?(.*)""", line)
        if not mobj:
            mobj = re.match(
                r"""^\s*<div class="caption">(?:<center>)?(?:<b>)?\s*([^\s]+)\s+(?:[0-9]+[-][0-9]+)\s+(.*?)(?:</b>)?(?:</center>)?</div>""",
                line,
            )
        if not mobj:
            return line
        tag = mobj.group(1)
        caption = mobj.group(2)
        self.cap_index[tag] += 1
        return (
            '<div class="caption"><center><b>{} {}-{} {}</b></center></div>\n'.format(
                tag, self.index["#"], self.cap_index[tag], caption
            )
        )

    def __add_head(self, line: str) -> str:
        mobj = re.match(r"""^::(.*)::""", line.strip())
        if mobj:
            return '<h1 class="title"><center>{}</center></h1>\n'.format(mobj.group(1))
        return line

    def __prettier_proc(self, lines: Sequence[str]) -> list[str]:
        prettier = sp.Popen(
            "prettier --parser markdown",
            stdin=sp.PIPE,
            stdout=sp.PIPE,
            stderr=sp.PIPE,
            shell=True,
        )
        out, _ = prettier.communicate(input="".join(lines).encode("utf-8"))
        if prettier.returncode != 0:
            sys.stderr.write(f"call prettier failed, ret code: {prettier.returncode}\n")
            return list(lines)
        else:
            return [line + "\n" for line in out.decode("utf-8").split("\n")]

    def process(self, lines: Sequence[str]) -> list[str]:
        self.__reset()
        retlines = []
        for line in lines:
            if self.__is_comment(line) or self.__is_code(line):
                retlines.append(line)
                continue

            line = self.__add_head(line)
            line = self.__add_space(line)
            if self.__config["section_number"] in ["h1", "h2"]:
                line = self.__add_index(line)
                line = self.__add_caption(line)

            retlines.append(line)

        if self.__config["prettier"]:
            retlines = self.__prettier_proc(retlines)

        return retlines


def get_input(file) -> list[str]:
    if file:
        with Path(file).open("r", encoding="utf-8") as f:
            return f.readlines()
    else:
        return [line.decode("utf-8") for line in sys.stdin.buffer.readlines()]


def parse_command_line() -> argparse.Namespace:
    parser = argparse.ArgumentParser(sys.argv[0])
    parser.add_argument(
        "--out", "-o", default=None, help="output file name, if ommited, to stdout"
    )
    parser.add_argument(
        "--prettier",
        "-p",
        default=None,
        choices=["yes", "no"],
        help="do not call prettier",
    )
    parser.add_argument(
        "--section-number",
        "-n",
        default=None,
        choices=["no", "h1", "h2"],
        help="whether add section number, and start level h1/h2",
    )
    parser.add_argument("file", nargs="?", help="file name")
    return parser.parse_args(sys.argv[1:])


def gen_formatter(ns: argparse.Namespace, first_line: str) -> MarkdownFormatter:
    config = DEFAULT_CONFIG.copy()
    if mobj := re.match(
        r"""^\s*<!--\s*mdformat\s*:\s*(\{.*\})\s*-->\s*$""", first_line
    ):
        try:
            ret = json.loads(mobj.group(1))
            config |= ret
        except json.JSONDecodeError as e:
            print("parse config failed:", str(e), file=sys.stderr)
            pass

    if ns.prettier is not None:
        config["prettier"] = ns.prettier == "yes"
    if ns.section_number is not None:
        config["section_number"] = ns.section_number

    return MarkdownFormatter(config)


def main():
    ns = parse_command_line()
    file, out = ns.file, ns.out
    lines = get_input(file)
    fmt = gen_formatter(ns, lines[0] if len(lines) > 0 else "")
    lines = fmt.process(lines)
    while lines and lines[-1] == "\n":
        del lines[-1]
    if out:
        Path(out).open("w", encoding="utf-8").writelines(lines)
    else:
        sys.stdout.buffer.writelines([line.encode("utf-8") for line in lines])


if __name__ == "__main__":
    main()
