# INTRODUCTION
This code is designed to run the HLA typing pipeline in a linux user environment.  Code depends on minimum versions of R 4.0.* (and library dependencies), Python 3.9, and standard sequencing programs (e.g. bwa mem etc.).  Additionally, the HLA-VBSeq program will need to be installed (http://nagasakilab.csml.org/hla/). 

## HLA typing of individuals from dataset X
Previously, code was designed with X == 1000genomes (1KGP) and related datasets in mind.  Code is currently being revised to accommodate multiple datasets and pipelines as a more flexible strategy.  This includes custom code and designs for AllOfUs and MVP datasets.

## Major steps will include:

### Setup:
0) Install/link appropriate code dependencies
- Added initialize_R.R code to assist in R dependency generation.  Depending on install strategies (e.g. with/without conda) and environment needs, this may need additional updates/tinkering for full functionality.  Download http://nagasakilab.csml.org/hla/HLAVBSeq.jar and set in your bashrc settings/local path.

1) downloading and storing reference files of interest
- Generic reference and index data files should be downloaded/generated.  
- Generic HLA targets (e.g. chrom.6 )... [Note: this designation will likely change to accommodate bacterial/viral targeting as a function of variant/(sub)clade designations

2) Generate, cache and link cram files
- This will also vary slightly between 1KGP, AllOfUs, etc. (as location & strategy depends slightly on storage bucket/needs)... note that 1KGP and AllOfUs store crams differently (est. upcoming feature addition).  Current details for 1KGP listed in README_2.md file.  For AllOfUs, the appropriate cram files should be identified and then included as an input file (note- undergoing revision given most recent config file updates.)

### Current code design:
1) runner from jupyter notebook that calls qsub on the main run_hla_typing
2) Qsub splits jobs into specified sets of queries to do the hla typing step
3) Each query will launch the hla_typing script to run (quick summary):
- bwa mem
- samtools
- HLAVBSeq.jar
4) Finally, run the convert_hla_types_to_vcf.ipynb function to generate vcf files.  This currently includes steps for snp addition, filtering, and phasing.

---------------------------------------------------------------------





## OLDER:
### HLA typing of the 1000 Genomes individuals
### High-coverage WGS (3,202 samples)
### Download genotype data from the high-coverage WGS:
### Set up cache for read CRAMs faster 
- Run the seq_cache_populate.pl script from samtools - http://www.htslib.org/workflow/#mapping_to_cram  
perl samtools/misc/seq_cache_populate.pl -root /path/to/cache /path/to/GRCh38_full_analysis_set_plus_decoy_hla.fa
- Set the cache environment variables 
export REF_PATH=/path/to/cache/%2s/%2s/%s:http://www.ebi.ac.uk/ena/cram/md5/%s
>export REF_CACHE=/path/to/cache/%2s/%2s/%s
```
bash script/setup_cram_cache.sh
```
### Get 1KGP sample information
### Set up HLA typing on the 1KGP
- prepare_hla_typing.ipynb

### Link SNP VCF
### Convert HLA types to VCF, combine into one VCF and phase
- convert_hla_types_to_vcf.ipynb (also imputes in 1kgp for validation)

### Test imputation in 1KGP
- validate_imputation_1kgp.ipynb

### Impute HLA types in UKBB
- impute_hla_types.ipynb

### Run GWAS on UKBB HLA types
- go back to /frazer01/projects/CEGS/analysis/ukbb_hla_type_gwas/

### Infer local ancestry
### Kohonen SOM
- local_ancestry_som.ipynb

### OLD
### Impute HLA types
- 10-step cross-validation
- linear regression
- impute_hla_cv.ipynb

### phase with imputed data
- phase_hla.ipynb
