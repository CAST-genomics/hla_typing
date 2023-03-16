version 1.0

### Basic test wdl workflow for Aou environment

workflow HLATyping {
    
    input {
        File Alleles # alleles.gen.fasta
        File Bed #hg38.bed
        # String location # path to do the work in
        String base_name #example = wg_100004 
        String cram_name = basename(base_name,".cram")
    }
    #Array[File] cramfiles
    
	# Int? preemptible_tries
	# Int preemptible_count = select_first([preemptible_tries, 3])
    call Setup {
        # This should create the directory location, pull cram, and confirm data are available
        # Also copy over any other needed files to this directory
        input:
            #my_dir = location,
            my_cram = cram_name,
            preemptible_count = 2
        #output here is none, path is assumed to exist
    }

    call Process_cram {
        input:
            my_cram=Setup.local_cram, #wgs_1000004.cram 
            my_bam=base_name + ".bam",  #wgs_1000004.bam
            preemptible_count=8,
            bed_file=Bed,   
    }

    call sort_bamfile {
        input:
            local_bam=Process_cram.local_bam, #= wgs_1000004.bam
            preemptible_count=8,
            Sort_bam = Process_cram.local_bam + "_sort.bam" #= sort_bam = sort_bam
            #input_cram = my_cram
    }

    call fixmate {
        input:
            sort_bam=sort_bamfile.sort_bam, #sort.bam
            preemptible_count = 1,
            fixmate_out="fixmate.bam"
    }

    call fastq_1 {
        input:
            Fixmate=fixmate.fixmate_bam,
            preemptible_count = 1
    }
    call fastq1_unmapped {
        input:
            input_bam=Process_cram.local_bam, # wgs_1000004.bam
            preemptible_count = 1
    }
    call fastq1_unmapped2 {
        input:
            unmapped = fastq1_unmapped.unmapped,
            preemptible_count = 1
    }
    call bwa_alleles {
        input:
            alleles=Alleles, #alleles.gen.fasta
            mapped1=fastq_1.mapped1,
            mapped2=fastq_1.mapped2,
            # unmapped1=fastq1_unmapped2.unmapped1,
            # unmapped2=fastq1_unmapped2.unmapped2,
            preemptible_count = 8,
    }
    call HLAVBSeq {
        input:
            alleles=Alleles, #alleles.gen.fasta
            samout=bwa_alleles.samout, #totest.sam
            preemptible_count = 2, #
            result_loc="result.txt"
    }
    
    output {
        File output_file = HLAVBSeq.result
        # File recalibrated_bam_index = ApplyBQSR.output_bam_index
        # File merged_vcf = MergeVCFs.output_vcf
        # File merged_vcf_index = MergeVCFs.output_vcf_index
        # File variant_filtered_vcf = VariantFiltration.output_vcf
        # File variant_filtered_vcf_index = VariantFiltration.output_vcf_index
    }    

}


task Setup{
    input{
        # String my_dir
        String my_cram
        Int preemptible_count = 2
    }
    command <<<
        echo ~{my_cram}
        echo gsutil -u {project} cp gs://fc-aou-datasets-controlled/pooled/wgs/cram/v6_base/~{my_cram}* .
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
    input{
        File my_cram # = local_cram #wgs_1000004.cram
        String my_bam  #wgs_1000004.bam
        Int preemptible_count = 2
        File bed_file # hg38.bed
    }
    command <<<
        echo samtools view -b -L ~{bed_file} -@ 7 ~{my_cram} > ~{my_bam}
    >>>

    output{
        File local_bam = my_bam
    }
    runtime{
        #docker: docker
		memory: "4 GB"
		#disks: "local-disk " + sub(((size(unmapped_bam,"GB")+1)*5),"\\..*","") + " HDD"
		preemptible: preemptible_count
    }
}


task sort_bamfile {
    input{
        File local_bam #= wgs_1000004.bam
        Int preemptible_count = 2
        String Sort_bam = local_bam + "_sort.bam" #= sort_bam = sort_bam
    }
    command <<<
        echo samtools sort -n -@ 7 -o ~{Sort_bam} ~{local_bam}
    >>>
    
    output{
        File sort_bam = Sort_bam
    }
    runtime{
        #docker: docker
		memory: "4 GB"
		#disks: "local-disk " + sub(((size(unmapped_bam,"GB")+1)*5),"\\..*","") + " HDD"
		preemptible: preemptible_count
    }
}


task fixmate{
    input{
        File sort_bam #sort.bam
        Int preemptible_count = 2
        String fixmate_out #fixmate.bam
    }

    command <<<
        echo samtools fixmate -O bam -@ 7 ~{sort_bam} ~{fixmate_out}
    >>>
    
    output{
        File fixmate_bam=fixmate_out
    }
    runtime{
        #docker: docker
		memory: "4 GB"
		#disks: "local-disk " + sub(((size(unmapped_bam,"GB")+1)*5),"\\..*","") + " HDD"
		preemptible: preemptible_count
    }
}



task fastq_1 {
    input{
        File Fixmate #fixmate.bam
        Int preemptible_count = 2
    }
    command <<<
        echo samtools fastq -@ 7 -n -0 mapped.0.fastq -s mapped.s.fastq -1 mapped.1.fastq -2 mapped.2.fastq ~{Fixmate}
    >>>
    
    output{
        File mapped0 = "mapped.0.fastq"
        File mapped1 = "mapped.1.fastq"
        File mapped2 = "mapped.2.fastq"
        File mappeds = "mapped.s.fastq"
    }
    runtime{
        #docker: docker
		memory: "4 GB"
		#disks: "local-disk " + sub(((size(unmapped_bam,"GB")+1)*5),"\\..*","") + " HDD"
		preemptible: preemptible_count
    }
}



task fastq1_unmapped {
    input{
        File input_cram # wgs_1000004.bam
        Int preemptible_count = 2
    }
    command <<<
        echo samtools view -bh -f 12 -o unmapped.bam -@ 7 ~{input_cram}
    >>>
    
    output{
        File unmapped = "unmapped.bam"
    }
    runtime{
        #docker: docker
		memory: "4 GB"
		#disks: "local-disk " + sub(((size(unmapped_bam,"GB")+1)*5),"\\..*","") + " HDD"
		preemptible: preemptible_count
    }
}


task fastq1_unmapped2 {
    input{
        File unmapped # = unmapped.bam
        Int preemptible_count = 2
    }
    command <<<
        echo samtools fastq -@ 7 -n -0 unmapped.0.fastq -s unmapped.s.fastq -1 unmapped.1.fastq -2 unmapped.2.fastq ~{unmapped}
    >>>
    
    output{
        File unmapped0 = "unmapped.0.fastq"
        File unmapped1 = "unmapped.1.fastq"
        File unmapped2 = "unmapped.2.fastq"
        File unmappeds = "unmapped.s.fastq"
    }
    runtime{
        #docker: docker
		memory: "4 GB"
		#disks: "local-disk " + sub(((size(unmapped_bam,"GB")+1)*5),"\\..*","") + " HDD"
		preemptible: preemptible_count
    }
}



task bwa_alleles{
    input{
        File alleles #alleles.gen.fasta
        File mapped1 #mapped.1.fastq
        File mapped2 #mapped.2.fastq
        File unmapped1 #unmapped
        File unmapped2 
        #later add unmapped1
        #later add unmapped2 
        Int preemptible_count # = 2
    }
    command <<<
        echo bwa/bwa mem -t -8 -P -L 10000 -a ~{alleles} ~{mapped1} ~{mapped2} ~{unmapped1} ~{unmapped2} > totest.sam
    >>>
    
    output{
        File samout = "totest.sam"
    }
    runtime{
        #docker: docker
		memory: "4 GB"
		#disks: "local-disk " + sub(((size(unmapped_bam,"GB")+1)*5),"\\..*","") + " HDD"
		preemptible: preemptible_count
    }
}


task HLAVBSeq {
    input{
        File alleles #alleles.gen.fasta
        File samout #totest.sam
        Int preemptible_count # = 2 #
        String result_loc
    }
    command <<<
        echo java -Xmx8G -jar ./HLAVBSeq.jar ~{alleles} ~{samout} ~{result_loc} --alpha_zero 0.01 --is_paired
    >>>
    
    output{
        File result=result_loc
    }
    runtime{
        #docker: docker
		memory: "8 GB"
		#disks: "local-disk " + sub(((size(unmapped_bam,"GB")+1)*5),"\\..*","") + " HDD"
		preemptible: preemptible_count
    }
}

