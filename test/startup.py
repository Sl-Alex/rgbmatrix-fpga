#!/usr/bin/env python3

import sys,os

def init():
    parentdir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
    if parentdir not in sys.path:
        sys.path.insert(0, parentdir)
