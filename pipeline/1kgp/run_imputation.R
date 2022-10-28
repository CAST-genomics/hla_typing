source("/frazer01/projects/CEGS/analysis/hla_type_1kgp/script/functions_hla_type.R")

option_list        = list(make_option("--taskid", type="integer", default=0, help="SGE task ID", metavar="character")) 
opt_parser         = OptionParser(option_list=option_list)
opt                = parse_args(opt_parser)
bin                = opt$taskid
ukbb2bin           = fread("pipeline/beagle/ukbb2bin.txt", sep = "\t", header = TRUE, data.table = FALSE)
rownames(ukbb2bin) = ukbb2bin$id
ukbb_psam          = fread("input/ukbb/snps.psam", sep = "\t", header = TRUE, data.table = FALSE)
ukbb_pgen_prefix   = paste(getwd(), "input/ukbb/snps", sep = "/")

impute(bin, ukbb2bin, ukbb_psam, ukbb_pgen_prefix)
