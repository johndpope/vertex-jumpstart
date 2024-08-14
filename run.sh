#!/bin/bash

# Set your environment variables
export GCP_PROJECT=kommunityproject
export IMAGE_NAME="pytorch-training"
export GCS_BUCKET_NAME="gs://jp-ai-experiments"
export BRANCH_NAME="feat/ada-fixed4"
export GITHUB_REPO="https://github.com/johndpope/imf.git"

# Debug: Print all tags
echo "All tags:"
gcloud container images list-tags gcr.io/$GCP_PROJECT/$IMAGE_NAME --format='get(tags)' --sort-by=~tags

# Get the latest version
LATEST_TAG=$(gcloud container images list-tags gcr.io/$GCP_PROJECT/$IMAGE_NAME --format='get(tags)' --sort-by=~tags | tr ';' '\n' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -rV | head -n 1)

# Debug: Print the result of the tag search
echo "Tag search result: $LATEST_TAG"

if [ -z "$LATEST_TAG" ]; then
  echo "Error: No valid tags found. Make sure you have pushed images with valid version tags (format: v1.0.0)."
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