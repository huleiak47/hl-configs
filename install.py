#!/usr/bin/env python3
# -*- coding:utf-8 -*-

import os


def main():
    for f in os.listdir("."):
        if os.path.isdir(f) and os.path.isfile(os.path.join(f, "install.bat")):
            try:
                os.chdir(f)
                print(os.path.join(f, "install.bat"))
                os.system("install.bat")
            finally:
                os.chdir("..")


if __name__ == "__main__":
    main()
