# Documents and code for nextflow runner design.

## Basic overview:
The AllOfUs workbench includes support for wdl/cromwell and nextflow manager solutions.  This implementation of the AoU nextflow design will be implemented first in hla-typing and extended to other CAST project workflows in AoU.

The nextflow manager uses a very python-friendly language in order to create workflow connections between elements.  The AOU documentation and examples include the following links which should be reviewed, and the corresponding nf runner example from aou is included in this folder (in much more abbreviated code.).

## Important point:
More details will be aded here for the workflow implementation.  The major considerations are 1) inputs and aou-specific formatting with the GCP buckets etc, 2) cram-based files read into HLA with chr6 subselection (to minimize local file space usage), 3) parallelization for multi-cram execution, 4) results summarization, 5) summaries that are allowable for external download & analysis.

