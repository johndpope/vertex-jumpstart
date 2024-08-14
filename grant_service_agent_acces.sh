#!/bin/bash

# Set your project ID
PROJECT_ID=$GCP_PROJECT

# Set the Vertex AI Service Agent email
# This format should work for any project
SERVICE_AGENT="service-${PROJECT_NUMBER}@gcp-sa-aiplatform.iam.gserviceaccount.com"

# Get the project number
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')

# Grant the Service Agent access to Container Registry
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_AGENT" \
    --role="roles/storage.objectViewer"

echo "Storage Object Viewer role granted to Vertex AI Service Agent"

# Grant Vertex AI Service Agent role
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_AGENT" \
    --role="roles/aiplatform.serviceAgent"

echo "Vertex AI Service Agent role granted"

# Grant Artifact Registry Reader role
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_AGENT" \
    --role="roles/artifactregistry.reader"

echo "Artifact Registry Reader role granted to Vertex AI Service Agent"

echo "All necessary roles have been granted to the Vertex AI Service Agent"