#!/usr/bin/sh

source /frazer01/home/aphodges/.bashrc
export REF_PATH=/frazer01/home/aphodges/software/my_hla_typing/input/cram_cache/cache/%2s/%2s/%s:http://www.ebi.ac.uk/ena/cram/md5/%s
export REF_CACHE=/frazer01/home/aphodges/software/my_hla_typing/input/cram_cache/cache/%2s/%2s/%s
Rscript /frazer01/home/aphodges/software/my_hla_typing/script/run_hla_typing.R --taskid $SGE_TASK_ID

