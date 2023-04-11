file_conf = 'examples/my_files.txt'
param_conf = "somevalue.conf"
tbi = 'some_index.inf'

myFile = file(file_conf)
allLines = myFile.readLines()
for( line : allLines ) {
    println line
}
//allLines2 = Channel.fromPath(allLines)


process validate_file {
     label 'validate_file'

     input:
     val vcf from allLines

     output:
     path 'examples/x.txt'
     
     script:
     // """
     // echo '${vcf}'
     // echo '\n'
     """
     echo "gatk ValidateVariants \
     -R 'gs://genomics-public-data/references/hg38/v0/Homo_sapiens_assembly38.fasta' \
     -V ${vcf} \
     --read-index tbi \
     --validation-type-to-exclude ALL" > x.txt
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
