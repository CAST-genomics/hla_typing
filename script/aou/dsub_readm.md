# DSUB handler for AllOfUs

## Description:
The dsub handler is being added to allow quick parallelization with qsub/bsub-like behavior for parallel job submission and tracking (an alternative/in addition to Nextflow handler for AoU and UKB).

## Getting Started:
AOU provides the following link for tsv format with parameters: https://github.com/Databiosphere/dsub#tasks-file-format

<!-- Notebook examples in researcher workbench: -->
<!-- https://workbench.researchallofus.org/workspaces/aou-rw-64c07d34/howtousedsubintheresearcherworkbench/notebooks -->

## Dsub setup:
Jupyter code: https://workbench.researchallofus.org/workspaces/aou-rw-64c07d34/howtousedsubintheresearcherworkbench/notebooks/preview/1.%20dsub%20set%20up.ipynb \n
!pip3 install --upgrade dsub
%%bash
dsub --help

%%writefile ~/aou_dsub.bash
function aou_dsub () {

  # Get a shorter username to leave more characters for the job name.
  local DSUB_USER_NAME="$(echo "${OWNER_EMAIL}" | cut -d@ -f1)"

  # For AoU RWB projects network name is "network".
  local AOU_NETWORK=network
  local AOU_SUBNETWORK=subnetwork

  dsub \
      --provider google-cls-v2 \
      --user-project "${GOOGLE_PROJECT}"\
      --project "${GOOGLE_PROJECT}"\
      --image 'marketplace.gcr.io/google/ubuntu1804:latest' \
      --network "${AOU_NETWORK}" \
      --subnetwork "${AOU_SUBNETWORK}" \
      --service-account "$(gcloud config get-value account)" \
      --user "${DSUB_USER_NAME}" \
      --regions us-central1 \
      --logging "${WORKSPACE_BUCKET}/dsub/logs/{job-name}/{user-id}/$(date +'%Y%m%d/%H%M%S')/{job-id}-{task-id}-{task-attempt}.log" \
      "$@"
}

aou_dsub --help | more
<!-- can add to bashrc, eg  %%bash \n echo source ~/aou_dsub.bash >> ~/.bashrc -->
