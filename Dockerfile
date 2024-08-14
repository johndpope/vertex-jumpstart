# Use an official PyTorch runtime as a parent image
FROM us-docker.pkg.dev/vertex-ai/training/pytorch-xla.2-2.py310:latest

WORKDIR /app

# Install necessary packages
RUN apt-get update && apt-get install -y git curl gnupg lsb-release fuse

# Install gcsfuse
RUN echo "deb http://packages.cloud.google.com/apt gcsfuse-$(lsb_release -c -s) main" | tee /etc/apt/sources.list.d/gcsfuse.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update && \
    apt-get install -y gcsfuse

# Install google-cloud-storage
RUN pip install google-cloud-storage

# Set arguments for the branch name and WandB API key
ARG BRANCH_NAME
ARG WANDB_API_KEY

# Check for WandB API key and log in or throw an error
RUN if [ -z "$WANDB_API_KEY" ]; then \
        echo "Error: WandB API key not provided" && exit 1; \
    else \
        pip install wandb && wandb login $WANDB_API_KEY; \
    fi

# Check for BRANCH_NAME and exit if not provided
RUN if [ -z "$BRANCH_NAME" ]; then \
        echo "Error: BRANCH_NAME not provided" && exit 1; \
    fi

# Clone your repository and checkout the specified branch
RUN git clone https://github.com/johndpope/imf.git . && \
    git checkout ${BRANCH_NAME}

# Install any needed packages specified in requirements.txt
RUN ls -l && \
    cat requirements.txt && \
    pip install --no-cache-dir -r requirements.txt

# Create a mount point for the GCS bucket
RUN mkdir -p /mnt/gcs_bucket

# Make port 8080 available to the world outside this container
EXPOSE 8080

# Copy the start.sh script into the container
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Run the startup script when the container launches
ENTRYPOINT ["/app/start.sh"]