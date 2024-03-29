#!/usr/bin/env nextflow
params.sample = "HG02580_chr6"
params.cram = "/home/drew/builds/hla_typing/"+params.sample + ".cram" //HG02580.alt_bwamem_GRCh38DH.20150718.ACB.low_coverage.cram"  // "/home/drew/models/yeast_cram/yeast.cram"
params.crai = "/home/drew/builds/hla_typing/"+params.sample + ".cram.crai" //HG02580.alt_bwamem_GRCh38DH.20150718.ACB.low_coverage.cram.crai" // "/home/drew/models/yeast_cram/yeast.cram.crai"
params.alleles = "/home/drew/models/yeast_cram/alleles.gen.fasta"
params.bed = "/home/drew/builds/cast/hla_typing/examples/data/reference/hg38.bed"  // yeast_regions.bed"
params.bam = "/home/drew/models/yeast_cram/"+params.sample+ ".bam"
params.path = "/home/drew/models/yeast_cram/"
// params.base_name = "/home/drew/models/yeast_cram/yeast_new"
params.out = "/home/drew/builds/cast/hla_typing/examples/results/nf_stdout.txt"
cores = "7"
params.hlavbseq = "/home/drew/builds/cast/hla_typing/script/HLAVBSeq.jar"
params.outtxt = "/home/drew/models/yeast_cram/hla_out" + params.sample + ".txt"

process view_cram {
    label 'view_and_display_cram'
    input:
        // val vcf from allLines
        path cram
        path crai
        path out
    output:
        // path 'examples/x.txt'
        file out // into out
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
        file bam // into bam// into bam2
        // stdout
    script:
        """
        samtools view -bh -L $bed -@ $cores -o $bam -X $cram $crai
        """
        // samtools view -b -L $bed -@ 4 -X $cram $crai > $bam
        // samtools view -b -L $bed -@ 4 -o $bam -X $cram $crai
}

process sort_bamfile {
    label "Sort_bamfile"
    input:
        path bam
        val cores // == 4-7
        path sort_bam 
    output:
        path sort_bam 
    script:
        // sort_bam = Channel.path("$bam" + "_sort.bam")
        """
        samtools sort -n -@ $cores -o $sort_bam $bam
        """
}

process fixmate {
    label "fixmate"
    input:
        path sort_bam //from sort_bam_ch
        val cores
        path fixmate
    output:
        path fixmate // into fixmate_ch
    script:
        """
        samtools fixmate -O bam -@ $cores $sort_bam $fixmate
        """
}

process fastq_map {
    label "fastq_map"
    input:
        path fixmate //from fixmate_ch
        path map0 //= "mapped.0.fastq"
        path maps //= "mapped.s.fastq"
        path map1 //= "mapped.1.fastq"
        path map2 //= "mapped.2.fastq"
    output:
        path map0 //into map0_ch //= "mapped.0.fastq"
        path maps //into maps_ch //="mapped.s.fastq"
        path map1 //into map1_ch //"mapped.1.fastq"
        path map2 //into map2_ch //"mapped.2.fastq"
    script:
        """
        samtools fastq -@ $cores -n -0 $map0 -s $maps -1 $map1 -2 $map2 $fixmate
        """
}

// process fastq_unmap1 {
//     label "fastq_unmap1"
//     input:
//         path input_bam
//         var cores // = 7
//         path unmapped_bam // = "unmapped.bam"
//     output:
//         path unmapped_bam
//     script:
//         """
//         echo samtools view -bh -f 12 -o $unmapped_bam -@ $cores $input_bam
//         """
// }

// process fastq_unmap2 {
//     label "fastq_unmap2"
//     input:
//         path unmapped_bam
//         var cores //= 7
//     output:
//         path unmap0 //unmap0.fastq
//         path unmaps
//         path unmap1
//         path unmap2
//     script:
//         """
//         echo samtools fastq -@ $cores -n -0 $unmap0 -s $unmaps -1 $unmap1 -2 unmap2 $unmapped_bam
//         """    
// }


process bwa_alleles {
    label "bwa_alleles"
    input:
        path alleles
        path mapped1
        path mapped2
        path sam
        val cores
    output:
        path sam
    script:
        def allelesbase = alleles[0].baseName
        """
        bwa mem -t $cores -P -L 10000 -a $allelesbase $mapped1 $mapped2 > $sam
        """
}

process hlavbseq {
    label "hlavbseq"
    input:
        path alleles
        path sam
        path outtxt
        path hlavbseq
    output:
        path outtxt
    script:
        def allelesbase = alleles[0].baseName
        """
        echo 'java -Xmx12G -jar $hlavbseq $allelesbase $sam $outtxt --alpha_zero 0.01 --is_paired' > $outtxt
        """
}

process cleanup {
    label "cleanup"
    input:
        path map0
        path maps
        path map1
        path map2        
    output:  
        stdout
    script:
    """
    echo "Test of removing files";
    rm $map0; rm $map1; rm $map2; rm $maps;
    """
}



workflow {
    // view_cram(params.cram, params.crai, params.out)
    // index_alleles = Channel.fromPath(params.alleles + "*")
    mybam = process_cram(params.cram, params.crai, params.bed, params.bam)
    // | view()
    // println( file(mybam).name())
    sortbam =  params.bam + "_sort.bam"
    sort_bam = sort_bamfile(mybam, cores, sortbam) // "bam_sort.bam")
    fixmate_bam = params.bam + "_fixmate.bam"
    my_fixmate = fixmate(sort_bam, cores, fixmate_bam)
    (map0, maps, map1, map2) = fastq_map(my_fixmate, 
        params.path+"mapped.0.fastq", params.path+"mappped.s.fastq", 
        params.path + "mapped.1.fastq", params.path + "mapped.2.fastq")
    // // fastq_unmap1(input_bam, cores, unmapped_bam)
    // // fastq_unmap2(unmapped_bam, cores)
    allelesPath = file(params.alleles + ".{,amb,ann,bwt,pac,sa}")
    sam = bwa_alleles(allelesPath, map1, map2, params.path + "bwa.sam", cores)
    result = hlavbseq(allelesPath, sam, params.outtxt, params.hlavbseq)
    // cleanup(map0, maps, map1, map2)
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
