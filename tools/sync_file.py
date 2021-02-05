#!/usr/bin/env python3
# -*- coding:utf-8 -*-
"""
同步上传工程文件并执行编译命令
"""

import logging as log
import os
import pickle
import sys
import warnings
from pathlib import Path, PurePosixPath

import fire
import paramiko

warnings.filterwarnings("ignore")

# -------------------config ------------------------------------#

SSH_REMOTE_IP = "10.44.244.57"
SSH_REMOTE_PORT = 22
SSH_USER = "hulei"
SSH_PASSWD = "19850923"

LOCAL_DIR = "."
REMOTE_DIR = "/home/hulei/projects/FSPV2"
FILE_IGNORE = [".sync*", ".ycm_*", ".vprj", ".vscode", "*.py1.stats"]

BUILD_CMD = "cd build && cmake .. -DBUILD_TESTS=ON && make -j48"
REBUILD_CMD = "cd build && cmake .. -DBUILD_TESTS=ON && make clean && make -j48"
CLEAN_CMD = "cd build && cmake .. -DBUILD_TESTS=ON && make clean"

# -------------------------------------------------------------#

SYNC_DB = ".sync.db"

DB = {}

LOCAL_DIR_PATH = Path(LOCAL_DIR).absolute()
LOCAL_DIR = str(LOCAL_DIR_PATH).replace("\\", "/")


def walk_dir(root: Path):
    for child in root.iterdir():
        cont = False
        for ignore in FILE_IGNORE:
            if child.match(ignore):
                cont = True
                break
        if cont:
            continue
        if child.is_dir():
            yield from walk_dir(child)
        else:
            yield str(child).replace("\\", "/")


def filter_files(file_list, force=False):
    for f in file_list:
        tm = Path(f).stat().st_mtime_ns
        if f not in DB or tm > DB[f]:
            yield f


def get_rm_files(file_list):
    for f in DB.keys():
        if f not in file_list:
            yield f


def make_parent(sftp, dest, dir_maked):
    dest_parent = str(PurePosixPath(dest).parent)
    if dest_parent in dir_maked:
        log.debug("cache hit!")
        return
    try:
        log.debug("check dir stat: %s" % dest_parent)
        sftp.stat(dest_parent)
        dir_maked[dest_parent] = 1
    except IOError:
        if "/" in dest_parent:
            make_parent(sftp, dest_parent, dir_maked)
        log.info("mkdir %s" % dest_parent)
        sftp.mkdir(dest_parent)
        dir_maked[dest_parent] = 1


def connect_server():
    # 获取Transport实例
    tran = paramiko.Transport((SSH_REMOTE_IP, SSH_REMOTE_PORT))

    # 连接SSH服务端，使用password
    tran.connect(username=SSH_USER, password=SSH_PASSWD)
    return tran


def path_to_remote(f):
    if f.startswith(LOCAL_DIR):
        return REMOTE_DIR + "/" + f[len(LOCAL_DIR) + 1:]
    else:
        return REMOTE_DIR + "/" + f


def upload_files(tran, file_list, rm_list):
    # 获取SFTP实例
    sftp = paramiko.SFTPClient.from_transport(tran)
    dir_maked = {REMOTE_DIR: 1}
    for f in file_list:
        dest = path_to_remote(f)
        make_parent(sftp, dest, dir_maked)
        log.info("put %s %s" % (f, dest))
        sftp.put(f, dest)
        DB[f] = Path(f).stat().st_mtime_ns
    for f in rm_list:
        dest = path_to_remote(f)
        log.info("remove %s" % (dest))
        try:
            pass
            sftp.remove(dest)
        except FileNotFoundError:
            pass
        del DB[f]


def sync(tran, force=False):
    global DB
    file_db = Path(SYNC_DB)
    if not force and file_db.is_file():
        DB = pickle.loads(file_db.read_bytes())

    files = list(walk_dir(LOCAL_DIR_PATH))
    up_files = list(filter_files(files, force))
    rm_files = list(get_rm_files(files))

    if not up_files and not rm_files:
        log.debug("no file to upload")
        return
    upload_files(tran, up_files, rm_files)
    Path(SYNC_DB).write_bytes(pickle.dumps(DB))


def init_db():
    for f in walk_dir(LOCAL_DIR_PATH):
        tm = Path(f).stat().st_mtime_ns
        DB[f] = tm
    Path(SYNC_DB).write_bytes(pickle.dumps(DB))


def do_action(tran, cmd):
    ssh = paramiko.SSHClient()
    ssh._transport = tran
    log.info("remote run: %s" % cmd)
    stdin, stdout, stderr = ssh.exec_command("cd " + REMOTE_DIR + " && " + cmd)
    out1 = stderr.read().decode("utf-8", 'replace').encode('gbk',
                                                           'replace').decode('gbk').replace(REMOTE_DIR, LOCAL_DIR)
    out2 = stdout.read().decode("utf-8", 'replace').encode('gbk',
                                                           'replace').decode('gbk').replace(REMOTE_DIR, LOCAL_DIR)
    sys.stdout.write(out1)
    sys.stdout.write(out2)


def main(action="build", force=False, verbose=False):
    if verbose:
        log.basicConfig(level=log.DEBUG)
    else:
        log.basicConfig(level=log.INFO)

    if not LOCAL_DIR_PATH.is_dir():
        raise Exception("%s is not a dir!" % (LOCAL_DIR))
    os.chdir(LOCAL_DIR)
    if action == "init":
        init_db()
    elif action == "sync":
        tran = connect_server()
        try:
            sync(tran, force)
        finally:
            tran.close()
    elif action in ["build", "rebuild", "clean"]:
        cmd = {"build": BUILD_CMD, "rebuild": REBUILD_CMD, "clean": CLEAN_CMD}[action]
        tran = connect_server()
        try:
            sync(tran, force)
            do_action(tran, cmd)
        finally:
            tran.close()
    else:
        raise Exception("action %s not support!" % action)


if __name__ == "__main__":
    fire.Fire(main)
