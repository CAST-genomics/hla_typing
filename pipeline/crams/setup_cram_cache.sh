# /usr/bin/bash
source examples/configs/crams.config

cd $cache_path
perl $script -root $cache_path2 $decoy

export REF_PATH="{$cram_cache}/%2s/%2s/%s:http://www.ebi.ac.uk/ena/cram/md5/%s"
export REF_CACHE="{$cram_cache}/%2s/%2s/%s"
