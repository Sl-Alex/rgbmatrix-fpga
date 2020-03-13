#!/usr/bin/env python3

import os
from shutil import copyfile

def init():
    # Copy configuration script to this folder
    if not os.path.exists("./config.py"):
        copyfile("../vhdl/config.py", "./config.py")

if __name__ == "__main__": 
    init()