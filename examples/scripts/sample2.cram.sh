#!/bin/bash
#$ -N hlat
#$ -pe smp 3
#$ -l short
#$ -V
mycommand="samtools view -bo ./output/d_1/mapped.bam -L hg38.bed sample2.cram"; eval $mycommand 
mycommand="samtools sort -n -o ./output/d_1/sort.bam ./output/d_1/mapped.bam"; eval $mycommand 
mycommand="samtools fixmate -O bam ./output/d_1/sort.bam ./output/d_1/fixmate.bam"; eval $mycommand 
mycommand="samtools fastq -n -0 ./output/d_1/mapped.0.fastq -s ./output/d_1/mapped.s.fastq -1 ./mapped.1.fastq -2 ./output/d_1/mapped.2.fastq ./output/d_1/fixmate.bam"; eval $mycommand 
mycommand="samtools view -bh -f 12 -o ./output/d_1/unmapped.bam sample2.cram"; eval $mycommand 
mycommand="samtools fastq -n -0 ./output/d_1/unmapped.0.fastq -s ./output/d_1/unmapped.s.fastq -1 ./output/d_1//unmapped.1.fastq -2 ./output/d_1/unmapped.2.fastq ./output/d_1/unmapped.bam"; eval $mycommand 
mycommand="cat ./output/d_1/mapped.1.fastq ./output/d_1/unmapped.1.fastq > ./output/d_1/totest.1.fastq"; eval $mycommand 
mycommand="cat ./output/d_1/mapped.2.fastq ./output/d_1/unmapped.2.fastq > ./output/d_1/totest.2.fastq"; eval $mycommand 
mycommand="bwa mem -t 8 -P -L 10000 -a hg38.fa ./output/d_1/totest.1.fastq ./output/d_1/totest.2.fastq > ./output/d_1/totest.sam"; eval $mycommand 
mycommand="java -Xmx12G -jar ../../HLAVBSeq.jar hg38.fa ./output/d_1/totest.sam ./output/d_1/result.txt --alpha_zero 0.01 --is_paired"; eval $mycommand 
mycommand="Rscript ./script/process_hla_types.R ./output/d_1/result.txt ./alleles.txt 5 151"; eval $mycommand 
