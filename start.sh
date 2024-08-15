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

# Create the mount point directory if it doesn't exist
MOUNT_POINT="/mnt/gcs_bucket"
if [ ! -d "$MOUNT_POINT" ]; then
    echo "Creating mount point directory: $MOUNT_POINT"
    sudo mkdir -p $MOUNT_POINT
    sudo chown $USER:$USER $MOUNT_POINT

fi

# Mount the GCS bucket using default credentials
echo "Mounting GCS bucket: $GCS_BUCKET_NAME to $MOUNT_POINT"
gcsfuse  --implicit-dirs --key-file=$GOOGLE_APPLICATION_CREDENTIALS $GCS_BUCKET_NAME $MOUNT_POINT


# echo "Using publically available bucket"
# sudo mkdir -p image-cache
# gcsfuse  --implicit-dirs  --anonymous-access $GCS_BUCKET_NAME $MOUNT_POINT


if [ $? -eq 0 ]; then
    echo "Successfully mounted GCS bucket to $MOUNT_POINT"

        # Sanity check: List contents of the mounted directory
    echo "Performing sanity check - listing contents of $MOUNT_POINT:"
    ls -la $MOUNT_POINT
    
    # Check if the directory is empty
    if [ -z "$(ls -A $MOUNT_POINT)" ]; then
        echo "Warning: The mounted directory appears to be empty."
    else
        echo "Sanity check passed: Directory contains files/folders."
        
        # Optional: List contents of a specific subdirectory if you know it exists
        # For example, if you know there's an 'imf' directory:
        if [ -d "$MOUNT_POINT/imf" ]; then
            echo "Contents of $MOUNT_POINT/celebvhq/35666/images:"
            ls -la $MOUNT_POINT/celebvhq/35666/images
        fi
    fi
else
    echo "Failed to mount GCS bucket. Please check your credentials and bucket name."
    exit 1
fi

echo "Running training.... 🏄"
# Run the training script
python train.py

# Unmount the GCS bucket
fusermount -u /mnt/gcs_bucket