# /usr/bin/bash

cd /frazer01/projects/CEGS/analysis/hla_type_1kgp/input

wget https://ftp-trace.ncbi.nlm.nih.gov/1000genomes/ftp/1000G_2504_high_coverage/1000G_2504_high_coverage.sequence.index
wget https://ftp-trace.ncbi.nlm.nih.gov/1000genomes/ftp/1000G_2504_high_coverage/additional_698_related/1000G_698_related_high_coverage.sequence.index

mkdir cram_cache

cd cram_cache

mkdir cache

wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa

grep "^>" GRCh38_full_analysis_set_plus_decoy_hla.fa > chroms.txt


perl /frazer01/software/samtools-1.9/bin/seq_cache_populate.pl -root /frazer01/projects/CEGS/analysis/hla_type_1kgp/input/cram_cache/cache GRCh38_full_analysis_set_plus_decoy_hla.fa

export REF_PATH=/frazer01/projects/CEGS/analysis/hla_type_1kgp/input/cram_cache/cache/%2s/%2s/%s:http://www.ebi.ac.uk/ena/cram/md5/%s
export REF_CACHE=/frazer01/projects/CEGS/analysis/hla_type_1kgp/input/cram_cache/cache/%2s/%2s/%s

cd /frazer01/projects/CEGS/analysis/hla_type_1kgp
