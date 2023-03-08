version 1.0

import "hla_basic.wdl" as hla
#import "hla_wrapper.wdl" as hla

workflow main{
    input{
        String cram_manifest
        #Array[File] cramfiles
        File alleleFile
        File bedfile
        #String locationx
    }
    Array[Array[String]] batch_crams = read_tsv( cram_manifest )

    scatter(i in batch_crams){
        call hla.HLATyping{
            input: Alleles=alleleFile,
            Bed=bedfile,
            #location=locationx,
            base_name= i[0], # "${i}",
            cram_name= i[0] + ".cram"
        }        
    }
}
