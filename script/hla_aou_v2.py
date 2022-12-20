""" Run basic qsubs for the hpylori analysis"""

from pickle import FALSE, TRUE
import sys
import os
import pandas as pd
import re
from script import gen_qsub_wraps as gqw
import pysam


basepath = "./" ##starting basepath is current dir in workflow
refloc = "./hg38.fa"
# startpath = basepath + ""
dirpath = "./output/"
dirmanifest = basepath + "manifests/"
manifest_file =  "" #"2022-08-18-Shah-FFPE-DNA-Libs Info.xlsx"
ncores = str(8)
aou_cram = True

bed = "/frazer01/home/aphodges/reference/hg38.bed"
# bam = outpath + name + ".sam"
target_cram = "gs://fc-aou-datasets-controlled/pooled/wgs/cram/v6_base/wgs_1000004.cram"
local_cram = dirpath + "wgs_1000004.cram"
chr_loc = "chr6"
name = "wgs_1000004_script.sh"

fasta = "/frazer01/home/aphodges/software/my_hla_typing/reference/hg38_v2/hg38.fa"
refloc = fasta
hlavbseq = "/frazer01/home/aphodges/builds/hla_typing/" + "HLAVBSeq.jar"
jparam = "-Xmx12G"
process_hlas = "./script/process_hla_types.R"
allele = "/frazer01/home/aphodges/software/my_hla_typing/reference/alleles.txt"
mean_cov = "5"
read_len = "151"

if __name__ == "__main__":
    manifest = pd.read_excel(dirmanifest + manifest_file)
    samples = manifest.loc[:,"Sample Name"]
    
    print(len(samples))
    print(manifest)
    print(samples[0])

    for k in range( 1 ):   # len(samples)):
        # Define indexer offset for antrum or corpus type as matched in sample name
        
        ##Older code - non-AoU runner with 2 fastqs...
        # if 0:
        #     cmd1="bwa mem -a -t " +ncores +" "+refloc+" "+startpath + sample1 + " " +\
        #         startpath + sample2 + " > " + outpath + name + ".sam"
        #     Rout = outpath+name
        
        ##Newer code version with cram file and chr6 sub-selection via pipe:
        #this replaces the cmd1 command above
        if aou_cram:
            cramfile = pysam.AlignmentFile(target_cram, "rc")
            localcram = pysam.AlignmentFile(local_cram,"wb",template=cramfile)
            for x in cramfile.fetch(chr_loc):
                localcram.write(x)
            localcram.close()
            cramfile.close()
                   
        cmd2="samtools view -bo "+dirpath+"mapped.bam -L "+bed+" "+bam+""
        cmd3="samtools sort -n -o "+dirpath+"sort.bam "+dirpath+"mapped.bam"
        cmd4="samtools fixmate -O bam "+dirpath+"sort.bam "+dirpath+"fixmate.bam"
        cmd5="samtools fastq -n -0 "+dirpath+"mapped.0.fastq -s "+dirpath+"mapped.s.fastq -1 "+\
            dirpath+"mapped.1.fastq -2 " + dirpath +"mapped.2.fastq "+dirpath+"fixmate.bam"
        cmd6="samtools view -bh -f 12 -o "+dirpath+"unmapped.bam "+bam+""
        cmd7="samtools fastq -n -0 "+dirpath+"unmapped.0.fastq -s "+dirpath+"unmapped.s.fastq -1 "+dirpath+\
            "/unmapped.1.fastq -2 "+dirpath+"unmapped.2.fastq "+dirpath+"unmapped.bam"
        #optional: generally unneeded if specifying chr6 for cram subloc
        cmd8="cat "+dirpath+"mapped.1.fastq "+dirpath+"unmapped.1.fastq > "+dirpath+"totest.1.fastq"
        #optional: generally unneeded if specifying chr6 for cram subloc
        cmd9="cat "+dirpath+"mapped.2.fastq "+dirpath+"unmapped.2.fastq > "+dirpath+"totest.2.fastq"
        cmd10="bwa mem -t 8 -P -L 10000 -a "+fasta+" "+dirpath+"totest.1.fastq "+dirpath+"totest.2.fastq > "+\
            dirpath+"totest.sam" # original
        # run HLA-VBSeq
        cmd11="java "+jparam+" -jar "+hlavbseq+" " + fasta + " " + dirpath+"totest.sam "+\
            dirpath+"result.txt --alpha_zero 0.01 --is_paired"
        # get HLA types
        cmd12="Rscript "+process_hlas+" "+dirpath+"result.txt "+allele+" "+mean_cov+" "+read_len+""

        commands = [cmd1, cmd2, cmd3, cmd4, cmd5, cmd6, cmd7, cmd10,cmd11, cmd12]

        filehandle = "examples/scripts/"+name+".sh"
        # gqw.runner_command(commands,filehandle)
        q = "qsub -l short -pe smp " +ncores+ " " + \
        "-o /frazer01/home/aphodges/software/hpylori/examples/logs/combined_logs.out "+\
        "-e /frazer01/home/aphodges/software/hpylori/examples/logs/combined_logs.err "+\
        "/frazer01/home/aphodges/software/hpylori/examples/scripts/"+name+".sh"
        print(q)
        print(commands)
