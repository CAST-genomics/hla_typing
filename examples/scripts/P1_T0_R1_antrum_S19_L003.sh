#!/bin/bash
#$ -N hpylori
#$ -pe smp 3
#$ -l short
#$ -V
source /frazer01/home/aphodges/.bashrc

#mycommand="bwa mem -a -t 16 /frazer01/home/aphodges/software/my_hla_typing/reference/hg38_v2/hg38.fa /projects/CEGS/data/mvp/hpylori/igm-storage2.ucsd.edu/220829_A00953_0611_BH5W27DSX5/P1_T0_R1_antrum_S19_L003_R1_001.fastq.gz /projects/CEGS/data/mvp/hpylori/igm-storage2.ucsd.edu/220829_A00953_0611_BH5W27DSX5/P1_T0_R1_antrum_S19_L003_R2_001.fastq.gz > /frazer01/projects/CEGS/pipeline/mvp_hpylori/samfiles/P1_T0_R1_antrum_S19_L003.sam"; eval $mycommand 
mycommand="bwa mem -a -t 16 /frazer01/home/aphodges/software/my_hla_typing/reference/hg38_v2/hg38.fa /projects/CEGS/data/mvp/hpylori/igm-storage2.ucsd.edu/220829_A00953_0611_BH5W27DSX5/P1_T0_R1_antrum_S19_L003_R1_001.fastq.gz /projects/CEGS/data/mvp/hpylori/igm-storage2.ucsd.edu/220829_A00953_0611_BH5W27DSX5/P1_T0_R1_antrum_S19_L003_R2_001.fastq.gz > /frazer01/projects/CEGS/pipeline/mvp_hpylori/samfiles/P9_T1_R1_antrum_S36_L003.sam"; eval $mycommand
mycommand="samtools view -bo /frazer01/home/aphodges/test_hlahpy/mapped.bam -L /frazer01/home/aphodges/reference/hg38.bed /frazer01/projects/CEGS/pipeline/mvp_hpylori/samfiles/P1_T0_R1_antrum_S19_L003.sam"; eval $mycommand 
mycommand="samtools sort -n -o /frazer01/home/aphodges/test_hlahpy/sort.bam /frazer01/home/aphodges/test_hlahpy/mapped.bam"; eval $mycommand 
mycommand="samtools fixmate -O bam /frazer01/home/aphodges/test_hlahpy/sort.bam /frazer01/home/aphodges/test_hlahpy/fixmate.bam"; eval $mycommand 
mycommand="samtools fastq -n -0 /frazer01/home/aphodges/test_hlahpy/mapped.0.fastq -s /frazer01/home/aphodges/test_hlahpy/mapped.s.fastq -1 /frazer01/home/aphodges/test_hlahpy/mapped.1.fastq -2 /frazer01/home/aphodges/test_hlahpy/mapped.2.fastq /frazer01/home/aphodges/test_hlahpy/fixmate.bam"; eval $mycommand 
mycommand="samtools view -bh -f 12 -o /frazer01/home/aphodges/test_hlahpy/unmapped.bam /frazer01/projects/CEGS/pipeline/mvp_hpylori/samfiles/P1_T0_R1_antrum_S19_L003.sam"; eval $mycommand 
mycommand="samtools fastq -n -0 /frazer01/home/aphodges/test_hlahpy/unmapped.0.fastq -s /frazer01/home/aphodges/test_hlahpy/unmapped.s.fastq -1 /frazer01/home/aphodges/test_hlahpy//unmapped.1.fastq -2 /frazer01/home/aphodges/test_hlahpy/unmapped.2.fastq /frazer01/home/aphodges/test_hlahpy/unmapped.bam"; eval $mycommand 
mycommand="cat /frazer01/home/aphodges/test_hlahpy/mapped.1.fastq /frazer01/home/aphodges/test_hlahpy/unmapped.1.fastq > /frazer01/home/aphodges/test_hlahpy/totest.1.fastq"; eval $mycommand 
mycommand="cat /frazer01/home/aphodges/test_hlahpy/mapped.2.fastq /frazer01/home/aphodges/test_hlahpy/unmapped.2.fastq > /frazer01/home/aphodges/test_hlahpy/totest.2.fastq"; eval $mycommand 
mycommand="bwa mem -t 8 -P -L 10000 -a /frazer01/home/aphodges/software/my_hla_typing/reference/hg38_v2/hg38.fa /frazer01/home/aphodges/test_hlahpy/totest.1.fastq /frazer01/home/aphodges/test_hlahpy/totest.2.fastq > /frazer01/home/aphodges/test_hlahpy/totest.sam"; eval $mycommand 
mycommand="java -Xmx12G -jar /frazer01/home/aphodges/builds/hla_typing/HLAVBSeq.jar /frazer01/home/aphodges/software/my_hla_typing/reference/hg38_v2/hg38.fa /frazer01/home/aphodges/test_hlahpy/totest.sam /frazer01/home/aphodges/test_hlahpy/result.txt --alpha_zero 0.01 --is_paired"; eval $mycommand 
mycommand="Rscript ./script/process_hla_types.R /frazer01/home/aphodges/test_hlahpy/result.txt /frazer01/home/aphodges/software/my_hla_typing/reference/alleles.txt 5 151"; eval $mycommand 
