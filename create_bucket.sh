#!/bin/bash

# Set your project ID
PROJECT_ID=$GCP_PROJECT  # Replace with your actual project ID

# Set your bucket name
BUCKET_NAME="jp-ai"  # Replace with your desired bucket name

# Create the bucket in the specified project
gsutil mb -p $PROJECT_ID gs://$BUCKET_NAME

echo "Bucket gs://$BUCKET_NAME created in project $PROJECT_ID"

# Optionally, set the project for your current session
gcloud config set project $PROJECT_ID

echo "Current project set to $PROJECT_ID"

echo "🎯 update your .zshrc export GCP_PROJECT=jp-ai with the your bucket name"