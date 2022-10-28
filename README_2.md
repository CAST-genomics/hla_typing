# HLA typing of the 1000 Genomes individuals
- https://docs.google.com/document/d/1P4pjhqxGSiiUGreC58wWkh44R4045C-ZXWoYzdO0yrM/edit#
- 1KGP BAM files are in http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/phase3/data/
- index data in http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/phase3/20130502.phase3.sequence.index

# High-coverage WGS (3,202 samples)
- https://www.internationalgenome.org/announcements/3202-samples-at-high-coverage-from-NYGC/
- data in https://ftp-trace.ncbi.nlm.nih.gov/1000genomes/ftp/1000G_2504_high_coverage/
- index file: https://ftp-trace.ncbi.nlm.nih.gov/1000genomes/ftp/1000G_2504_high_coverage/1000G_2504_high_coverage.sequence.index
- CRAM info: https://ftp-trace.ncbi.nlm.nih.gov/1000genomes/ftp/README.crams
- Using CRAMs: http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/README_using_1000genomes_cram.md

## Download genotype data from the high-coverage WGS:
- https://ftp-trace.ncbi.nlm.nih.gov/1000genomes/ftp/1000G_2504_high_coverage/working/20201028_3202_phased/

```
cd /frazer01/projects/CEGS/analysis/hla_type_1kgp/input
nohup wget https://ftp-trace.ncbi.nlm.nih.gov/1000genomes/ftp/1000G_2504_high_coverage/working/20201028_3202_raw_GT_with_annot/20201028_CCDG_14151_B01_GRM_WGS_2020-08-05_chr6.recalibrated_variants.vcf.gz &
wget https://ftp-trace.ncbi.nlm.nih.gov/1000genomes/ftp/1000G_2504_high_coverage/working/20201028_3202_raw_GT_with_annot/20201028_CCDG_14151_B01_GRM_WGS_2020-08-05_chr6.recalibrated_variants.vcf.gz.tbi
```

# Set up cache for read CRAMs faster 
- Taken from http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/README_using_1000genomes_cram.md
1. Download the reference file from our FTP site. ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa
2. Run the seq_cache_populate.pl script from samtools - http://www.htslib.org/workflow/#mapping_to_cram  

```
perl samtools/misc/seq_cache_populate.pl -root /path/to/cache /path/to/GRCh38_full_analysis_set_plus_decoy_hla.fa
```

3. Set the cache environment variables 

```
export REF_PATH=/path/to/cache/%2s/%2s/%s:http://www.ebi.ac.uk/ena/cram/md5/%s
>export REF_CACHE=/path/to/cache/%2s/%2s/%s
```

```
bash script/setup_cram_cache.sh
```

# Get 1KGP sample information
```
mkdir input/1kgp
ln -s /frazer01/reference/public/1000Genomes/integrated_call_samples_v3.20130502.ALL.panel input/1kgp/ancestry.txt
ln -s /frazer01/reference/public/1000Genomes/20131219.populations.tsv                      input/1kgp/populations.txt
ln -s /frazer01/reference/public/1000Genomes/20131219.superpopulations.tsv                 input/1kgp/superpopulations.txt
```

# Set up HLA typing on the 1KGP
- prepare_hla_typing.ipynb

## Link SNP VCF
mkdir input/vcf
ln /reference/public/1000Genomes/ALL.chr6.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz     input/vcf/chr6.vcf.gz
ln /reference/public/1000Genomes/ALL.chr6.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz.tbi input/vcf/chr6.vcf.gz.tbi

## Convert HLA types to VCF, combine into one VCF and phase
- first, get maps to phase genotypes:
 - get genetic maps from https://github.com/odelaneau/shapeit4/blob/master/maps/genetic_maps.b37.tar.gz and save to input/phase/
```
tar -xvf input/phase/genetic_maps.b37.tar.gz
mkdir input/phase
ln /frazer01/projects/CEGS/analysis/apoe_haplotypes/input/phase/chr6.b37.gmap.gz input/phase/.
```
- convert_hla_types_to_vcf.ipynb (also imputes in 1kgp for validation)

## Test imputation in 1KGP
- validate_imputation_1kgp.ipynb

## Impute HLA types in UKBB
```
mkdir input/ukbb
ln /frazer01/projects/CEGS/analysis/ukbb_hla_exome/pipeline/traits/vcf/snps.pgen input/ukbb/.
ln /frazer01/projects/CEGS/analysis/ukbb_hla_exome/pipeline/traits/vcf/snps.psam input/ukbb/.
ln /frazer01/projects/CEGS/analysis/ukbb_hla_exome/pipeline/traits/vcf/snps.pvar input/ukbb/.
```

- impute_hla_types.ipynb

# Run GWAS on UKBB HLA types
- go back to /frazer01/projects/CEGS/analysis/ukbb_hla_type_gwas/

# Infer local ancestry
## Kohonen SOM
- local_ancestry_som.ipynb



# OLD
## Impute HLA types
- 10-step cross-validation
- linear regression
- impute_hla_cv.ipynb

## phase with imputed data
- phase_hla.ipynb
