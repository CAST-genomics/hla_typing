params.file_csv = "./examples/configs/example.csv"
params.out = "./examples/configs/example_out.xlsx"

process generate_manifest {
  input:
    path file_csv
  output:
    path out

    """
    python ./script/gen_manifest.py $file_csv $out
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
