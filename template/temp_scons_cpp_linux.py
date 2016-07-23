#!/usr/bin/python
#-*- coding:utf-8 -*-

def arg(name, default):
    globals()[name] = type(default)(ARGUMENTS.get(name, default))
    return globals()[name]

arg("TOOLSET"   , "clang") # gcc or clang
arg("DEST_NAME" , "demo")
arg("DEST_TYPE" , 0)      # "program" = 0   , "sharedlib" = 1 , "staticlib" = 2
arg("BIN_PATH"  , "bin")
arg("TMP_PATH"  , "obj")

CPPDEFINES    = ["" + arg('CPPDEFINES', ""), "", ""] # [common, debug, release]
LIBS          = ["" + arg('LIBS', ""), "", ""]
CCFLAGS       = ["" + arg('CCFLAGS', ""), "", ""]
LINKFLAGS     = ["" + arg('LINKFLAGS', ""), "", ""]

SRC_SUFFIX    = ".c .cpp .cxx .cc .c++"
SRC_EXCLUDE   = [""]      # excluded file names
INC_PATH      = ['.']   # include paths used for compiler
SRC_PATH      = ['.']   # source file searching paths, you can use * and ** as search pattern
LIB_PATH      = []      # library paths used for linker

arg("GUI", 1)           # GUI or CONSOLE
arg("RTTI", 1)          # support RTTI in C++
arg("EXCEPTION", 1)     # support EXCEPTION in C++
arg("USE_WXWIDGETS", 1) # use wxwidgets library, auto set macros and library
arg("PROFILE", 0)       # profile for gcc debug config only
arg("COVERAGE", 0)      # coverage for gcc debug config only
arg("STRICT", 1)        # strict compiler flags, treat some waring as error
arg("USE_C99", 1)       # use C99, else use C89, for gcc C file only
arg("USE_CXX11", 1)     # use C++11, else use C++98/03, for gcc C++ file only
arg("CLANG_COMP", 1)    # use "scons clang" command to generate .clang_complete file
arg("YCM", 1)           # use "scons ycm" command to generate .ycm_extra_conf.py file
arg("YCMPATH", ".")     # set the path of .ycm_exra_conf.py
arg("INSTALL", ".")     # If set, the install path must have three subdir: bin, include, lib. If DEST_TYPE is 1 or 2, the files in ./include will copy to {INSTALL}/include
arg("UPX", 0)           # use upx to compress dest file when install

DEFAULT       = "debug" # default build target, you can set "debug", "release", "all", "install", "clang"

############################## default config #####################################

import os

if TOOLSET == "gcc":
    base_env = Environment(
        ENV                    = os.environ,
        tools                  = ['default'],
        TARGET_ARCH            = "x86",
        )
elif TOOLSET == "clang":
    base_env = Environment(
        ENV                    = os.environ,
        tools                  = ['default'],
        TARGET_ARCH            = "x86",
        CC = 'clang',
        CXX = 'clang++',
        )


import subprocess as sp

wx_cpp_flags = sp.check_output("wx-config --cxxflags", shell=1)
wx_link_flags = sp.check_output("wx-config --libs", shell=1)

DFT_CPPDEFINES     = ["", "", "NDEBUG"]

DFT_LIBS = ["", "", ""]

DFT_CCFLAGS    = ["-Wall", "-gdwarf-4 -g3 -O0", "-O3"]
if STRICT:
    DFT_CCFLAGS[0] += " -Werror=implicit-function-declaration -Werror=return-type -Werror=uninitialized -Werror=delete-non-virtual-dtor"
    if TOOLSET == "gcc":
        DFT_CCFLAGS[0] += " -Werror=return-local-addr"
    elif TOOLSET == "clang":
        DFT_CCFLAGS[0] += " -Werror=return-stack-address"
if PROFILE:
    if TOOLSET == "gcc":
        DFT_CCFLAGS[1] += " -pg"
    else:
        DFT_CCFLAGS[1] += " -fprofile-instr-generate"
if COVERAGE:
    if TOOLSET == "gcc":
        DFT_CCFLAGS[1] += " -fprofile-arcs -ftest-coverage"
        DFT_LIBS[1] += " gcov"
    else:
        DFT_CCFLAGS[1] += " -fprofile-instr-generate -fcoverage-mapping"

DFT_CFLAGS     = ["", "", ""]
if USE_C99:
    DFT_CFLAGS[0] += " -std=c99"
else:
    DFT_CFLAGS[0] += " -std=c89"

DFT_CXXFLAGS   = ["", "", ""]
if USE_WXWIDGETS:
    DFT_CXXFLAGS[0] += " " + wx_cpp_flags #" wxUSE_UNICODE UNICODE _UNICODE "
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

DFT_LINKFLAGS = [" -Wl,-Map,${RMEXT(TARGET)}.map ", "", "-s"]
if USE_WXWIDGETS:
    DFT_LINKFLAGS[0] += " " + wx_link_flags
if PROFILE:
    DFT_LINKFLAGS[1] += " -pg"

############################### ENV #######################################3
import sys
path = os.path
from copy import copy

def _rmext(filepath):
    ret = path.splitext(str(filepath))[0]
    return ret

base_env.Append(
    RMEXT                  = _rmext,
    WINDOWS_EMBED_MANIFEST = (0 if TOOLSET != 'msvc' or MSVC_VER not in ["7.0", "7.1", "8.0", "9.0"] else 1),
    CPPPATH                = INC_PATH,
    CPPDEFINES             = Split(CPPDEFINES[0]) + Split(DFT_CPPDEFINES[0]),
    CCFLAGS                = Split(CCFLAGS[0]) + Split(DFT_CCFLAGS[0]),
    CFLAGS                 = Split(DFT_CFLAGS[0]),
    CXXFLAGS               = Split(DFT_CXXFLAGS[0]),
    LINKFLAGS              = Split(LINKFLAGS[0]) + Split(DFT_LINKFLAGS[0]),
    LIBPATH                = LIB_PATH,
    LIBS                   = Split(LIBS[0]) + Split(DFT_LIBS[0]),
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
    #if use windres you should set the path in command line, it will not search files from the environment variables
    if TOOLSET == "gcc":
        env['RCINCFLAGS'] = env['RCINCFLAGS'] + "".join(map(lambda p: " " + env['RCINCPREFIX'] + " " + p, GCC_INC_PATH))

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
            if TOOLSET == "gcc":
                libinstall += env.InstallAs(INSTALL + "/lib/" + DEST_NAME + ".lib", dest[1])
            else: # msvc
                libinstall += env.InstallAs(INSTALL + "/lib/lib" + DEST_NAME + ".a", dest[1])
            if UPX:
                bininstall = env.Command(INSTALL + "/bin/" + DEST_NAME + ".dll", dest[0], ["upx -9 -o $TARGET $SOURCE"])
            else:
                bininstall = env.Install(INSTALL + "/bin", dest[0])
        else:               #program
            libinstall = []
            if UPX:
                bininstall = env.Command(INSTALL + "/bin/" + DEST_NAME + ".exe", dest, ["upx -9 -o $TARGET $SOURCE"])
            else:
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
        if USE_CXX11:
            print >> f, "-std=c++11"
    return None

if CLANG_COMP:
    clang_complete = Command(
        "./.clang_complete",
        "./SConstruct",
        make_clang_complete
        )
    Alias("clang", clang_complete)

def make_ycm_config(target, source, env):
    is_cpp = False
    for source in sourcefiles:
        if os.path.splitext(source)[1].lower() in [".cpp", ".cxx", ".c++"]:
            is_cpp = True
            break

    with open(str(target[0]), "w") as f:
        def printflag(flag):
            print >> f, "    '%s'," % flag

        print >> f, """
import os
import ycm_core
flags = [
    '-Wall',
    '-Wextra',
    '-Werror',
    '-fexceptions',
    '-DNDEBUG',"""
        for DEF in debug_env["CPPDEFINES"]:
            printflag("-D{}".format(DEF))
        for INC in INC_PATH:
            printflag("-I")
            printflag(os.path.relpath(os.path.abspath(INC), start=YCMPATH))
        if USE_WXWIDGETS:
            for flag in wx_cpp_flags.split():
                printflag(flag)
        if is_cpp:
            printflag("-x")
            printflag("c++")
            if USE_CXX11:
                printflag("-std=c++11")
            else:
                printflag("-std=c++03")
        else:
            printflag("-x")
            printflag("c")
            if USE_C99:
                printflag("-std=c99")
            else:
                printflag("-std=c89")
        print >> f, "]"

        print >> f, """
compilation_database_folder = ''

if os.path.exists(compilation_database_folder):
    database = ycm_core.CompilationDatabase(compilation_database_folder)
else:
    database = None

SOURCE_EXTENSIONS = ['.cpp', '.cxx', '.cc', '.c', '.m', '.mm']


def DirectoryOfThisScript():
    return os.path.dirname(os.path.abspath(__file__))


def MakeRelativePathsInFlagsAbsolute(flags, working_directory):
    if not working_directory:
        return list(flags)
    new_flags = []
    make_next_absolute = False
    path_flags = ['-isystem', '-I', '-iquote', '--sysroot=']
    for flag in flags:
        new_flag = flag

        if make_next_absolute:
            make_next_absolute = False
            if not flag.startswith('/'):
                new_flag = os.path.join(working_directory, flag)

        for path_flag in path_flags:
            if flag == path_flag:
                make_next_absolute = True
                break

            if flag.startswith(path_flag):
                path = flag[len(path_flag):]
                new_flag = path_flag + os.path.join(working_directory, path)
                break

        if new_flag:
            new_flags.append(new_flag)
    return new_flags


def IsHeaderFile(filename):
    extension = os.path.splitext(filename)[1]
    return extension in ['.h', '.hxx', '.hpp', '.hh']


def GetCompilationInfoForFile(filename):
    # The compilation_commands.json file generated by CMake does not have entries
    # for header files. So we do our best by asking the db for flags for a
    # corresponding source file, if any. If one exists, the flags for that file
    # should be good enough.
    if IsHeaderFile(filename):
        basename = os.path.splitext(filename)[0]
        for extension in SOURCE_EXTENSIONS:
            replacement_file = basename + extension
            if os.path.exists(replacement_file):
                compilation_info = database.GetCompilationInfoForFile(
                    replacement_file)
                if compilation_info.compiler_flags_:
                    return compilation_info
        return None
    return database.GetCompilationInfoForFile(filename)


# This is the entry point; this function is called by ycmd to produce flags for
# a file.
def FlagsForFile(filename, **kwargs):
    if database:
        # Bear in mind that compilation_info.compiler_flags_ does NOT return a
        # python list, but a "list-like" StringVec object
        compilation_info = GetCompilationInfoForFile(filename)
        if not compilation_info:
            return None

        final_flags = MakeRelativePathsInFlagsAbsolute(
            compilation_info.compiler_flags_,
            compilation_info.compiler_working_dir_)
    else:
        relative_to = DirectoryOfThisScript()
        final_flags = MakeRelativePathsInFlagsAbsolute(flags, relative_to)

    return {
        'flags': final_flags,
        'do_cache': True
    }
"""

if YCM:
    ycm_config = Command(
        os.path.join(YCMPATH, ".ycm_extra_conf.py"),
        "./SConstruct",
        make_ycm_config
        )
    Alias("ycm", ycm_config)

Default(DEFAULT)
