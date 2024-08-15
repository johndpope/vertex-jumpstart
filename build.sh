#!/bin/bash

# Function to check if an environment variable is set
check_env_var() {
    if [ -z "${!1}" ]; then
        echo "Error: $1 is not set. Please set this environment variable before running the script."
        exit 1
    fi
}

# Check required environment variables
check_env_var "GCP_PROJECT"
check_env_var "GOOGLE_CLOUD_BUCKET_NAME"
check_env_var "WANDB_KEY"

# Set your environment variables
echo "Project name: $GCP_PROJECT"

echo "Target bucket name: $GOOGLE_CLOUD_BUCKET_NAME"
export IMAGE_NAME=pytorch-train
echo "Target image name: $IMAGE_NAME"

# Function to increment version
increment_version() {
  local version=$1
  local delimiter=.
  local array=($(echo "$version" | tr $delimiter '\n'))
  array[$((${#array[@]} - 1))]=$((${array[$((${#array[@]} - 1))]} + 1))
  echo $(local IFS=$delimiter ; echo "${array[*]}")
}

# Get the latest version
LATEST_TAG=$(gcloud container images list-tags gcr.io/$GCP_PROJECT/$IMAGE_NAME --format='get(tags)' --sort-by=~tags | tr ';' '\n' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -rV | head -n 1)

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
        sed -i "s|value: gs://.*|value: gs://$GOOGLE_CLOUD_BUCKET_NAME|" job_config.yaml
        echo "Updated job_config.yaml with new Image URI and bucket name"
        echo "Updated job_config.yaml contents:"
        cat job_config.yaml
    else
        echo "job_config.yaml not found. Please make sure it exists in the current directory."
    fi
else
    echo "Image push cancelled."
fi

echo "IAM policies updated. Your job_config.yaml has been updated to run latest build version..."
echo "Now run ./push-job.sh to fire up training job 🚀"

# Ask for confirmation before pushing
read -p "To access the storage bucket you need to grant iam policy binding for service account (y/n) " -n 1 -r
echo
# Update the IAM policy binding
# Assign Storage Object Viewer role
gcloud projects add-iam-policy-binding $GCP_PROJECT \
    --member=serviceAccount:$GCP_PROJECT@appspot.gserviceaccount.com \
    --role=roles/storage.objectViewer

# Assign Logs Writer role to Cloud ML service account
gcloud projects add-iam-policy-binding $GCP_PROJECT \
    --member=serviceAccount:$GCP_PROJECT@appspot.gserviceaccount.com \
    --role=roles/logging.logWriter

# Assign AI Platform User role
gcloud projects add-iam-policy-binding $GCP_PROJECT \
    --member=serviceAccount:$GCP_PROJECT@appspot.gserviceaccount.com \
    --role=roles/aiplatform.user

echo "IAM policies updated. Your job_config.yaml has been updated to run latest build version..."
echo "Now run ./push-job.sh to fire up training job 🚀"