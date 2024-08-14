export GOOGLE_APPLICATION_CREDENTIALS=google_service_key.json
export GCS_BUCKET_NAME="jp-ai-experiments"
gcsfuse --implicit-dirs --key-file=$GOOGLE_APPLICATION_CREDENTIALS $GCS_BUCKET_NAME /mnt/gcs_bucket
