upload videos / extracted frames to google storage


```shell

gcloud auth application-default login



pip install google-cloud-storage


gsutil mkdir gs://mybucket/celebvhq/35666/images/



gsutil -m cp -r -p /media/2TB/celebvhq/35666/images/* gs://$GOOGLE_CLOUD_BUCKET_NAME/celebvhq/35666/images/

```