source("/frazer01/projects/CEGS/analysis/hla_type_1kgp/script/functions_hla_type.R")

option_list        = list(make_option("--taskid", type="integer", default=0, help="SGE task ID", metavar="character")) 
opt_parser         = OptionParser(option_list=option_list)
opt                = parse_args(opt_parser)
ii                 = opt$taskid
id2cv              = fread("pipeline/beagle/1kgp_validation/id2cv.txt"         , sep = "\t", header = TRUE, data.table = FALSE)
cv2perm            = fread("pipeline/beagle/1kgp_validation/random/cv2perm.txt", sep = "\t", header = TRUE, data.table = FALSE)

impute_1kgp_random(ii, cv2perm, id2cv)
