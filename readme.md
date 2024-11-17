# Quick GPU Training on Google Cloud
> Spin up GPU instances for temporary PyTorch training jobs on Google Cloud Platform

This guide helps you quickly set up and run GPU-accelerated PyTorch training jobs on Google Cloud. Perfect for running experiments that need a few hours of GPU time without maintaining permanent infrastructure.

## 🚀 Quick Start

1. **Set Environment Variables**
   ```bash
   export GCP_PROJECT=your-project-id
   export GOOGLE_CLOUD_BUCKET_NAME=your-bucket-name
   ```

2. **Submit Training Job**
   ```bash
   ./push-job.sh
   ```

3. **Monitor Progress**
   ```bash
   # Your job URL will appear after submission
   🔗 View job at: https://console.cloud.google.com/vertex-ai/training/custom-jobs?project=$GCP_PROJECT
   ```

<details>
<summary>🔧 Prerequisites</summary>

- Google Cloud Platform (GCP) account
- Google Cloud SDK installed
- Docker installed locally
- Weights & Biases account (optional)

[See setup instructions](#detailed-setup)
</details>

<details>
<summary>⚙️ Configuration</summary>

The `job_config_gpu.yaml` file controls your GPU and environment settings:

```yaml
workerPoolSpecs:
  machineSpec:
    machineType: a2-highgpu-1g  # 40GB GPU
    acceleratorType: NVIDIA_TESLA_A100
    acceleratorCount: 1
  replicaCount: 1
  containerSpec:
    imageUri: 'us-docker.pkg.dev/deeplearning-platform-release/gcr.io/pytorch-cu121.2-2.py310'
    env:
      - name: GCS_BUCKET_NAME
        value: gs://your-bucket
      - name: BRANCH_NAME
        value: your-branch
      - name: GITHUB_REPO
        value: your-repo
```
</details>

<details>
<summary>📦 Storage Setup</summary>

1. Create a GCS bucket:
   ```bash
   ./create_bucket.sh
   ```

2. Upload training data:
   ```bash
   gsutil -m cp -r ./training_data gs://your-bucket/
   ```
</details>

<details>
<summary>🔑 Required Permissions</summary>

Minimum IAM roles needed:
- AI Platform Admin (`roles/ml.admin`)
- Storage Object Admin (`roles/storage.objectAdmin`)
- Container Registry Service Agent
</details>

<details>
<summary>🐛 Troubleshooting</summary>

1. **Job Won't Start**
   - Check IAM permissions
   - Verify GPU quota in your region
   
2. **Storage Access Issues**
   - Test bucket access: `gsutil ls gs://your-bucket`
   - Verify service account permissions

3. **Local Testing**
   ```bash
   # Mount cloud storage locally
   gcsfuse --anonymous-access your-bucket /mount/point
   ```
</details>

<details id="detailed-setup">
<summary>📚 Detailed Setup Guide</summary>

### 1. Enable Required APIs
- Google Cloud Storage
- AI Platform Training & Prediction
- Container Registry

### 2. Shell Configuration
```bash
# Install oh-my-zsh for better CLI experience
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Add to .zshrc
plugins=(git)
export GCP_PROJECT=your-project-id
export GOOGLE_CLOUD_BUCKET_NAME=your-bucket-name
```

### 3. Container Registry Setup
```bash
gcloud auth configure-docker
```

[Full setup documentation available in the original README]
</details>

## 📈 Monitoring

Track your training job:
- Real-time logs
- GPU utilization
- Training metrics

## 🛟 Need Help?

- [Google Cloud AI Platform Documentation](https://cloud.google.com/ai-platform/docs)
- [PyTorch Documentation](https://pytorch.org/docs/stable/index.html)
- Submit an issue for specific questions

