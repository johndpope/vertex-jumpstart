#!/bin/bash

# Set your environment variables
export GOOGLE_APPLICATION_CREDENTIALS=google_service_key.json
export GCS_BUCKET_NAME="jp-ai-experiments"

# Check and remove 'gs://' from GCS_BUCKET_NAME if present
if [[ $GCS_BUCKET_NAME == gs://* ]]; then
    GCS_BUCKET_NAME=${GCS_BUCKET_NAME#gs://}
    echo "Removed 'gs://' prefix from GCS_BUCKET_NAME. New value: $GCS_BUCKET_NAME"
fi

# Create the mount point directory if it doesn't exist
MOUNT_POINT="/mnt/gcs_bucket"
if [ ! -d "$MOUNT_POINT" ]; then
    echo "Creating mount point directory: $MOUNT_POINT"
    sudo mkdir -p $MOUNT_POINT
    sudo chown $USER:$USER $MOUNT_POINT
fi

# Mount the GCS bucket using default credentials
echo "Mounting GCS bucket: $GCS_BUCKET_NAME to $MOUNT_POINT"
gcsfuse --implicit-dirs --key-file=$GOOGLE_APPLICATION_CREDENTIALS $GCS_BUCKET_NAME $MOUNT_POINT

if [ $? -eq 0 ]; then
    echo "Successfully mounted GCS bucket to $MOUNT_POINT"
else
    echo "Failed to mount GCS bucket. Please check your credentials and bucket name."
    exit 1
fi