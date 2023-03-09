version 1.0

import "hla_basic_test2.wdl" as hla
#import "hla_wrapper.wdl" as hla

workflow main{
    input{
        String cram_manifest
        File alleleFile
        File bedfile
    }
    Array[Array[String]] batch_crams = read_tsv( cram_manifest )

    scatter(i in batch_crams){
        call hla.HLATyping{
            input: 
                Alleles=alleleFile,
                Bed=bedfile,
                location="./",
                base_name= i[0], 
                cram_name= i[0] + ".cram"
        }        
    }
}
