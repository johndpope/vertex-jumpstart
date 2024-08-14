echo $GCP_PROJECT
echo $GOOGLE_CLOUD_BUCKET_NAME
export IMAGE_NAME=pytorch-training
DOCKER_BUILDKIT=1 docker build --build-arg="WANDB_API_KEY=$WANDB_KEY"  -t gcr.io/$GCP_PROJECT/$IMAGE_NAME:v1.04 .

docker push gcr.io/$GCP_PROJECT/$IMAGE_NAME:v1.04

# make public gsutil iam ch allUsers:objectViewer gs://artifacts.$GCP_PROJECT.appspot.com
