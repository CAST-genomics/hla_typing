source("/frazer01/projects/CEGS/analysis/hla_type_1kgp/script/functions_hla_type.R")

option_list        = list(make_option("--taskid", type="integer", default=0, help="SGE task ID", metavar="character")) 
opt_parser         = OptionParser(option_list=option_list)
opt                = parse_args(opt_parser)
bin                = opt$taskid
id2cv              = fread("pipeline/beagle/1kgp_validation/id2cv.txt", sep = "\t", header = TRUE, data.table = FALSE)

impute_1kgp(bin, id2cv)
