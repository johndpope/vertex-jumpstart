#!/bin/bash

# Set your project ID
PROJECT_ID=$GCP_PROJECT

# Set the Vertex AI Service Agent email
SERVICE_AGENT="service-447983725546@gcp-sa-aiplatform-cc.iam.gserviceaccount.com"

# Grant the Service Agent access to Container Registry
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_AGENT" \
    --role="roles/storage.objectViewer"

echo "Access granted to Vertex AI Service Agent"