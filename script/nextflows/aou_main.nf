vcfs_path =  Channel.fromPath(params.vcfs_path).first()
tbis_path =  Channel.fromPath(params.tbis_path).first()

process validate_vcf {
     label 'validate_gatk'

     input:
     file vcf from vcfs_path
     file tbi from tbis_path
     
     script:
     """
     gatk ValidateVariants \
     -R 'gs://genomics-public-data/references/hg38/v0/Homo_sapiens_assembly38.fasta' \
     -V ${vcf} \
     --read-index ${tbi} \
     --validation-type-to-exclude ALL
     """
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
