#!/usr/bin/env python3
# -*- coding:utf-8 -*-
"""
format markdown after prettier.
"""

import re
import subprocess as sp
import sys
from collections import defaultdict
from pathlib import Path

import fire


class MarkdownFormatter:
    def __init__(self):
        self.__reset()

    def __reset(self):
        self.code = False
        self.comment = False
        self.index = defaultdict(int)
        self.cap_index = defaultdict(int)

    def __is_comment(self, line):
        if line.strip().startswith("<!--"):
            self.comment = True
            return True
        if line.strip().endswith("-->"):
            self.comment = False
            return True
        return self.comment

    def __is_code(self, line):
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
        return re.sub(r'''([^`]?)(`.+?`)([^`]?)''', self.__repl_add_space,
                      line)

    def __update_index_and_gen_number(self, section):
        self.index[section] += 1
        for i in range(len(section) + 1, 10):
            self.index['#' * i] = 0
        if section == '##':
            self.cap_index = defaultdict(int)

        ret = []
        for i in range(2, len(section) + 1):
            ret.append(str(self.index['#' * i]))

        return ".".join(ret)

    def __add_index(self, line):
        # `##` 作为第一级章节
        mobj = re.match(
            r'''^(##+)\s*(?:(?:[0-9]{1,2}\.)*[0-9]{1,2}\s+)?(.*)''', line,
            re.DOTALL)
        if not mobj:
            return line

        section = mobj.group(1)
        number = self.__update_index_and_gen_number(section)
        return " ".join((section, number, mobj.group(2)))

    def __add_caption(self, line):
        mobj = re.match(r'''^:\s*([^\s]+)\s+(?:[0-9]+[-][0-9]+\s+)?(.*)''', line)
        if not mobj:
            mobj = re.match(
                r'''^\s*<div\s+class\s*=\s*"caption"\s*>\s*([^\s]+)\s+(?:[0-9]+[-][0-9]+)\s+(.*?)</div>''',
                line)
        if not mobj:
            return line
        tag = mobj.group(1)
        caption = mobj.group(2)
        self.cap_index[tag] += 1
        return '<div class="caption">{} {}-{} {}</div>\n'.format(
            tag, self.index['##'], self.cap_index[tag], caption)

    def process(self, lines):
        self.__reset()
        retlines = []
        for line in lines:
            if self.__is_comment(line) or self.__is_code(line):
                retlines.append(line)
                continue

            line = self.__add_space(line)
            line = self.__add_index(line)
            line = self.__add_caption(line)

            retlines.append(line)

        return retlines


def prettier_proc(lines):
    prettier = sp.Popen(["prettier", "--parser", "markdown"],
                        stdin=sp.PIPE,
                        stdout=sp.PIPE,
                        shell=True)
    out = prettier.communicate(input="".join(lines).encode("utf-8"))[0]
    if prettier.returncode != 0:
        sys.stderr.write("call prettier failed.\n")
        return lines
    else:
        return [line + "\n" for line in out.decode("utf-8").split("\n")]


def get_input(file):
    if file:
        with Path(file).open("r", encoding="utf-8") as f:
            return f.readlines()
    else:
        return [line.decode('utf-8') for line in sys.stdin.buffer.readlines()]


def main(file=None):
    fmt = MarkdownFormatter()
    lines = get_input(file)
    lines = prettier_proc(lines)
    lines = fmt.process(lines)
    while lines and lines[-1] == "\n":
        del lines[-1]
    sys.stdout.buffer.writelines([line.encode('utf-8') for line in lines])


if __name__ == "__main__":
    fire.Fire(main)
