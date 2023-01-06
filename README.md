# INTRODUCTION
This code is designed to run the HLA typing pipeline in a linux user environment.  Code depends on minimum versions of R 4.0.* (and library dependencies), Python 3.9, and standard sequencing programs (e.g. bwa mem etc.).  Additionally, the HLA-VBSeq program will need to be installed (http://nagasakilab.csml.org/hla/). 

## HLA typing of individuals
The CAST HLAT code repo has been redesigned to accomodate analyses in the AllOfUs and MVP/VA analysis environments.
Previously, code was designed to use 1000 Genomes' and related datasets in an internal server environment at UCSD.  

## Setup

### Pre-installs:
0) Install/link appropriate code dependencies
-*Updated: major dependencies for main runners are python based and can be directly pip installed through the jupyter notebook in AoU.

- Older: added initialize_R.R code to assist in R dependency generation.  Depending on install strategies (e.g. with/without conda) and environment needs, this may need additional updates/tinkering for full functionality.  

0b) Download this github repo into the local folder for AoU workbench (ideally within project for simpler path usage... some updates anticipated to further streamline this step).  Copy jupyter notebook cells for starting permissons/file access/etc (this can be further automated in the future.).

0c) Wget/curl the HLAVBSeq.jar file from externally for usage by the workflow runner.

### Manifest and sample specification:
1) Copy & update manifest*.xlsx to local directory and modify to include your samples of interest.  The target cram field should be the absolute path to respective cram file in AoU.  Local cram/sample field should be the name of the output .cram to be used throughout rest of analysis.

### Reference specification:
2) downloading and storing reference files of interest
- Generic reference and index data files should be downloaded/generated.  Some references used are already available through the AoU workbench.  For AoU workbench, this can be done through the jupyter environment via creating a new file & copying contents into the file & saving.  Other references will be pulled directly from github.
- Generic HLA targets (e.g. chrom.6 )... this will include the hg38.bed and alleles.txt files from Frazer server.

3) Some minor folder updates may be needed prior to executing the outer jupyter notebook.  

### Current code workflow and execution:
1) Runner first reads the config files with path locations & reference info
2) Next, the manifest.xlsx file is read to identify samples to be used in analysis
3) A bash .sh runner is generated to include all commands to be run per sample.  This will then be used in a future Nextflow/cromwell runner script (*WIP).  Additionally, a new bsub header module was added to further automate runs in selected environments.
4) Each query will launch the hla_typing script to run (quick summary):
- bwa mem
- samtools
- HLAVBSeq.jar
- R HlA reporting script
4) (Finally, run the convert_hla_types_to_vcf.ipynb function to generate vcf files.  This currently includes steps for snp addition, filtering, and phasing. -WIP).
---------------------------------------------------------------------

