#!/bin/bash

# This shell function passes reasonable defaults for several dsub parameters, while
# allowing the caller to override any of them. It creates a nice folder structure within
# the workspace bucket for dsub log files.

# --[ Parameters ]--
# any valid dsub parameter flag

#--[ Returns ]--
# the job id of the job created by dsub

#--[ Details ]--
# The first five parameters below should always be those values when running on AoU RWB.

# Feel free to change the values for --user, --regions, --logging, and --image if you like.

# Note that we insert some job data into the logging path.
# https://github.com/DataBiosphere/dsub/blob/main/docs/logging.md#inserting-job-data

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
