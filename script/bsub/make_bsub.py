"""WRapper function to update an sh file with bsub compatibility."""

import os
import yaml
from typing import Dict

def read_params(config_file:str)->Dict:
    """read config for bsub-specific configs"""
    with open(config_file, "r") as file:
        params = yaml.safe_load(file)
    return params

def format_header(params:Dict)->str:
    header_str = "#!/usr/bin/env bash\n" +\
        "set -o errexit\n"+\
        "set -o nounset\n"+\
        "set -o xtrace\n\n"
    for k in params.keys():
        if k == "a":
            header_str += "#BSUB -a \"" + params[k] +"\"\n"
        else:
            header_str += "#BSUB -"+k+" "+str(params[k]) + "\n"
    header_str += "\n"
    return header_str


if __name__ == "__main__":
    x = read_params("./examples/configs/basic_bsub.yml")
    print(x)
    w=format_header(x)
    print("\n"+w)
    

