# Set your variables
SOURCE_DIR="/media/2TB/celebvhq/35666/images"
ZIP_FILE="celebvhq_35666_images.zip"
GCS_BUCKET="jp-ai"

# Check if the source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory $SOURCE_DIR does not exist."
    exit 1
fi

# Create the zip file
echo "Creating zip file..."
zip -r "$ZIP_FILE" "$SOURCE_DIR"

if [ $? -ne 0 ]; then
    echo "Error: Failed to create zip file."
    exit 1
fi

echo "Zip file created successfully: $ZIP_FILE"

# Upload the zip file to Google Cloud Storage
echo "Uploading to Google Cloud Storage..."
gsutil cp "$ZIP_FILE" "gs://$GCS_BUCKET/"

if [ $? -ne 0 ]; then
    echo "Error: Failed to upload to Google Cloud Storage."
    exit 1
fi

echo "Upload successful. File available at: gs://$GCS_BUCKET/$ZIP_FILE"

# Optionally, remove the local zip file
# Uncomment the next line if you want to delete the local zip file after upload
# rm "$ZIP_FILE"

echo "Process completed successfully."