#$ -V
#$ -cwd

source ~/.bashrc

bam=$1
build=$2
prefix=$3
fasta_type=$4
allele=$5
mean_cov=$6
read_len=$7

#dir=`mktemp -d -p pipeline/hla_vbseq/TMP`
dir="${prefix}.TMP"            
fasta="/frazer01/home/aphodges/software/my_hla_typing/reference/${fasta_type}/alleles.${fasta_type}.fasta"
bed="/frazer01/home/aphodges/software/my_hla_typing/reference/${build}.bed"
ref_fasta="/frazer01/home/aphodges/software/my_hla_typing/reference/hg38_v2/hg38.fa"

#if [ ! -d "${dir}" ]; then
# echo $dir
#fi
# extract reads mapping to HLA genes
date >& 2

mkdir $dir

#cmd="samtools view -T $ref_fasta -bo $dir/mapped.bam -L $bed $bam"

cmd="samtools view -bo ${dir}/mapped.bam -L ${bed} ${bam}"
echo "${cmd}" >& 2; eval $cmd
date >& 2

cmd="samtools sort -n -o ${dir}/sort.bam ${dir}/mapped.bam"
echo "${cmd}" >& 2; eval $cmd
date >& 2

cmd="samtools fixmate -O bam ${dir}/sort.bam ${dir}/fixmate.bam"
echo "${cmd}" >& 2; eval $cmd
date >& 2

cmd="samtools fastq -n -0 ${dir}/mapped.0.fastq -s ${dir}/mapped.s.fastq -1 ${dir}/mapped.1.fastq -2 $dir/mapped.2.fastq $dir/fixmate.bam"
echo "${cmd}" >& 2; eval $cmd
date >& 2

# extract unmapped reads

#cmd="samtools view -T $ref_fasta -bh -f 12 -o $dir/unmapped.bam $bam"
cmd="samtools view -bh -f 12 -o ${dir}/unmapped.bam ${bam}"
echo "${cmd}" >& 2; eval $cmd
date >& 2

cmd="samtools fastq -n -0 ${dir}/unmapped.0.fastq -s ${dir}/unmapped.s.fastq -1 ${dir}/unmapped.1.fastq -2 ${dir}/unmapped.2.fastq ${dir}/unmapped.bam"
echo "${cmd}" >& 2; eval $cmd
date >& 2

# bind fastq files

cmd="cat ${dir}/mapped.1.fastq ${dir}/unmapped.1.fastq > ${dir}/totest.1.fastq"
echo "${cmd}" >& 2; eval $cmd
date >& 2

cmd="cat ${dir}/mapped.2.fastq ${dir}/unmapped.2.fastq > ${dir}/totest.2.fastq"
echo "${cmd}" >& 2; eval $cmd
date >& 2

# align reads to HLA types

cmd="bwa mem -t 8 -P -L 10000 -a ${fasta} ${dir}/totest.1.fastq ${dir}/totest.2.fastq > ${dir}/totest.sam" # original
#cmd="bwa mem -t 2 -P -L 10000 -B 10 -O 10 -a $fasta $dir/totest.1.fastq $dir/totest.2.fastq > $dir/totest.sam"
echo "${cmd}" >& 2; eval $cmd
date >& 2

# run HLA-VBSeq

cmd="java -Xmx12G -jar /frazer01/home/aphodges/software/my_hla_typing/HLAVBSeq.jar ${fasta} ${dir}/totest.sam ${dir}/result.txt --alpha_zero 0.01 --is_paired"
echo "${cmd}" >& 2; eval $cmd
date >& 2
    
# get HLA types

cmd="Rscript /frazer01/home/aphodges/software/my_hla_typing/process_hla_types.R ${dir}/result.txt ${allele} ${mean_cov} ${read_len}"
echo "${cmd}" >& 2; eval $cmd
date >& 2
    
# move output files and remove temp folder

cp $dir/result.txt        $prefix.result.txt
cp $dir/hla_types.txt     $prefix.hla_types.txt
cp $dir/hla_types_all.txt $prefix.hla_types_all.txt
rm -r $dir
