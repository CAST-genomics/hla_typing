""" Run basic qsubs for the hpylori analysis"""

from pickle import FALSE, TRUE
import sys
import os
import pandas as pd
#import subprocess
import re
from script import gen_qsub_wraps as gqw

basepath = "/projects/CEGS/data/mvp/hpylori/"
# refloc = "/frazer01/home/aphodges/software/hpylori/examples/references/Helicobacter_pylori_pangenome_contigs.fa"
# refloc = "/frazer01/home/aphodges/software/hpylori/examples/references/sequence_hpylori_MT5135.fa"
#refloc = "/frazer01/home/aphodges/software/hpylori/examples/references/COVID_19.fa"

# Generated refloc via: cat hg38.fa eco_gcf5845.2_ASM584v2.fa sequence_hpylori_MT5135.fa > combined.fa
refloc = "/frazer01/home/aphodges/software/hpylori/examples/references/combined.fa"
dirpath = basepath + "igm-storage2.ucsd.edu/220829_A00953_0611_BH5W27DSX5/"
outpath = "/frazer01/projects/CEGS/pipeline/mvp_hpylori/samfiles/"
dirmanifest = basepath + "manifests/"
manifest_file = "2022-08-18-Shah-FFPE-DNA-Libs Info.xlsx"
ncores = str(16)

if __name__ == "__main__":
    #id2urlf = pd.read_csv(dirpath + "/pipeline/hla_typing/id2url.txt",sep="\t")
    #first get manifest info and namings
    manifest = pd.read_excel(dirmanifest + manifest_file)
    samples = manifest.loc[:,"Sample Name"]
    
    print(len(samples))
    print(manifest)
    print(samples[0])

    for k in range(len(samples)):
        # Define indexer offset for antrum or corpus type as matched in sample name
        indexer = 18
        flag = TRUE
        if re.search(r'corpus', samples[k]):
            indexer = 36 
            flag = TRUE 
        id = manifest.loc[k,"Sample Code"]
        ids = id.split("_")
        id = ids[0]  ##e.g. this is SS1 --> need to convert it to S19
        id = "S" + str(int(id[2:]) + indexer)
        name = samples[k] + "_"+id +"_L003"
        sample1 = name + "_R1_001.fastq.gz"
        sample2 = name + "_R2_001.fastq.gz"

        ##only run the updated corpus (for now)
        if flag:
            # print(sample1 + " " + sample2)
            command="bwa mem -a -t " +ncores +" "+refloc+" "+dirpath + sample1 + " " + dirpath + sample2 + \
                " > " + outpath + name + ".sam"
            Rout = outpath+name
            # print(command)
            command2 = "samtools sort -@ "+ ncores +" -o "+Rout+".bam " + Rout + ".sam"
            # print(command2)
            command2a = "rm " + Rout + ".sam"
            command2b = "samtools view -f 3 -F 3840 -q 10 -h -o" + Rout+ "_filt10.bam " + Rout + ".bam"
            command2c = "rm "+ Rout +".bam"
            command3 = "samtools index " + Rout + "_filt10.bam"
            command4 = "samtools idxstats "+Rout + "_filt10.bam > " + Rout + "_log.txt"
            command5 = "bamCoverage -b " + Rout + "_filt10.bam " + " -o " + Rout + "_filt10.bw " + \
            "--ignoreDuplicates"
            commands = [command, command2,command2a, command2b, command2c, command3, command4, command5 ] 
            filehandle = "examples/scripts/"+name+".sh"
            # gqw.runner_command(commands,filehandle)
            q = "qsub -l short -pe smp " +ncores+ " " + \
            "-o /frazer01/home/aphodges/software/hpylori/examples/logs/combined_logs.out "+\
            "-e /frazer01/home/aphodges/software/hpylori/examples/logs/combined_logs.err "+\
            "/frazer01/home/aphodges/software/hpylori/examples/scripts/"+name+".sh"
            print(q)
            print(commands)
            # os.system("chmod u+x examples/scripts/*.sh")
            # os.system(q)
