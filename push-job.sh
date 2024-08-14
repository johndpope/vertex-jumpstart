cat job_config.yaml

gcloud ai custom-jobs create \
  --project=kommunityproject \
  --region=us-central1 \
  --display-name=pytorch-training-job \
  --config=job_config.yaml 

  echo "🏂 see jobs training here -- https://console.cloud.google.com/vertex-ai/training/custom-jobs"