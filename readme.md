Cloud Storage
upload videos / extracted frames to google storage



**Required Google Cloud Roles**
```
Logs Viewer role (roles/logging.viewer):
Cloud AI Platform Viewer
AI Platform Admin 
Artifact Registry Create-on-Push Writer 
Compute Admin 
Storage Object User 
Vertex AI administrator
```

```shell

gcloud auth application-default login



pip install google-cloud-storage


gsutil mkdir gs://mybucket/celebvhq/35666/images/



gsutil -m cp -r -p /media/2TB/celebvhq/35666/images/* gs://$GOOGLE_CLOUD_BUCKET_NAME/celebvhq/35666/images/

```