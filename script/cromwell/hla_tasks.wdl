version 1.0

task Setup{
    input{
        # String my_dir
        String my_cram
        Int preemptible_count = 2
    }
    command <<<
        gsutil -u {project} cp gs://fc-aou-datasets-controlled/pooled/wgs/cram/v6_base/~{my_cram}* .
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
        File input_bam # wgs_1000004.bam
        Int preemptible_count = 2
    }
    command <<<
        echo samtools view -bh -f 12 -o unmapped.bam -@ 7 ~{input_bam}
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
        #File unmapped1 #unmapped
        #File unmapped2 
        #later add unmapped1
        #later add unmapped2 
        Int preemptible_count # = 2
    }
    command <<<
        echo bwa/bwa mem -t -8 -P -L 10000 -a ~{alleles} ~{mapped1} ~{mapped2} > totest.sam
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
        echo java -Xmx12G -jar ./HLAVBSeq.jar ~{alleles} ~{samout} ~{result_loc} --alpha_zero 0.01 --is_paired
    >>>
    
    output{
        File result=result_loc
    }
    runtime{
        #docker: docker
		memory: "4 GB"
		#disks: "local-disk " + sub(((size(unmapped_bam,"GB")+1)*5),"\\..*","") + " HDD"
		preemptible: preemptible_count
    }
}

