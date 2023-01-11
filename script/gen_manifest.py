
import pandas as pd
import sys

if __name__ == "__main__":
    filex = sys.argv[1]
    fileo = sys.argv[2]
    num_rows = int(sys.argv[3])
    full_data = pd.read_csv(filex,sep=",")
    temp_data = full_data.iloc[0:num_rows,]
    temp_data.rename(columns={"person_id":"ID", "cram_uri":"Target Cram"})
    #temp_data headers are person_id, cram_uri, cram_index_uri
    temp_data["Sample Cram"] = ""
    for k in range(len(temp_data)):
        temp_data.iloc[k, "Sample Cram"] = temp_data.iloc[k,"Target Cram"].split('/')[-1]
    temp_data.to_excel(fileo)
    
    
    