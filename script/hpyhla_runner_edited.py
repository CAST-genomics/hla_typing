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
startpath = basepath + "igm-storage2.ucsd.edu/220829_A00953_0611_BH5W27DSX5/"
dirpath = "/frazer01/home/aphodges/test_hlahpy/"
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

    for k in range( 1 ):   # len(samples)):
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
        bed = "/frazer01/home/aphodges/reference/hg38.bed"
        bam = outpath + name + ".sam"
        fasta = "/frazer01/home/aphodges/software/my_hla_typing/reference/hg38_v2/hg38.fa"
        refloc = fasta
        hlavbseq = "/frazer01/home/aphodges/builds/hla_typing/" + "HLAVBSeq.jar"
        jparam = "-Xmx12G"
        process_hlas = "./script/process_hla_types.R"
        allele = "/frazer01/home/aphodges/software/my_hla_typing/reference/alleles.txt"
        mean_cov = "5"
        read_len = "151"

        # fasta="/frazer01/home/aphodges/software/my_hla_typing/reference/${fasta_type}/alleles.${fasta_type}.fasta"
        # bed="/frazer01/home/aphodges/software/my_hla_typing/reference/${build}.bed"
        # ref_fasta="/frazer01/home/aphodges/software/my_hla_typing/reference/hg38_v2/hg38.fa"

        ##only run the updated corpus (for now)
        if flag:
            # print(sample1 + " " + sample2)
            cmd1="bwa mem -a -t " +ncores +" "+refloc+" "+startpath + sample1 + " " +\
                startpath + sample2 + " > " + outpath + name + ".sam"
            Rout = outpath+name
            # print(command)
                        
            cmd2="samtools view -bo "+dirpath+"mapped.bam -L "+bed+" "+bam+""
            cmd3="samtools sort -n -o "+dirpath+"sort.bam "+dirpath+"mapped.bam"
            cmd4="samtools fixmate -O bam "+dirpath+"sort.bam "+dirpath+"fixmate.bam"
            cmd5="samtools fastq -n -0 "+dirpath+"mapped.0.fastq -s "+dirpath+"mapped.s.fastq -1 "+\
                dirpath+"mapped.1.fastq -2 " + dirpath +"mapped.2.fastq "+dirpath+"fixmate.bam"
            cmd6="samtools view -bh -f 12 -o "+dirpath+"unmapped.bam "+bam+""
            cmd7="samtools fastq -n -0 "+dirpath+"unmapped.0.fastq -s "+dirpath+"unmapped.s.fastq -1 "+dirpath+\
                "/unmapped.1.fastq -2 "+dirpath+"unmapped.2.fastq "+dirpath+"unmapped.bam"
            cmd8="cat "+dirpath+"mapped.1.fastq "+dirpath+"unmapped.1.fastq > "+dirpath+"totest.1.fastq"
            cmd9="cat "+dirpath+"mapped.2.fastq "+dirpath+"unmapped.2.fastq > "+dirpath+"totest.2.fastq"
            cmd10="bwa mem -t 8 -P -L 10000 -a "+fasta+" "+dirpath+"totest.1.fastq "+dirpath+"totest.2.fastq > "+\
                dirpath+"totest.sam" # original
            # run HLA-VBSeq
            cmd11="java "+jparam+" -jar "+hlavbseq+" " + fasta + " " + dirpath+"totest.sam "+\
                dirpath+"result.txt --alpha_zero 0.01 --is_paired"
            # get HLA types
            cmd12="Rscript "+process_hlas+" "+dirpath+"result.txt "+allele+" "+mean_cov+" "+read_len+""

            # command2 = "samtools sort -@ "+ ncores +" -o "+Rout+".bam " + Rout + ".sam"
            # # print(command2)
            # command2a = "rm " + Rout + ".sam"
            # command2b = "samtools view -f 3 -F 3840 -q 10 -h -o" + Rout+ "_filt10.bam " + Rout + ".bam"
            # command2c = "rm "+ Rout +".bam"
            # command3 = "samtools index " + Rout + "_filt10.bam"
            # command4 = "samtools idxstats "+Rout + "_filt10.bam > " + Rout + "_log.txt"
            # command5 = "bamCoverage -b " + Rout + "_filt10.bam " + " -o " + Rout + "_filt10.bw " + \
            # "--ignoreDuplicates"
            # commands = [command, command2,command2a, command2b, command2c, command3, command4, command5 ] 
            commands = [cmd1, cmd2, cmd3, cmd4, cmd5, cmd6, cmd7, cmd8, cmd9, cmd10,cmd11, cmd12]
            filehandle = "examples/scripts/"+name+".sh"
            gqw.runner_command(commands,filehandle)
            q = "qsub -l short -pe smp " +ncores+ " " + \
            "-o /frazer01/home/aphodges/software/hpylori/examples/logs/combined_logs.out "+\
            "-e /frazer01/home/aphodges/software/hpylori/examples/logs/combined_logs.err "+\
            "/frazer01/home/aphodges/software/hpylori/examples/scripts/"+name+".sh"
            print(q)
            print(commands)
            # os.system("chmod u+x examples/scripts/*.sh")
            # os.system(q)
