#!/bin/bash

if [ -z "$GCS_BUCKET_NAME" ]; then
    echo "Error: GCS_BUCKET_NAME not provided"
    exit 1
fi

if [ -z "$BRANCH_NAME" ]; then
    echo "Error: BRANCH_NAME not provided"
    exit 1
fi

if [ -z "$GITHUB_REPO" ]; then
    echo "Error: GITHUB_REPO not provided"
    exit 1
fi

mkdir bla
cd bla
# Clone the repository and checkout the specified branch
git clone $GITHUB_REPO .
git checkout ${BRANCH_NAME}

# Install any needed packages specified in requirements.txt
pip install --no-cache-dir -r requirements.txt

# Mount the GCS bucket using default credentials
gcsfuse --implicit-dirs --key-file='' $GCS_BUCKET_NAME /mnt/gcs_bucket

# Run the training script
python train.py

# Unmount the GCS bucket
fusermount -u /mnt/gcs_bucket