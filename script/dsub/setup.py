"""Dsub setup and configuration."
/usr/bin/python
Setup script in preparation for using the dsub runner in AoU
# Modified from https://workbench.researchallofus.org/workspaces/aou-rw-8ea7b935/howtousedsubintheresearcherworkbenchv6/notebooks/preview/1.%20dsub%20set%20up.ipynb
and 
"""

import os
from datetime import datetime
import pandas as pd

if __name__ == "__main__":
    # copy aou_dsub.bash to home env't and source to bash
    if os.path.isfile("~/aou_dsub.bash"):
        print("Bash runner for dsub already exists.")
    else:
        os.system("echo source ~/aou_dsub.bash >> ~/.bashrc")
    # test runner
    os.system("aou_dsub --help | more")
