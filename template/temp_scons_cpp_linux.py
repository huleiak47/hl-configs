#!/usr/bin/python
#-*- coding:utf-8 -*-

def arg(name, default):
    globals()[name] = type(default)(ARGUMENTS.get(name, default))

arg("TOOLSET"   , "gcc")  # "gcc" or "msvc"
arg("DEST_NAME" , "demo")
arg("DEST_TYPE" , 0)      # "program" = 0   , "sharedlib" = 1 , "staticlib" = 2
arg("BIN_PATH"  , "bin")
arg("TMP_PATH"  , "obj")

CPPDEFINES    = ["", "", ""] # [common, debug, release]
LIBS          = ["", "", ""]
CCFLAGS       = ["", "", ""]
LINKFLAGS     = ["", "", ""]

SRC_SUFFIX    = ".c .cpp .cxx .cc .c++ .rc .def"
SRC_EXCLUDE   = []      # excluded file names
INC_PATH      = ['.']   # include paths used for compiler
SRC_PATH      = ['.']   # source file searching paths, you can use * and ** as search pattern
LIB_PATH      = []      # library paths used for linker

arg("GUI", 0)           # GUI or CONSOLE
arg("RTTI", 1)          # support RTTI in C++
arg("EXCEPTION", 1)     # support EXCEPTION in C++
arg("USE_WXWIDGETS", 0) # use wxwidgets library, auto set macros and library
arg("PROFILE", 0)       # profile for gcc debug config only
arg("COVERAGE", 0)      # coverage for gcc debug config only
arg("STRICT", 1)        # strict compiler flags, treat some waring as error
arg("USE_C99", 1)       # use C99, else use C89, for gcc C file only
arg("USE_CXX11", 1)     # use C++11, else use C++98/03, for gcc C++ file only
arg("CLANG_COMP", 1)    # use "scons clang" command to generate .clang_complete file
arg("INSTALL", "")      # If set, the install path must have three subdir: bin, include, lib. If DEST_TYPE is 1 or 2, the files in ./include will copy to {INSTALL}/include
arg("UPX", 0)           # use upx to compress dest file when install
arg("GCC_VER", "4.8.2")

DEFAULT       = "debug" # default build target, you can set "debug", "release", "all", "install", "clang"

############################## default config #####################################

DFT_CPPDEFINES     = ["", "", "NDEBUG"]
DFT_LIBS = ["", "", ""]
if USE_WXWIDGETS:
    DFT_CPPDEFINES[0] += " `wx-config --cxxflags`"
    DFT_LIBS[0] += " `wx-config --libs"

DFT_CCFLAGS    = ["-Wall -pipe", "-gdwarf-4 -g3 -O0", "-O3"]
if DEST_TYPE == 1:
    DFT_CCFLAGS[0] += " -fPIC"
if STRICT:
    DFT_CCFLAGS[0] += " -Werror=implicit-function-declaration -Werror=return-type -Werror=return-local-addr"
if PROFILE:
    DFT_CCFLAGS[1] += " -pg"
if COVERAGE:
    DFT_CCFLAGS[1] += " -fprofile-arcs -ftest-coverage"
    DFT_LIBS[1] += " gcov"

DFT_CFLAGS     = ["", "", ""]
if USE_C99:
    DFT_CFLAGS[0] += " -std=c99"
else:
    DFT_CFLAGS[0] += " -std=c89"

DFT_CXXFLAGS   = ["", "", ""]
if USE_CXX11:
    DFT_CXXFLAGS[0] += " -std=c++11"
else:
    DFT_CXXFLAGS[0] += " -std=c++03"
if RTTI:
    DFT_CXXFLAGS[0] += " -frtti"
else:
    DFT_CXXFLAGS[0] += " -fno-rtti"
if EXCEPTION:
    DFT_CXXFLAGS[0] += " -fexceptions"
else:
    DFT_CXXFLAGS[0] += " -fno-exceptions"

DFT_LINKFLAGS = ["-Wl,-Map,${RMEXT(TARGET)}.map", "", "-s"]
if PROFILE:
    DFT_LINKFLAGS[1] += " -pg"


############################### ENV #######################################3
import os, sys
path = os.path
from copy import copy

def _rmext(filepath):
    ret = path.splitext(str(filepath))[0]
    return ret

base_env = Environment(
    ENV        = os.environ,
    CPPPATH    = INC_PATH,
    CPPDEFINES = Split(CPPDEFINES[0]) + Split(DFT_CPPDEFINES[0]),
    CCFLAGS    = Split(CCFLAGS[0]) + Split(DFT_CCFLAGS[0]),
    CFLAGS     = Split(DFT_CFLAGS[0]),
    CXXFLAGS   = Split(DFT_CXXFLAGS[0]),
    LINKFLAGS  = Split(LINKFLAGS[0]) + Split(DFT_LINKFLAGS[0]),
    LIBPATH    = LIB_PATH,
    LIBS       = Split(LIBS[0]) + Split(DFT_LIBS[0]),
    RMEXT      = _rmext,
    )

debug_env = base_env.Clone()
debug_env.Append(
    NAME       = "debug",
    CPPDEFINES = Split(CPPDEFINES[1]) + Split(DFT_CPPDEFINES[1]),
    CCFLAGS    = Split(CCFLAGS[1]) + Split(DFT_CCFLAGS[1]),
    CFLAGS     = Split(DFT_CFLAGS[1]),
    CXXFLAGS   = Split(DFT_CXXFLAGS[1]),
    LINKFLAGS  = Split(LINKFLAGS[1]) + Split(DFT_LINKFLAGS[1]),
    LIBS       = Split(LIBS[1]) + Split(DFT_LIBS[1]),
    )
release_env = base_env.Clone()
release_env.Append(
    NAME       = "release",
    CPPDEFINES = Split(CPPDEFINES[2]) + Split(DFT_CPPDEFINES[2]),
    CCFLAGS    = Split(CCFLAGS[2]) + Split(DFT_CCFLAGS[2]),
    CFLAGS     = Split(DFT_CFLAGS[2]),
    CXXFLAGS   = Split(DFT_CXXFLAGS[2]),
    LINKFLAGS  = Split(LINKFLAGS[2]) + Split(DFT_LINKFLAGS[2]),
    LIBS       = Split(LIBS[2]) + Split(DFT_LIBS[2]),
    )

################################################################################################
def search_path(pathitems, suffixes, excludes):
    ret = []
    for i in xrange(len(pathitems)):
        if pathitems[i] == "*":
            basedir = "/".join(pathitems[:i])
            if not path.isdir(basedir):
                return ret
            for d in os.listdir(basedir):
                if path.isdir(path.join(basedir, d)):
                    items = copy(pathitems)
                    items[i] = d
                    ret.extend(search_path(items, suffixes, excludes))
            return ret
        if pathitems[i] == "**":
            basedir = "/".join(pathitems[:i])
            if not path.isdir(basedir):
                return ret
            for root, dirs, files in os.walk(basedir):
                items = copy(pathitems)
                items[i] = path.relpath(root, basedir)
                ret.extend(search_path(items, suffixes, excludes))
            return ret
    basedir = "/".join(pathitems)
    if not path.isdir(basedir):
        return ret
    for f in os.listdir(basedir):
        f = path.normpath(f)
        if f not in excludes:
            pp = '/'.join([basedir, f])
            if (path.splitext(pp)[1] in suffixes) and path.isfile(pp):
                ret.append(path.normpath(pp))
    return ret

def findfiles(paths, suffixes, excludes):
    ret = []
    suffixes = map(path.normpath, suffixes)
    excludes = map(path.normpath, excludes)
    for p in paths:
        ret += search_path(p.replace("\\", "/").split("/"), suffixes, excludes)
    ret = list(set(ret))
    ret.sort()
    return tuple(ret)

#find gcc path
def find_gcc_inc_path():
    path1 = os.environ.get("C_INCLUDE_PATH", "")
    path2 = os.environ.get("CPLUS_INCLUDE_PATH", "")
    paths = path1.split(";") + path2.split(";")
    paths = set(filter(lambda p: p, paths))
    return tuple(paths)

GCC_INC_PATH = find_gcc_inc_path()

sourcefiles = findfiles(SRC_PATH, Split(SRC_SUFFIX), SRC_EXCLUDE)

alldest = []
objdict = {}

for env in [debug_env, release_env]:
    objs = {}
    for sf in sourcefiles:
        args = path.join(TMP_PATH, env["NAME"], path.splitext(path.basename(sf))[0] + env["OBJSUFFIX"]), sf
        objs[sf] = env.Object(*args)
        Clean(objs[sf], map(lambda ext: _rmext(str(objs[sf][0])) + ext, ['.asm', '.s', '.gcno', '.gcda', '.pdb']))
    DEST_PATH = path.join(BIN_PATH, env["NAME"], DEST_NAME)
    if DEST_TYPE == 2:
        dest = env.Library(DEST_PATH, objs.values())
    elif DEST_TYPE == 1:
        dest = env.SharedLibrary(DEST_PATH, objs.values())
    else:
        dest = env.Program(DEST_PATH, objs.values())
    Clean(dest, map(lambda ext: _rmext(str(dest[0])) + ext, ['.exp', '.ilk', '.map', '.pdb', '.manifest']))
    alldest.append(Alias(env["NAME"], dest))
    if env["NAME"] == DEFAULT:
        objdict = objs
    if env["NAME"] == "release" and INSTALL:
        if DEST_TYPE == 2: #static lib
            libinstall = env.Install(INSTALL + "/lib", dest)
            bininstall = []
        elif DEST_TYPE == 1: #shared lib
            libinstall = env.Install(INSTALL + "/lib", dest[1])
            bininstall = env.Install(INSTALL + "/bin", dest[0])
        else:               #program
            libinstall = []
            bininstall = env.Install(INSTALL + "/bin", dest)

        if DEST_TYPE != 0:
            headers = findfiles(["./include/**"], [".h", ".hpp", ".hxx", ".hh", ".h++"], [])
            incinstall = [env.InstallAs(INSTALL + "/" + h, h) for h in headers]
        else:
            incinstall = []
        Alias("install", libinstall + bininstall + incinstall)

for k, v in objdict.items():
    Alias(os.path.basename(k), v)

Alias("all", alldest)

def make_clang_complete(target, source, env):
    with open(str(target[0]), "w") as f:
        for DEF in debug_env["CPPDEFINES"]:
            print >> f, "-D{}".format(DEF)
        for INC in INC_PATH:
            print >> f, "-I{}".format(INC)
    return None

if CLANG_COMP:
    clang_complete = Command(
        "./.clang_complete",
        "./SConstruct",
        make_clang_complete
        )
    Alias("clang", clang_complete)

Default(DEFAULT)

