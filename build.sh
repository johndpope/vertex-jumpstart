#!/bin/bash

# Set your environment variables
echo $GCP_PROJECT
echo $GOOGLE_CLOUD_BUCKET_NAME
export IMAGE_NAME=pytorch-training

# Function to increment version
increment_version() {
  local version=$1
  local delimiter=.
  local array=($(echo "$version" | tr $delimiter '\n'))
  array[$((${#array[@]} - 1))]=$((${array[$((${#array[@]} - 1))]} + 1))
  echo $(local IFS=$delimiter ; echo "${array[*]}")
}

# Get the latest version
LATEST_TAG=$(gcloud container images list-tags gcr.io/$GCP_PROJECT/$IMAGE_NAME --format='get(tags)' --sort-by=~tags | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -n 1)

if [ -z "$LATEST_TAG" ]; then
  NEW_TAG="v1.0.0"
else
  NEW_TAG="v$(increment_version "${LATEST_TAG#v}")"
fi

echo "Building new image with tag: $NEW_TAG"

# Build the Docker image
DOCKER_BUILDKIT=1 docker build --build-arg="WANDB_API_KEY=$WANDB_KEY" -t gcr.io/$GCP_PROJECT/$IMAGE_NAME:$NEW_TAG .

# Ask for confirmation before pushing
read -p "Do you want to push the image gcr.io/$GCP_PROJECT/$IMAGE_NAME:$NEW_TAG to GCR? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # Push the Docker image
    docker push gcr.io/$GCP_PROJECT/$IMAGE_NAME:$NEW_TAG

    NEW_IMAGE_URI="gcr.io/$GCP_PROJECT/$IMAGE_NAME:$NEW_TAG"
    echo "New image pushed: $NEW_IMAGE_URI"

    # Update the job_config.yaml file
    if [ -f "job_config.yaml" ]; then
        sed -i "s|imageUri: '.*'|imageUri: '$NEW_IMAGE_URI'|" job_config.yaml
        echo "Updated job_config.yaml with new Image URI"
        echo "Updated job_config.yaml contents:"
        cat job_config.yaml
    else
        echo "job_config.yaml not found. Please make sure it exists in the current directory."
    fi
else
    echo "Image push cancelled."
fi