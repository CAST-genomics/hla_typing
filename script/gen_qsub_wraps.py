"""Generates the qsub wrappers for usage in submitting jobs.

Cloned from hpylori repo for hla run.
"""

import pandas as pd 
import numpy as np
from typing import List

def somefunction(_filename:str, _colnames:List[str], _sep:str="\t" )->pd.DataFrame:
    mydata = pd.read_csv(_filename, sep=_sep)
    mydata.columns = _colnames

# x=somefunction(myfilename)

def gen_header_string()->str:
    """Generate header string info for .sh files"""
    strx = "#!/bin/bash\n" + \
    "#$ -N hpylori\n" + \
    "#$ -pe smp 3\n" + \
    "#$ -l short\n" + \
    "#$ -V\n"
    # "#$ -cwd\n"
    strx = strx + "source /frazer01/home/aphodges/.bashrc\n\n"
    return strx

def add_commands(list_commands:List,header:str)->str:
    """Add commands passed in iteratively to str"""
    outx = ""
    outx = header
    for k in list_commands:
        outx = outx + "mycommand=\""+ k + "\"; eval $mycommand \n"
    return outx

def write_commands(mystr:str, filehandle:str)->None:
    """write commands to file"""
    text_file = open(filehandle, "w")
    n = text_file.write(mystr)
    text_file.close()
    return

def runner_command(commands:List, filehandle:str,)->None:
    """Run the commands"""
    head = gen_header_string()
    cmd = add_commands(commands, head)
    print(cmd)
    print(filehandle)
    write_commands(cmd, filehandle)
    return

if __name__ == "__main__":
    filehandle = "examples/scripts/test1.sh"
    mycommands = ["echo 'Hello world!'","date"]
    runner_command(mycommands,filehandle)

