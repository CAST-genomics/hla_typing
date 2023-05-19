# INTRODUCTION
This readme is focused on the Nextflow implementation in AllOfUs workbench.

## Setup
Tne 'nextflow_parallelization' Jupyter notebook in AllOfUs hlatyping workspace should be cloned into same workspace with different name.  

Please set 2nd Juypter cel "firstrun" parameter to True for first-pass (as some dependencies are installed in later cels/steps based on this param).  General buckets and paths are configured in the early cels before the "Nextflow specific setup and runtime" portion of the notebook.

Previous code was hardcoded (now commented out) into cels, though these dependencies (bwa, samtools, HLAVBSeq, etc.) are now included in docker images.  Docker images are pulled from the public gcr.io for cast (note that currently samtools and bwa used are in separate dockers, and can later be combined in the future).

Additional cels before the "Nextflow..." section set specific parameters for GCR usage, and are dynamically created within jupyter and AoU (not hardcoded in the git site for security purposes).

## Reference files
References are specified in a REF_FOLDER location for usage by Nextflow spinoff agents.

## Basic nextflow run
Starting at the "Nextflow..." section, one or more samples are initially specified along with other parameters in a param file (currently one sample in example, see nextflow channel documentation, e.g. ["sample1","sample2",...] for more parallel design & additional needed updates). 

Json and yaml copies of the parameter file are generated in jupyter notebook and stored to resp. files.  The json file version is used as -param input in nextflow (~cel 23 in jupyter).  The configuration file for nextflow is obtained from AoU (and recommended to follow their notebook example/discussion in AoU workspaces).

Finally, once all config and param files are ready, the following command will run nextflow with the desired sample(s):
```
nextflow run ./main.nf -c ~/.nextflow/config -profile gls -process.container="gcr.io/ucsd-medicine-cast/hla_gatk:latest" -params-file params.json -with-report test_nextflow.html
```

Given length of time of analysis needed per sample (~1hr), it's recommended to use the backgrounding notebook example from AoU to run a full analysis with multiple samples (e.g. clone over that notebook and add the command above to run longer jobs).

## Helpful practices/info
Nextflow outputs are accessible for each task.  The "\[id1/id2\*]" identifier in front of each process is the truncated path identifier to be added to main nextflow gs path (e.g. mynextoutdir = "gs://fc-secure*/test_nextflow/*scratch/\[id1/id2\*]... etc.") for current task and run.  The data can be queried in jupyter or command line (! if in jupyter) via "gsutils -m ls -la $mynextoutdir" or similar.

Nextflow inputs often require a direct access to all available files for a step, including all index files for bwa running.  This was forced in some steps via direct naming (though can be improved in the future)

---------------------------------------------------------------------

