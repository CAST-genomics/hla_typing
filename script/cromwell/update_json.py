"""Json updater

Important for AoU to update in jupyter w/in environment the 
respective bucket information
"""
import json
import sys
from typing import Dict, List

def read_json(inputfile:str)->Dict:
    """read in the json and return dict"""
    with open(inputfile) as json_file:
        data = json.loads(json_file)
    return data

def add_params(inputdict:Dict, params:str)->Dict:
    """this will parse the formatted string and add to dictionary, 
    Then convert to and return the json
    """
    list_of_params = params.split(";")
    for k in list_of_params:
        # each k is a unique parameter which should split on ':'
        myout = []
        myout = k.split(':') 
        #here there should be 2 items in myout: [paramname,value/location]
        inputdict[ myout[0] ] = myout[1]
    return inputdict

def write_json(outputdict:Dict, fileout:str, flag:str=True )->None:
    """write final json to file, optional print"""
    outputjson = json.dumps(outputdict,dep)
    if flag:
        print(outputjson)
    with open(fileout, "w") as outfile:
        json.dump(outputjson, outfile)
    return

if __name__ == "__main__":
    ## get the inputfile, outputfile, params_string as inputs
    inputjson = sys.argv[1] #input json name
    output = sys.argv[2] #output json name
    params = sys.argv[3]
    dictin = read_json(inputjson)
    updated = add_params(dictin, params)
    write_json(updated, output, True)

