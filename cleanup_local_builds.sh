#!/bin/bash

# Set the number of latest versions to keep
VERSIONS_TO_KEEP=3

# Function to remove an image
remove_image() {
    local image=$1
    echo "Removing image: $image"
    docker rmi $image
}

# Get all images related to pytorch-training
all_images=$(docker images --format "{{.Repository}}:{{.Tag}} {{.ID}}" | grep "pytorch-training")

# Keep track of the latest versions
declare -A latest_versions

# Process images
while read -r line; do
    repo_tag=$(echo $line | cut -d' ' -f1)
    image_id=$(echo $line | cut -d' ' -f2)
    repo=$(echo $repo_tag | cut -d: -f1)
    tag=$(echo $repo_tag | cut -d: -f2)

    # Skip untagged images
    if [ "$tag" = "<none>" ]; then
        continue
    fi

    # Add to latest versions
    if [[ $tag =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        if [ ${#latest_versions[$repo]} -lt $VERSIONS_TO_KEEP ]; then
            latest_versions[$repo]+=" $repo_tag"
        elif [[ ${latest_versions[$repo]} != *"$repo_tag"* ]]; then
            remove_image $repo_tag
        fi
    fi
done <<< "$all_images"

# Remove untagged images
docker images --format "{{.Repository}}:{{.Tag}} {{.ID}}" | grep "<none>" | while read -r line; do
    image_id=$(echo $line | cut -d' ' -f2)
    remove_image $image_id
done

echo "Cleanup completed."