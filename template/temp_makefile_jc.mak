# author: hulei
#

ifeq ($(OS),Windows_NT)
	SHELL := cmd.exe
else
	SHELL := /bin/sh
endif

SRCDIR := src
DESTDIR := bin

PKGNAME := com.ftsafe.javacard.cardz
PKGAID := 0xD1:0x56:0x00:0x01:0x32:0x0A:0x00:0x01
PKGVER := 1.0

SUPPORT_INT := 1
DEBUG := 1
JCVER ?= 222

#每个应用格式为AID/Name，如果有多个应用，使用空格分隔
APPLET := $(PKGAID):0x01/CardZ

######################################################################################

ifeq ($(JCVER),222)
	JCC := jcc.bat
	JCCVT := jccvt.bat
else
	JCC := jcc$(JCVER).bat
	JCCVT := jccvt$(JCVER).bat
endif

SRCFILES := $(shell ff.py $(SRCDIR) -p *.java)
PKGDIR := $(subst .,/,$(PKGNAME))
CAPNAME := $(notdir $(PKGDIR)).cap
CAPFILE := $(DESTDIR)/$(PKGDIR)/javacard/$(CAPNAME)
DESTFILE := ./$(CAPNAME)
ifeq ($(APPLET),)
	APPFLAGS :=
else
	APPFLAGS := $(foreach applet,$(APPLET),$(subst /, ,-applet $(applet)))
endif

ifeq ($(SUPPORT_INT),1)
	INTFLAGS := -i
else
	INTFLAGS :=
endif

ifeq ($(DEBUG),1)
	JAVADBGFLAGS := -g
	CVTDBGFLAGS := -debug
else
	JAVADBGFLAGS :=
	CVTDBGFLAGS :=
endif


.PHONY : all clean

all:$(DESTFILE)
	@echo all done

$(DESTFILE):$(CAPFILE)
	cp -f $< $@

$(CAPFILE): $(SRCFILES)
	@echo $(CAPFILE)
	if not exist $(DESTDIR) mkdir $(DESTDIR)
	$(JCC) $(JAVADBGFLAGS) -d $(DESTDIR) $^
	$(JCCVT) -classdir bin -d $(DESTDIR) $(INTFLAGS) $(CVTDBGFLAGS) -out JCA CAP EXP $(APPFLAGS) $(PKGNAME) $(PKGAID) $(PKGVER)

clean:
	if exist $(DESTDIR) rm -r -f $(DESTDIR)
	if exist $(DESTFILE) rm -f $(DESTFILE)
	@echo clean done

