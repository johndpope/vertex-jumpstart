#!/bin/bash

# Enable debug mode
# set -x

# Check if GCP_PROJECT is set
if [ -z "$GCP_PROJECT" ]; then
    echo "Error: GCP_PROJECT environment variable is not set."
    exit 1
fi

echo "Current project set to $GCP_PROJECT"
echo "pytorch-training-job"

# Determine which config file to use
if [ "$GCP_PROJECT" = "pagt-405319" ]; then
    CONFIG_FILE="job_config_gpu.yaml"
else
    CONFIG_FILE="job_config.yaml"
fi

# Use Python script to print the config file
python3 utils/print_config.py "$CONFIG_FILE"


# Create the custom job and capture the output (using process substitution)
echo "🚀 Creating custom job..."
JOB_OUTPUT=$({ gcloud ai custom-jobs create \
  --project=$GCP_PROJECT \
  --region=us-central1 \
  --display-name=pytorch-training-job \
  --config=$CONFIG_FILE 2>&1; })



# echo "🔍 Attempting to extract job ID..."

# Extract using the command line that's shown in the output

# Extract job ID using CustomJob pattern
JOB_NAME=$(echo "$JOB_OUTPUT" | grep "CustomJob" | sed -n 's/.*CustomJob \[\(.*\)\].*/\1/p')

if [ -z "$JOB_NAME" ]; then
    echo "❌ Error: Could not extract job name from output"
    echo "Full output was:"
    echo "$JOB_OUTPUT"
    exit 1
fi

echo -e "\n✅ Job created: $JOB_NAME"
echo -e "🔗 View job at: https://console.cloud.google.com/vertex-ai/training/custom-jobs?project=$GCP_PROJECT\n"

echo "🔄 Starting job polling..."
python3 utils/poll.py "$JOB_NAME" --project "$GCP_PROJECT"