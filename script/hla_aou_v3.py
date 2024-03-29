""" Run basic qsubs for the hpylori analysis"""

from pickle import FALSE, TRUE
import sys
import os
import pandas as pd
import re
from script import gen_qsub_wraps as gqw
from script import config_reader as cr
import pysam
import yaml
from typing import Dict


def run_cram(target:str, local:str, chrloc:str)->None:
    """target=target_cram, local="""
    cramfile = pysam.AlignmentFile(target, "rc")
    localcram = pysam.AlignmentFile(local,"wb",template=cramfile)
    for x in cramfile.fetch(chrloc):
        localcram.write(x)
    localcram.close()
    cramfile.close()
    return

def run_cram2(target:str="wgs_10004.cram", local:str="mapped.bam", ref:str="hg38.bed")->None:
    """
    ref=hg38.bed
    local/out=mapped.bam
    target/sample=gs://*/wgs_*.cram
    """
    cramfile = pysam.AlignmentFile(target, "rc")
    localcram = pysam.AlignmentFile(local,"wb",template=cramfile)
    rows = pysam.view("-L",ref,"-o",local,"-b",target)
    for x in rows:
        localcram.write(x)
    localcram.close()
    cramfile.close()
    return

if __name__ == "__main__":
    cfpath = "./examples/configs/basic_config_aou.yml"
    if len(sys.argv) > 1:
        cfpath = sys.argv[1]
    
    [basepath, refloc, dirpath, dirmanifest, manifest_file, \
    ncores, aou_cram, logout, logerr, script_path, outdir, \
	bed, chr_loc, name, fasta, refloc, hlavbseq, jparam, \
	process_hlas, allele, mean_cov, read_len] = cr.get_params(cfpath)
    
    
    manifest = pd.read_excel(dirmanifest + manifest_file)
    samples = manifest.loc[:,"Sample Name"]
    targets = manifest.loc[:,"Target Cram"]

    for k in range( len(samples)):
        # Define indexer offset for antrum or corpus type as matched in sample name
        
        ##Older code - non-AoU runner with 2 fastqs...
        # if 0:
        #     cmd1="bwa mem -a -t " +ncores +" "+refloc+" "+startpath + sample1 + " " +\
        #         startpath + sample2 + " > " + outpath + name + ".sam"
        #     Rout = outpath+name
        
        ##Newer code version with cram file and chr6 sub-selection via pipe:
        #this replaces the cmd1 command above
        bam = samples[k]
        local_cram = bam
        target_cram = targets[k]
        
        if aou_cram:
            run_cram(target_cram, local_cram, chr_loc)
            #set bam to the local cramfile 
            #bam = local_cram
            
        dir2 = outdir+ "d_"+str(k)+"/"
        cmd1="mkdir " + outdir       
        cmd2="samtools view -bo "+dir2+"mapped.bam -L "+bed+" "+bam+""
        cmd3="samtools sort -n -o "+dir2+"sort.bam "+dir2+"mapped.bam"
        cmd3c = "rm "+dir2+"mapped.bam"
        cmd4="samtools fixmate -O bam "+dir2+"sort.bam "+dir2+"fixmate.bam"
        cmd4c = "rm "+dir2+"fixmate.bam"
        cmd5="samtools fastq -n -0 "+dir2+"mapped.0.fastq -s "+dir2+"mapped.s.fastq -1 "+\
            dirpath+"mapped.1.fastq -2 " + dir2 +"mapped.2.fastq "+dir2+"fixmate.bam"
        cmd6="samtools view -bh -f 12 -o "+dir2+"unmapped.bam "+bam+""
        cmd7="samtools fastq -n -0 "+dir2+"unmapped.0.fastq -s "+dir2+"unmapped.s.fastq -1 "+dir2+\
            "/unmapped.1.fastq -2 "+dir2+"unmapped.2.fastq "+dir2+"unmapped.bam"
        #optional: generally unneeded if specifying chr6 for cram subloc
        cmd8="cat "+dir2+"mapped.1.fastq "+dir2+"unmapped.1.fastq > "+dir2+"totest.1.fastq"
        #optional: generally unneeded if specifying chr6 for cram subloc
        cmd9="cat "+dir2+"mapped.2.fastq "+dir2+"unmapped.2.fastq > "+dir2+"totest.2.fastq"
        cmd10="bwa mem -t 8 -P -L 10000 -a "+fasta+" "+dir2+"totest.1.fastq "+dir2+"totest.2.fastq > "+\
            dir2+"totest.sam" # original
        # run HLA-VBSeq
        cmd11="java "+jparam+" -jar "+hlavbseq+" " + fasta + " " + dir2+"totest.sam "+\
            dir2+"result.txt --alpha_zero 0.01 --is_paired"
        # get HLA types
        cmd12="Rscript "+process_hlas+" "+dir2+"result.txt "+allele+" "+mean_cov+" "+read_len+""
        #cmd12c = "rm "
        commands = [cmd2, cmd3, cmd4, cmd5, cmd6, cmd7, cmd8, cmd9, cmd10,cmd11, cmd12]

        filehandle = script_path + bam + ".sh"
        gqw.runner_command(commands,filehandle)
        q = "qsub -l short -pe smp " +ncores+ \
        " -o " + logout +\
        " -e "+ logerr +\
        " " + script_path + bam +".sh"
        print(q)
        print(commands)
