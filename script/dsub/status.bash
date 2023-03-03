#!/usr/bin/bash
#modified from AoU example

while getopts p:l:j:u:f: flag
do
    case "${flag}" in
        p) GOOGLE_PROJECT=${OPTARG};;
        l) location=${OPTARG};;
        j) JOB_ID=${OPTARG};;
        u) USERS=${OPTARG};;
    esac
done

echo "dstat \
    --provider google-cls-v2 \
    --project \"${GOOGLE_PROJECT}\" \
    --location us-central1 \
    --jobs \"${JOB_ID}\" \
    --users \"${USER_NAME}\" \
    --status '*' \ 
    --full "
