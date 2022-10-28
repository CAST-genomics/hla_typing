source("/frazer01/projects/CEGS/analysis/hla_type_1kgp/script/functions_hla_type.R")

option_list        = list(make_option("--taskid", type="integer", default=0, help="SGE task ID", metavar="character")) 
opt_parser         = OptionParser(option_list=option_list)
opt                = parse_args(opt_parser)
ii                 = opt$taskid
cv2perm            = fread("pipeline/beagle/1kgp_validation/random/cv2perm.txt", sep = "\t", header = TRUE, data.table = FALSE)
outfolder_random   = paste(getwd(), "pipeline/beagle/1kgp_validation/random", sep = "/")
random2perm        = unique(cv2perm[,c("random", "perm")])
var_ids_file       = paste(getwd(), "pipeline/beagle/1kgp_validation/ukbb_variants", "var_ids_ukbb.txt", sep = "/")
var_ids            = readLines(var_ids_file)

create_random_var_lists(random2perm[ii, "random"], random2perm[ii, "perm"], var_ids)
