echo "Current project set to $GCP_PROJECT"
echo "pytorch-training-job"

echo "job_config.yaml"
cat job_config.yaml

echo "\n\n"


gcloud ai custom-jobs create \
  --project=$GCP_PROJECT \
  --region=us-central1 \
  --display-name=pytorch-training-job \
  --config=job_config.yaml 

  echo  "see jobs training here  🚀 -- https://console.cloud.google.com/vertex-ai/training/custom-jobs
