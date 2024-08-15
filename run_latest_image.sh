#!/bin/bash

# Set your environment variables

export IMAGE_NAME="pytorch-train"
export GCS_BUCKET_NAME="gs://jp-ai"
export BRANCH_NAME="feat/ada-fixed4"
export GITHUB_REPO="https://github.com/johndpope/imf.git"

echo "Using image_name :$IMAGE_NAME" 
echo "Using GCP_PROJECT :$GCP_PROJECT" 


# Function to get the latest local tag
get_latest_local_tag() {
    docker images --format '{{.Tag}}' gcr.io/$GCP_PROJECT/$IMAGE_NAME | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -rV | head -n 1
}

# Function to get the latest cloud tag
get_latest_cloud_tag() {
    gcloud container images list-tags gcr.io/$GCP_PROJECT/$IMAGE_NAME --format='get(tags)' --sort-by=~tags | tr ';' '\n' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -rV | head -n 1
}

# Ask user for tag source preference, defaulting to local
read -p "Do you want to use the latest tag from local or cloud? (local/cloud) [default: local]: " tag_source

# Set default to local if no input is provided
tag_source=${tag_source:-local}

if [ "$tag_source" = "local" ]; then
    LATEST_TAG=$(get_latest_local_tag)
    echo "Searching for latest local tag..."
elif [ "$tag_source" = "cloud" ]; then
    LATEST_TAG=$(get_latest_cloud_tag)
    echo "Searching for latest cloud tag..."
else
    echo "Invalid input. Defaulting to local."
    LATEST_TAG=$(get_latest_local_tag)
    echo "Searching for latest local tag..."
fi

# Debug: Print the result of the tag search
echo "Tag search result: $LATEST_TAG"

if [ -z "$LATEST_TAG" ]; then
    echo "Error: No valid tags found. Make sure you have images with valid version tags (format: v1.0.0)."
    exit 1
fi

echo "Latest tag found: $LATEST_TAG"

# Run the Docker container with the latest tag
echo "Running Docker container with the latest tag: $LATEST_TAG"
docker run --rm \
  -e GCS_BUCKET_NAME="$GCS_BUCKET_NAME" \
  -e BRANCH_NAME="$BRANCH_NAME" \
  -e GITHUB_REPO="$GITHUB_REPO" \
  -e GCP_PROJECT="$GCP_PROJECT" \
  gcr.io/$GCP_PROJECT/$IMAGE_NAME:$LATEST_TAG

echo "Docker container execution completed."