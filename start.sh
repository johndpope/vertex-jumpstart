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


gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS


# Check and remove 'gs://' from GCS_BUCKET_NAME if present
if [[ $GCS_BUCKET_NAME == gs://* ]]; then
    GCS_BUCKET_NAME=${GCS_BUCKET_NAME#gs://}
    echo "Removed 'gs://' prefix from GCS_BUCKET_NAME. New value: $GCS_BUCKET_NAME"
fi

# Mount the GCS bucket using default credentials
echo "Mounting GCS bucket: $GCS_BUCKET_NAME"
gcsfuse --implicit-dirs --key-file=$GOOGLE_APPLICATION_CREDENTIALS $GCS_BUCKET_NAME /mnt/gcs_bucket

if [ $? -eq 0 ]; then
    echo "Successfully mounted GCS bucket to /mnt/gcs_bucket"
else
    echo "Failed to mount GCS bucket. Please check your credentials and bucket name."
    exit 1
fi

# Run the training script
python train.py

# Unmount the GCS bucket
fusermount -u /mnt/gcs_bucket