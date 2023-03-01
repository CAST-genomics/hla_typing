### Basic test wdl workflow for Aou environment

workflow HLATyping {

	File inputCram
    File Reference
    File Alleles
    File Bed
    String location
    String input_cram
	String cram_name = basename(input_cram,".cram")

    Array[File] cramfiles

	# Int? preemptible_tries
	# Int preemptible_count = select_first([preemptible_tries, 3])
    call Setup {
        # This should create the directory location, pull cram, and confirm data are available
        # Also copy over any other needed files to this directory
        input:
            my_dir = location,
            #base_
            my_cram = cram_name,
        #output here is none, path is assumed to exist
    }

    call Process_cram {
        input:
            input_cram = my_cram
    }

    call sort_bam {
        input:
            input_cram = my_cram
    }

    call fixmate {}
    call fastq_1 {}
    call fastq1_unmapped {}
    call fastq1_unmapped2 {}
    call bwa_alleles {}
    call HLAVBSeq {}
    
    output {
        # File recalibrated_bam = ApplyBQSR.output_bam
        # File recalibrated_bam_index = ApplyBQSR.output_bam_index
        # File merged_vcf = MergeVCFs.output_vcf
        # File merged_vcf_index = MergeVCFs.output_vcf_index
        # File variant_filtered_vcf = VariantFiltration.output_vcf
        # File variant_filtered_vcf_index = VariantFiltration.output_vcf_index
    }    

}


task Setup{
    String my_dir
    File my_cram
    Int preemptible_count = 2
    command <<<
        echo ${my_dir};
        !gsutil -u {project} cp gs://fc-aou-datasets-controlled/pooled/wgs/cram/v6_base/${my_cram}* .
        # may need to move some files here for 
        # if 0:
        # !bwa/bwa index alleles.gen.fasta
    >>>
    output{
        File local_cram = my_cram
    }
    runtime{
        #docker: docker
		memory: "4 GB"
		#disks: "local-disk " + sub(((size(unmapped_bam,"GB")+1)*5),"\\..*","") + " HDD"
		preemptible: preemptible_count
    }
}


task Process_cram{
    File my_cram
    Int preemptible_count = 2
    File bed_file # hg38.bed

    command <<<
        echo samtools view -b -L ${bed_file} -@ 7 wgs_1000004.cram > wgs_1000004.bam
    >>>

    output{
        File local_cram = my_cram
    }
    runtime{
        #docker: docker
		memory: "4 GB"
		#disks: "local-disk " + sub(((size(unmapped_bam,"GB")+1)*5),"\\..*","") + " HDD"
		preemptible: preemptible_count
    }
}


task sort_bam {
    File x
    Int preemptible_count = 2
    String my_cram

    command <<<
        echo samtools sort -n -@ 7 -o sort.bam wgs_1000004.bam
    >>>
    
    output{
        File local_cram = my_cram
    }
    runtime{
        #docker: docker
		memory: "4 GB"
		#disks: "local-disk " + sub(((size(unmapped_bam,"GB")+1)*5),"\\..*","") + " HDD"
		preemptible: preemptible_count
    }
}


task fixmate{
    File x
    Int preemptible_count = 2

    command <<<
        echo samtools fixmate -O bam -@ 7 sort.bam fixmate.bam
    >>>
    
    output{
        File local_cram = my_cram
    }
    runtime{
        #docker: docker
		memory: "4 GB"
		#disks: "local-disk " + sub(((size(unmapped_bam,"GB")+1)*5),"\\..*","") + " HDD"
		preemptible: preemptible_count
    }
}



task fastq_1 {
    File x
    Int preemptible_count = 2

    command <<<
        echo samtools fastq -@ 7 -n -0 mapped.0.fastq -s mapped.s.fastq -1 mapped.1.fastq -2 mapped.2.fastq fixmate.bam
    >>>
    
    output{
        File local_cram = my_cram
    }
    runtime{
        #docker: docker
		memory: "4 GB"
		#disks: "local-disk " + sub(((size(unmapped_bam,"GB")+1)*5),"\\..*","") + " HDD"
		preemptible: preemptible_count
    }
}



task fastq1_unmapped {
    File x
    Int preemptible_count = 2

    command <<<
        echo samtools view -bh -f 12 -o unmapped.bam -@ 7 wgs_1000004.bam
    >>>
    
    output{
        File local_cram = my_cram
    }
    runtime{
        #docker: docker
		memory: "4 GB"
		#disks: "local-disk " + sub(((size(unmapped_bam,"GB")+1)*5),"\\..*","") + " HDD"
		preemptible: preemptible_count
    }
}


task fastq1_unmapped2 {
    File x
    Int preemptible_count = 2

    command <<<
        echo samtools fastq -@ 7 -n -0 unmapped.0.fastq -s unmapped.s.fastq -1 unmapped.1.fastq -2 unmapped.2.fastq unmapped.bam
    >>>
    
    output{
        File local_cram = my_cram
    }
    runtime{
        #docker: docker
		memory: "4 GB"
		#disks: "local-disk " + sub(((size(unmapped_bam,"GB")+1)*5),"\\..*","") + " HDD"
		preemptible: preemptible_count
    }
}



task bwa_alleles{
    File x
    Int preemptible_count = 2

    command <<<
        echo bwa/bwa mem -t -8 -P -L 10000 -a alleles.gen.fasta mapped.1.fastq mapped.2.fastq > totest.sam
    >>>
    
    output{
        File local_cram = my_cram
    }
    runtime{
        #docker: docker
		memory: "4 GB"
		#disks: "local-disk " + sub(((size(unmapped_bam,"GB")+1)*5),"\\..*","") + " HDD"
		preemptible: preemptible_count
    }
}



task HLAVBSeq {
    File x
    Int preemptible_count = 2

    command <<<
        echo java -Xmx12G -jar ./HLAVBSeq.jar alleles.gen.fasta totest.sam result.txt --alpha_zero 0.01 --is_paired
    >>>
    
    output{
        File local_cram = my_cram
    }
    runtime{
        #docker: docker
		memory: "4 GB"
		#disks: "local-disk " + sub(((size(unmapped_bam,"GB")+1)*5),"\\..*","") + " HDD"
		preemptible: preemptible_count
    }
}

