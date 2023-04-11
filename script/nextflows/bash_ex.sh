#!/usr/bin/bash
nextflow run script/nextflows/hlat_main.nf -profile gls -process.container="us.gcr.io/broad-gatk/gatk:4.2.5.0" 
# -c ~/.nextflow/config 
# -params-file params.yaml