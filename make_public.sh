# Set your variables
echo $GCP_PROJECT
echo $GOOGLE_CLOUD_BUCKET_NAME
export IMAGE_NAME=pytorch-training
export TAG=v1
export REGION=us-central1  # Replace with your actual region
export REPOSITORY_NAME=pytorch-training  # Replace with your actual repository name

# Option 1: Make the entire repository public
gcloud artifacts repositories set-iam-policy $REPOSITORY_NAME \
    --location=$REGION \
    --project=$GCP_PROJECT \
    policy.yaml
