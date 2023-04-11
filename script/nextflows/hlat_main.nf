#!/usr/bin/env nextflow
params.cram = "/home/drew/builds/hla_typing/HG02580.alt_bwamem_GRCh38DH.20150718.ACB.low_coverage.cram"  // "/home/drew/models/yeast_cram/yeast.cram"
params.crai = "/home/drew/builds/hla_typing/HG02580.alt_bwamem_GRCh38DH.20150718.ACB.low_coverage.cram.crai" // "/home/drew/models/yeast_cram/yeast.cram.crai"
params.alleles = "/home/drew/builds/cast/hla_typing/examples/data/reference/alleles.txt"
params.bed = "/home/drew/builds/cast/hla_typing/examples/data/reference/hg38.bed"  // yeast_regions.bed"
params.bam = "/home/drew/models/yeast_cram/test_HG02580.bam"
// params.base_name = "/home/drew/models/yeast_cram/yeast_new"
params.out = "/home/drew/builds/cast/hla_typing/examples/results/nf_stdout.txt"
cores = "7"


process view_cram {
    label 'view_and_display_cram'
    input:
        // val vcf from allLines
        path cram
        path crai
        path out
    output:
        // path 'examples/x.txt'
        file out into out
        // stdout
    script:
        """
        ls -la $cram; ls -la $crai;
        samtools view $cram | head > $out
        """
}

process process_cram {
    label "Process_cram_file"
    input:
        path cram
        path crai
        path bed
        path bam
        // var cores //= 7
    output:
        ///path bam
        stdout
    script:
        """
        echo 'samtools view -b -L $bed -@ $cores -o $bam -X $cram $crai'
        """
        // samtools view -b -L $bed -@ 4 -X $cram $crai > $bam
        // samtools view -b -L $bed -@ 4 -o $bam -X $cram $crai
}

process sort_bamfile {
    label "Sort_bamfile"
    input:
        path bam
        var cores // == 4-7
    output:
        path sort_bam
    script:
        """
        samtools sort -n -@ $cores -o $sort_bam $bam
        """
}

process fixmate {
    label "fixmate"
    input:
        path sort_bam
        var cores
        path fixmate
    output:
        path fixmate
    script:
        """
        samtools fixmate -O bam -@ $cores $sort_bam $fixmate
        """
}

process fastq_map {
    label "fastq_map"
    input:
        path fixmate
        path map0 //= "mapped.0.fastq"
        path maps //= "mapped.s.fastq"
        path map1 //= "mapped.1.fastq"
        path map2 //= "mapped.2.fastq"
    output:
        path map0 //= "mapped.0.fastq"
        path maps //="mapped.s.fastq"
        path map1 //"mapped.1.fastq"
        path map2 //"mapped.2.fastq"
    script:
        """
        echo samtools fastq -@ $cores -n -0 $map0 -s $maps -1 $map1 -2 $map2 $fixmate
        """
}

process fastq_unmap1 {
    label "fastq_unmap1"
    input:
        path input_bam
        var cores // = 7
        path unmapped_bam // = "unmapped.bam"
    output:
        path unmapped_bam
    script:
        """
        echo samtools view -bh -f 12 -o $unmapped_bam -@ $cores $input_bam
        """
}

process fastq_unmap2 {
    label "fastq_unmap2"
    input:
        path unmapped_bam
        var cores //= 7
    output:
        path unmap0 //unmap0.fastq
        path unmaps
        path unmap1
        path unmap2
    script:
        """
        echo samtools fastq -@ $cores -n -0 $unmap0 -s $unmaps -1 $unmap1 -2 unmap2 $unmapped_bam
        """    
}

process bwa_alleles {
    label "bwa_alleles"
    input:
        path alleles
        path mapped1
        path mapped2
        path sam //totest.sam
        var cores = 7
    output:
        path sam
    script:
        """
        echo bwa/bwa mem -t -@ $cores -P -L 10000 -a $alleles $mapped1 $mapped2 > $sam
        """
}

process hlavbseq {
    label "hlavbseq"
    input:
        path alleles
        path sam
        path outtxt
    output:
        path outtxt //./result.txt
    script:
        """
        echo java -Xmx12G -jar ./HLAVBSeq.jar $alleles $sam $outtxt --alpha_zero 0.01 --is_paired
        """
}

workflow {
    // view_cram(params.cram, params.crai, params.out)
    process_cram(params.cram, params.crai, params.bed, params.bam)
    | view()
    // sort_bamfile(bam, cores)
    // fixmate(sort_bam, cores, fixmate)
    // fastq_map(fixmate, map0, maps, map1, map2)
    // fastq_unmap1(input_bam, cores, unmapped_bam)
    // fastq_unmap2(unmapped_bam, cores)
    // bwa_alleles(alleles, mapped1, mapped2, sam, cores)
    // hlavbseq(alleles, sam, outtxt)
}

workflow.onComplete {

    println ( workflow.success ? """
        Pipeline execution summary
        ---------------------------
        Completed at: ${workflow.complete}
        Duration    : ${workflow.duration}
        Success     : ${workflow.success}
        workDir     : ${workflow.workDir}
        exit status : ${workflow.exitStatus}
        """ : """
        Failed: ${workflow.errorReport}
        exit status : ${workflow.exitStatus}
        """
    )
}
