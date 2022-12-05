# startpath = "/frazer01/home/aphodges/software/my_hla_typing/" #"/frazer01/projects/CEGS/analysis/hla_type_1kgp/"
# genef = "pipeline/hla_typing/gene_info.txt"
# idf = "pipeline/hla_typing/id2url.txt"
# hlaset = c("HG00187", "HG01924", "HG01926", "HG01927", "NA19154")
# hla_typing_path_ = "/frazer01/home/aphodges/software/my_hla_typing/hla_typing.sh"   
# #"/frazer01/home/matteo/software/my_hla_typing/hla_typing.sh"
# allele_path_ = "/frazer01/home/aphodges/software/my_hla_typing/reference/alleles.txt"       
# #"/frazer01/home/matteo/software/my_hla_typing/reference/alleles.txt"
# mapx = "/frazer01/software/beagle-5.4/plink.GRCh37.map/plink.chr6.GRCh37.map"
library(config)
config::get(file="./configs/path_config.yml")
setwd(startpath)
source("script/functions.R")

dir.create("pipeline/hla_typing/vcf", showWarnings = FALSE)

# Global variables
geneinfo            = fread(genef, sep = "\t", header = TRUE, data.table = FALSE)
geneinfo            = geneinfo[order(geneinfo$start),]
rownames(geneinfo)  = geneinfo$gene
vcf_hla_types       = paste(getwd(), "pipeline/hla_typing/vcf", "hla_types.vcf.gz" , sep = "/")
vcf_combined        = paste(getwd(), "pipeline/hla_typing/vcf", "combined.vcf.gz"  , sep = "/")
vcf_phased          = paste(getwd(), "pipeline/hla_typing/vcf", "phased.vcf.gz"    , sep = "/")
hla_types_list_file = paste(getwd(), "pipeline/hla_typing"    , "hla_type_list.txt", sep = "/")

if(myrun == "1kgp"){
    id2hla              = fread(idf   , sep = "\t", header = TRUE, data.table = FALSE)
    id2hla$infile       = paste("pipeline/hla_typing/processing", paste(id2hla$id, "hla_types.txt", sep = "."), sep = "/") 
    id2hla              = id2hla[ file.exists(id2hla$infile) == TRUE & !id2hla$id %in% hlaset, ]
    rownames(id2hla  )  = id2hla$id

    command  = paste("bcftools", "query", "-l", vcf_chr6)
    ids_1kgp = fread(cmd = command, sep = "\t", header = FALSE, data.table = FALSE)[,1]
    ids      = intersect(id2hla$id, ids_1kgp)
    ids_file = paste(getwd(), "input", "ids.txt", sep = "/")
    writeLines(ids, ids_file, sep = "\n")
} 

#### Note: need to clone + edit the above steps for bcftools generation
####   This will need slight tweaking given mvp/similar design.



# Subject IDs shared between HLA types and SNPs

# ancestry data
if(bcftools){
    ancestry_1kgp           = fread("input/1kgp/ancestry.txt"        , sep = "\t", header = FALSE, data.table = FALSE)
    pops                    = fread("input/1kgp/populations.txt"     , sep = "\t", header = TRUE , data.table = FALSE)
    superpops               = fread("input/1kgp/superpopulations.txt", sep = "\t", header = TRUE , data.table = FALSE)
    colnames(ancestry_1kgp) = c("subject_id", "population", "super_population", "sex")
    colnames(superpops    ) = c("super_population_description", "super_population")
    rownames(superpops    ) = superpops$super_population
    rownames(ancestry_1kgp) = ancestry_1kgp$subject_id
    colnames(pops         ) = gsub(" ", "_", tolower(colnames(pops)))
    pops                    = pops[!pops$population_description %in% c("Total", ""),]
    superpops$color         = c("#00ff00", "#ff00ff", "#ff0000", "#0000ff", "#ffff00")
}
################################################################################################
# Functions for HLA typing
################################################################################################

run_hla_typing = function(taskid, id2url, hla_typing_path=hla_typing_path_, allele_path=allele_path_)
{
    id      = id2url[taskid, "id"      ]
    cram    = id2url[taskid, "cram_url"]
    print("Test:cram output")
    print(cram)
    prefix  = paste("pipeline/hla_typing/processing", id, sep = "/")
    command = paste("bash", 
                    hla_typing_path,
                    cram,
                    "hg38",
                    prefix,
                    "gen", 
                    allele_path,
                    5,
                    151
                   )
    print(command)
    system(command)
}

################################################################################################
# Functions for imputations
################################################################################################

filter_vcf_by_id = function(ids, vcf_in, vcf_out)
{
    command = paste("bcftools", "view",
                    "-s" , paste(ids, collapse = ","),
                    "-Oz",
                    "-o" , vcf_out,
                    vcf_in)
    
    system(command)

    command = paste("bcftools", "index", "-t", vcf_out)

    system(command)
}

command_convert_to_vcf = function(bin_file, outfolder, ukbb_pgen_prefix)
{
    vcf_unphased = paste(outfolder, "snps_unphased", sep = "/")
    
    command = paste("plink2_64", 
                    "--pgen"      , paste(ukbb_pgen_prefix, "pgen", sep = "."),
                    "--psam"      , paste(ukbb_pgen_prefix, "psam", sep = "."),
                    "--pvar"      , paste(ukbb_pgen_prefix, "pvar", sep = "."),
                    "--keep"      , bin_file ,
                    "--memory"    , 16000,
                    "--threads"   , 4,
                    "--export"    , "vcf", "bgz", "vcf-dosage=DS-force",
					"--maj-ref"   , "force", 
					#"--ref-allele", "force", vcf_snps, 4, 3, "'#'",
                    "--out"   , vcf_unphased
                   )
    
    system(command)
    
    vcf_unphased_gz = paste(vcf_unphased, "vcf", "gz", sep = ".")
    command         = paste("bcftools", "index", "-t", vcf_unphased_gz)

    system(command)
	
	vcf_phased = paste(outfolder, "snps.vcf.gz"                 , sep = "/")
	log_phased = paste(outfolder, "phased.log"                  , sep = "/")
	file_map   = paste(getwd()  , "input/phase/chr6.b37.gmap.gz", sep = "/")
	command    = paste("shapeit4", 
					   "--input" , vcf_unphased_gz, 
					   "--thread", 16,
					   "--map"   , file_map  ,
					   "--region", coord     ,
					   "--log"   , log_phased,
					   "--output", vcf_phased,
					   ""
					  )

	system(command)

	command = paste("bcftools", "index", "-t", vcf_phased)

	system(command)
    
    return(vcf_phased)
}

command_run_beagle = function(vcf_in, vcf_out, outfolder, mapx=mapx)
{
    map_file = mapx
    out_file = paste(outfolder, "imputed", sep = "/")
    command  = paste("/frazer01/software/jdk-16.0.1/bin/java", 
                     #"-Xss5m", 
                     "-Xmx32g", 
                     "-jar", "/frazer01/software/beagle-5.4/beagle.19Apr22.7c0.jar", 
                     paste("gt" , vcf_out   , sep = "="),
                     paste("ref", vcf_in    , sep = "="),
                     paste("map", map_file  , sep = "="),
                     paste("out", out_file  , sep = "="),
                     "nthreads=4",
                     "ne=500000",
                     "impute=true",
                     "seed=-99999",
                     "")

    system(command)
	
	return(out_file)
}

command_extract_hla_convert = function(imputed_vcf, outfolder)
{
    out_file = paste(outfolder, "imputed_hla", sep = "/")
    command  = paste("plink2_64", 
                     "--vcf"    , paste(imputed_vcf, "vcf.gz", sep = "."),
                     "--extract", hla_types_list_file,
                     "--memory" , 16000,
                     "--threads", 4,
                     "--export" , "vcf", "bgz", "vcf-dosage=DS-force",
                     "--out"   , out_file
                    )
    
    system(command)
	
    command = paste("bcftools", "index", "-t", paste(out_file, "vcf", "gz", sep = "."))

    system(command)

}

impute_1kgp = function(bin, id2cv)
{
    ids_in    = id2cv[ id2cv$bin != bin, "id"]
    ids_imp   = id2cv[ id2cv$bin == bin, "id"]
    
    outfolder = paste(getwd(), "pipeline/beagle/1kgp_validation/processing", paste0("bin", bin), sep = "/")
    vcf_in    = paste(outfolder, "ref.vcf.gz", sep = "/")
    vcf_imp   = paste(outfolder, "gts.vcf.gz", sep = "/")
    
    dir.create(outfolder, showWarnings = FALSE)
    
    filter_vcf_by_id(ids_in , vcf_phased, vcf_in )
    filter_vcf_by_id(ids_imp, vcf_snps  , vcf_imp)
    
    imputed_vcf = command_run_beagle         (vcf_in, vcf_imp, outfolder)
    hla_out     = command_extract_hla_convert(imputed_vcf, outfolder)
}

impute_1kgp_ukbb_vars = function(bin, id2cv)
{
    ids_in    = id2cv[ id2cv$bin != bin, "id"]
    ids_imp   = id2cv[ id2cv$bin == bin, "id"]
	vcf_gts   = paste(getwd(), "pipeline/beagle/1kgp_validation/ukbb_variants", "ukbb_vars.vcf.gz", sep = "/")
    
    outfolder = paste(getwd(), "pipeline/beagle/1kgp_validation/1kgp_ukbb_vars/processing", paste0("bin", bin), sep = "/")
    vcf_in    = paste(outfolder, "ref.vcf.gz", sep = "/")
    vcf_imp   = paste(outfolder, "gts.vcf.gz", sep = "/")
    
    dir.create(outfolder, showWarnings = FALSE)
    
    filter_vcf_by_id(ids_in , vcf_phased, vcf_in )
    filter_vcf_by_id(ids_imp, vcf_gts   , vcf_imp)
    
    imputed_vcf = command_run_beagle         (vcf_in, vcf_imp, outfolder)
    hla_out     = command_extract_hla_convert(imputed_vcf, outfolder)
}

impute = function(bin, ukbb2bin, ukbb_psam, ukbb_pgen_prefix)
{
    ids       = as.character(ukbb2bin[ ukbb2bin$bin == bin, "id"])
    outfolder = paste(getwd(), "pipeline/beagle/processing", paste0("bin", bin), sep = "/")
    bin_file  = paste(outfolder, "ids.txt", sep = "/")
    
    dir.create(outfolder, showWarnings = FALSE)
    
    fwrite(ukbb_psam[ ukbb_psam[,1] %in% ids,], bin_file, sep = "\t", col.names = TRUE, row.names = FALSE)
    
	vcf_ukbb_vars = paste(getwd(), "pipeline/beagle/ukbb_vars_in_1kgp", "ukbb_vars.vcf.gz", sep = "/")
    vcf           = command_convert_to_vcf     (bin_file     , outfolder, ukbb_pgen_prefix)
    imputed_vcf   = command_run_beagle         (vcf_ukbb_vars, vcf, outfolder)
    hla_out       = command_extract_hla_convert(imputed_vcf  , outfolder)
    
    return(hla_out)
}

# Remove random variants

create_random_var_lists = function(random, perm, var_ids)
{
    set.seed(perm)
    var_ids   = sample(var_ids, size = ceiling(length(var_ids) * random/100), replace = FALSE)
    outfolder = paste (outfolder_random, "var_lists" , paste("vars", random, perm, sep = "."), sep = "/")
    prefix    = paste (outfolder, "vars"  , sep = "/")
    outfile   = paste (prefix   , "txt"   , sep = ".")
    vcf       = paste (prefix   , "vcf.gz", sep = ".")
    
    dir.create(outfolder, showWarnings = FALSE)
    
    writeLines(var_ids, outfile, sep = "\n")
    
    command = paste("plink2_64", 
                    "--vcf"    , vcf_phased,
                    "--extract", outfile,
                    "--memory" , 64000,
                    "--threads", 8,
                    "--export" , "vcf", "bgz", "vcf-dosage=DS-force",
                    "--out"   , prefix
                   )

    system(command)

    command = paste("bcftools", "index", "-t", vcf)
    
    system(command)
}

impute_1kgp_random = function(ii, cv2perm, id2cv)
{
    bin       = cv2perm[ii, "bin"     ]
    random    = cv2perm[ii, "random"  ]
    perm      = cv2perm[ii, "perm"    ]
    outfolder = cv2perm[ii, "folder"  ]
    vcf_gts   = cv2perm[ii, "vcf"     ]
    ids_in    = id2cv[ id2cv$bin != bin, "id"]
    ids_imp   = id2cv[ id2cv$bin == bin, "id"]
    outfolder = paste(getwd(), "pipeline/beagle/1kgp_validation/random/processing", paste(paste0("bin", bin), random, perm, sep = "."), sep = "/")
    vcf_in    = paste(outfolder, "ref.vcf.gz", sep = "/")
    vcf_imp   = paste(outfolder, "gts.vcf.gz", sep = "/")
    
    dir.create(outfolder, showWarnings = FALSE)
        
    filter_vcf_by_id(ids_in , vcf_phased, vcf_in )
    filter_vcf_by_id(ids_imp, vcf_gts   , vcf_imp)
    
    imputed_vcf = command_run_beagle         (vcf_in, vcf_imp, outfolder)
    hla_out     = command_extract_hla_convert(imputed_vcf, outfolder)
}

# Run GWAS
