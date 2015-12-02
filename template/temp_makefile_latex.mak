#author: hulei

ifeq ($(OS),Windows_NT)
	SHELL := cmd.exe
else
	SHELL := /bin/sh
endif

NAME       := test
SRC        := $(NAME).tex
OUT        := out
LATEX      := xelatex
LATEXFLAGS := $(INCFLAGS) -output-directory=$(OUT) -halt-on-error -c-style-errors
SHELL      := cmd.exe
DEST       := $(OUT)/$(NAME).pdf
INCLUDE    := 
INCFLAGS   := $(addprefix --include-directory=,$(INCLUDE))

#对于未使用参考文献和术语缩略语的文档，可以把SIMPLE定义为YES以减少编译时间
SIMPLE     := YES

.PHONY: all clean

all: $(DEST)
	echo all done

$(DEST): $(SRC)
	if not exist $(OUT) mkdir $(OUT)
ifeq ($(SIMPLE),YES)
	$(LATEX) -no-pdf $(LATEXFLAGS) $<
	$(LATEX) $(LATEXFLAGS) $<
else
	$(LATEX) -no-pdf $(LATEXFLAGS) $<
	bibtex $(INCFLAGS) $(OUT)/$(NAME)
	$(LATEX) -no-pdf $(LATEXFLAGS) $<
	-makeindex -s $(OUT)/$(NAME).ist -t $(OUT)/$(NAME).glg -o $(OUT)/$(NAME).gls $(OUT)/$(NAME).glo
	$(LATEX) -no-pdf $(LATEXFLAGS) $<
	$(LATEX) $(LATEXFLAGS) $<
endif

clean:
	-rd /s /q $(OUT)

