# PyTorch Training on Google Cloud Storage
![Google Cloud Logo](https://cloud.google.com/_static/cloud/images/social-icon-google-cloud-1200-630.png)
This guide will help you get started with training PyTorch models using Google Cloud Storage (GCS) and Google Cloud's AI Platform.

## Prerequisites

1. Google Cloud Platform (GCP) account + (service account for cloud storage access)
   
2. Google Cloud SDK installed and configured
3. Docker installed on your local machine
4. Weights & Biases (wandb) account

## Setup

### 1. Set up Google Cloud Project

1. Create a new Google Cloud Project or select an existing one.
2. Enable the following APIs:
   - Google Cloud Storage
   - AI Platform Training & Prediction
   - Container Registry

![Alt text](just_these.png)

(**PRO TIP** - you may want to toggle on just these to help you find things)


also use this (for branch highlighting) https://ohmyz.sh/



### 2. Set up Google Cloud Storage

1. Create a new GCS bucket:
   ```
   gsutil mb gs://YOUR_BUCKET_NAME
   ```
2. Replace `YOUR_BUCKET_NAME` in the `job_config.yaml` file.

### 3. Configure Environment Variables

Set the following environment variables:

.zshrc
```bash
export GCP_PROJECT=your-project-id
export GOOGLE_CLOUD_BUCKET_NAME=your-bucket-name
export WANDB_KEY=your-wandb-api-key
```

**Use Service Account Key**

Create a service account with the necessary permissions (Storage Admin, Storage Object Creator, etc.) in the Google Cloud Console.
Generate a JSON key for this service account and download it.
google-service-account-key.json


### 4. Uploading Files to Your Bucket

1. Using the Google Cloud Console:
   - Navigate to your bucket
   - Click "Upload files" or drag and drop files into the browser

2. Using the `gsutil` command-line tool:
   ```bash
   pip install google-cloud-storage

   gsutil cp [LOCAL_FILE_PATH] gs://[BUCKET_NAME]/
   
   ```
   
   Example - recursive copy to bucket:
   ```bash
   gsutil mkdir gs://mybucket/celebvhq/35666/images/
   gsutil -m cp -r -p /media/2TB/celebvhq/35666/images/* gs://$GOOGLE_CLOUD_BUCKET_NAME/celebvhq/35666/images/
   ```

3. To upload an entire directory:
   ```bash
   gsutil -m cp -r [LOCAL_DIRECTORY_PATH] gs://[BUCKET_NAME]/
   ```

   Example:
   ```bash
   gsutil -m cp -r ./training_data gs://my-pytorch-bucket/
   ```

## Setting up Google Container Registry

Google Container Registry (GCR) is a private container image registry that runs on Google Cloud. Here's how to set it up for your project:

### 1. Enable the Container Registry API

First, ensure that the Container Registry API is enabled for your project:

1. Go to the [Google Cloud Console](https://console.cloud.google.com/).
2. Select your project.
3. Go to "APIs & Services" > "Dashboard".
4. Click on "+ ENABLE APIS AND SERVICES" at the top.
5. Search for "Container Registry API" and enable it.

### 2. Configure Docker for GCR

To push images to GCR, you need to configure Docker to authenticate with Google Cloud:

```bash
gcloud auth application-default login
gcloud auth configure-docker
```

This command adds credentials to Docker's configuration file, allowing you to push and pull images from GCR.

### 3. Choose a Hosting Location

GCR can host your images in multiple locations. The main options are:

- `gcr.io` (United States)
- `us.gcr.io` (United States)
- `eu.gcr.io` (European Union)
- `asia.gcr.io` (Asia)

Choose the location closest to where you'll be running your training jobs for optimal performance.



## Upgrading the Docker Container

Keeping your training environment up-to-date is crucial for optimal performance and compatibility. Vertex AI provides pre-built containers that are regularly updated with the latest PyTorch versions and dependencies. Here's how to upgrade your Docker container:

### 1. Check for New Container Versions

Visit the [Vertex AI pre-built containers page](https://cloud.google.com/vertex-ai/docs/training/pre-built-containers) to see the latest available versions.

### 2. Update the Dockerfile

Modify your Dockerfile to use the latest base image. For PyTorch with CUDA support, update the first line:

```dockerfile
FROM us-docker.pkg.dev/vertex-ai/training/pytorch-gpu.X-Y.py3Z:latest
```

Replace `X`, `Y`, and `Z` with the latest version numbers from the Vertex AI documentation.

For example, to use PyTorch 2.2 with Python 3.10:

```dockerfile
FROM us-docker.pkg.dev/vertex-ai/training/pytorch-gpu.2-2.py310:latest
```





### 4. Prepare Your PyTorch Code

1. Place your PyTorch training code in a GitHub repository.
2. Update the `GITHUB_REPO` and `BRANCH_NAME` in the `job_config.yaml` file.

### 5. Set up IAM Roles

To train models and view training statistics, you'll need to assign the following roles to your Google Cloud account or service account:

1. **AI Platform Training and Prediction**:
   - `roles/ml.admin`: Full access to AI Platform Training and Prediction resources.
   - `roles/ml.developer`: Permission to submit training jobs and view job details.

2. **Compute Engine**:
   - `roles/compute.viewer`: Permission to view Compute Engine resources (for CPU usage statistics).

3. **Cloud Storage**:
   - `roles/storage.objectAdmin`: Full control of GCS objects.

4. **Container Registry**:
   - `roles/containerregistry.ServiceAgent`: Permission to push and pull Docker images.

To assign these roles:

1. Go to the IAM & Admin section in the Google Cloud Console.
2. Click on "Add" to add a new member or edit an existing one.
3. Enter the user's email or service account.
4. Add the following roles:
   - AI Platform Admin
   - AI Platform Developer
   - Compute Viewer
   - Storage Object Admin
   - Container Registry Service Agent

These roles will allow you to:
- Submit and manage training jobs
- View job details and logs
- Access CPU usage statistics
- Manage storage objects in your GCS bucket
- Push and pull Docker images to/from Container Registry

Note: It's a best practice to follow the principle of least privilege. If you're working in a team or production environment, consider creating custom roles with only the necessary permissions.

## Usage

### 1. Build and Push Docker Image

Run the `build.sh` script to build and push your Docker image:

```bash
./build.sh
```

This script will:
- Build a Docker image with your PyTorch code
- Tag the image with an incremented version
- Push the image to Google Container Registry
- Update the `job_config.yaml` file with the new image URI

### 2. Submit Training Job

Use the `push-job.sh` script to submit your training job:

```bash
./push-job.sh
```

This script will create a custom job on Google Cloud AI Platform using the configuration in `job_config.yaml`.
```yaml

workerPoolSpecs:
  machineSpec:
    machineType: n1-standard-8
    # machineType: n1-standard-32
    # acceleratorType: NVIDIA_TESLA_V100
    # machineType: a2-ultragpu-1g
    # acceleratorType: NVIDIA_A100_80GB
    # acceleratorCount: 1
  replicaCount: 1
  containerSpec:
    imageUri: 'gcr.io/kommunityproject/pytorch-training:v1.0.1'      
    env:
      - name: GCS_BUCKET_NAME
        value: gs://jp-ai-experiments
      - name: BRANCH_NAME
        value: feat/ada-fixed4
      - name: GITHUB_REPO
        value: https://github.com/johndpope/imf.git

```


### 3. Monitor Training Progress and CPU Usage

To view the training progress and CPU usage:

1. Go to the AI Platform Jobs page in the Google Cloud Console.
2. Find your job in the list and click on it.
3. In the job details page, you can see:
   - Job status and duration
   - Logs from your training script
   - Resource utilization graphs, including CPU usage

You can also use the `gcloud` command-line tool to get job information:

```bash
gcloud ai custom-jobs describe JOB_ID
```

Replace `JOB_ID` with your actual job ID.

## File Descriptions

- `Dockerfile`: Defines the Docker image for your PyTorch training environment.
- `build.sh`: Builds and pushes the Docker image, and updates `job_config.yaml`.
- `job_config.yaml`: Configuration file for the AI Platform training job.
- `push-job.sh`: Submits the training job to AI Platform.

## Customization

1. Modify the `Dockerfile` to include any additional dependencies your project requires.
2. Adjust the `job_config.yaml` file to change machine types, accelerators, or environment variables.
3. Update the `build.sh` script if you need to modify the image building process.

## Troubleshooting

- If you encounter permission issues, make sure you have the necessary IAM roles assigned to your Google Cloud account.
- For issues with the Docker image, check the build logs and ensure all dependencies are correctly installed.
- If the training job fails, review the job logs in the Google Cloud Console for error messages.
- If you can't see CPU usage statistics, ensure you have the Compute Viewer role assigned.

## Additional Resources

- [Google Cloud AI Platform Documentation](https://cloud.google.com/ai-platform/docs)
- [PyTorch Documentation](https://pytorch.org/docs/stable/index.html)
- [Weights & Biases Documentation](https://docs.wandb.ai/)
- [Google Cloud IAM Documentation](https://cloud.google.com/iam/docs)

For more detailed information or support, please refer to the official documentation of each tool or service used in this project.