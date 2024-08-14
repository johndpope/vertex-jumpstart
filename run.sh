#!/bin/bash

# Set your environment variables
export GCP_PROJECT=kommunityproject
export IMAGE_NAME=pytorch-training
export GCS_BUCKET_NAME="gs://jp-ai-experiments"
export BRANCH_NAME="feat/ada-fixed4"
export GITHUB_REPO="https://github.com/johndpope/imf.git"

# Get the latest version
LATEST_TAG=$(gcloud container images list-tags gcr.io/$GCP_PROJECT/$IMAGE_NAME --format='get(tags)' --sort-by=~tags | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -n 1)

if [ -z "$LATEST_TAG" ]; then
  echo "No valid tags found. Make sure you have pushed images with valid version tags."
  exit 1
fi

echo "Latest tag found: $LATEST_TAG"

# Run the Docker container with the latest tag
echo "Running Docker container with the latest tag: $LATEST_TAG"
docker run -it \
  -e GCS_BUCKET_NAME="$GCS_BUCKET_NAME" \
  -e BRANCH_NAME="$BRANCH_NAME" \
  -e GITHUB_REPO="$GITHUB_REPO" \
  gcr.io/$GCP_PROJECT/$IMAGE_NAME:$LATEST_TAG