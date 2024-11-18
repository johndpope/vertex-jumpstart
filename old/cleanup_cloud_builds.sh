#!/bin/bash

# Set your GCP project ID
GCP_PROJECT="kommunityproject"
IMAGE_NAME="pytorch-training"

# Function to delete an image
delete_image() {
    local image=$1
    echo "Deleting image: $image"
    gcloud container images delete $image --quiet
}

# Get all tags for the image
tags=$(gcloud container images list-tags gcr.io/$GCP_PROJECT/$IMAGE_NAME --format='get(tags)')

# Sort tags and keep only the latest 3 versions
latest_tags=$(echo "$tags" | tr ';' '\n' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -rV | head -n 3)

# Delete all images except the latest 3 versions
for tag in $tags; do
    if ! echo "$latest_tags" | grep -q "$tag"; then
        delete_image "gcr.io/$GCP_PROJECT/$IMAGE_NAME:$tag"
    fi
done

# Delete untagged images
untagged_images=$(gcloud container images list-tags gcr.io/$GCP_PROJECT/$IMAGE_NAME --filter='-tags:*' --format='get(digest)')
for digest in $untagged_images; do
    delete_image "gcr.io/$GCP_PROJECT/$IMAGE_NAME@$digest"
done

# Delete images from the old project (pagt-405319)
old_project_images=$(gcloud container images list-tags gcr.io/pagt-405319/$IMAGE_NAME --format='get(digest)')
for digest in $old_project_images; do
    delete_image "gcr.io/pagt-405319/$IMAGE_NAME@$digest"
done

echo "Cleanup completed."