#setwd("/frazer01/projects/CEGS/analysis/hla_type_1kgp")
setwd("/frazer01/home/aphodges/software/my_hla_typing/")
source("script/functions.R" )
source("script/functions_hla_type.R")

suppressPackageStartupMessages(library(rhdf5))

option_list      = list(make_option("--taskid", type="integer", default=0, help="SGE task ID", metavar="character")) 
opt_parser       = OptionParser(option_list=option_list)
opt              = parse_args(opt_parser)
taskid           = opt$taskid
id2url           = fread("pipeline/hla_typing/id2url.txt", sep = "\t", header = TRUE, data.table = FALSE)
rownames(id2url) = id2url$id

run_hla_typing(taskid, id2url)
