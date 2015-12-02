#coding:utf-8

def arg(name, default):
    globals()[name] = type(default)(ARGUMENTS.get(name, default))
    return globals()[name]

arg(u"NAME", u"test")
arg(u"TOC", 0) # table of content (only for html)
arg(u"CN", 0) # is chinese content (indent of paragraph)
arg(u"NUMBER", 0)
arg(u"DESTNAME", NAME)
arg(u"SOURCE", NAME + u".md")


PANDOC_FLAG = []
if CN:
    PANDOC_FLAG.append(u"-V cn=1")
if NUMBER:
    PANDOC_FLAG.append(u"-N")

PANDOC_FLAG = u" ".join(PANDOC_FLAG)
HTML_FLAG = PANDOC_FLAG
if TOC:
    HTML_FLAG += u" --toc"

import os
env = Environment(ENV = os.environ)

html = env.Command(DESTNAME + u".html", SOURCE,
                   [u"pandoc -t html -s -S %s --template=default -o $TARGET $SOURCE" % HTML_FLAG])

pdf = env.Command(DESTNAME + u".pdf", SOURCE, [
    u"pandoc -t html -s -S %s --template=prince -o ${TARGET}.tmp $SOURCE" % PANDOC_FLAG,
    u"prince ${TARGET}.tmp -o $TARGET",
    Delete(u"${TARGET}.tmp"),
])
env.Clean(pdf, str(pdf[0]) + ".tmp")

docx = env.Command(DESTNAME + u".docx", SOURCE,
                   [u"pandoc -t docx -s -S %s -o $TARGET $SOURCE" % PANDOC_FLAG])

Alias(u"docx", docx)
Alias(u"html", html)
Alias(u"pdf", pdf)
Alias(u"all", [docx, html, pdf])

Default(u"html")
