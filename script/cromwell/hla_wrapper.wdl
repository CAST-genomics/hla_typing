version 1.0
import "hla_basic.wdl" as hla
#import "hla_wrapper.wdl" as hla

workflow main{
    input{
        Array[File] cramfiles
        File alleleFile
        File bedfile
        #String locationx
    }
    scatter(i in cramfiles){
        call hla.HLATyping{
            input: Alleles= alleleFile,
            Bed=bedfile,
            #location=locationx,
            base_name="${i}",
            cram_name=i + ".cram"
        }        
    }
}
