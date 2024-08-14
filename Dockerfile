# Use an official PyTorch runtime as a parent image
FROM us-docker.pkg.dev/vertex-ai/training/pytorch-xla.2-2.py310:latest

WORKDIR /app

# Install git
RUN apt-get update && apt-get install -y git

RUN if [[ "$wandb_key" = "" ]] ; then echo WandB API key not provided ; else wandb login $wandb_key; fi

# Install google-cloud-storage
RUN pip install google-cloud-storage

# Set an argument for the branch name, with a default value
ARG BRANCH_NAME=feat/ada-fixed2
# Set an argument for the WandB API key
ARG WANDB_API_KEY=""


# Check for WandB API key and log in or throw an error
RUN if [ -z "$WANDB_API_KEY" ]; then \
        echo "Error: WandB API key not provided" && exit 1; \
    else \
        pip install wandb && wandb login $WANDB_API_KEY; \
    fi
    
# Clone your repository and checkout the specified branch
RUN git clone https://github.com/johndpope/imf.git . && \
    git checkout ${BRANCH_NAME}

# Install any needed packages specified in requirements.txt
# Note: requirements.txt is now expected to be in the repo
RUN ls -l && \
    cat requirements.txt && \
    pip install --no-cache-dir -r requirements.txt

# Make port 8080 available to the world outside this container
EXPOSE 8080

# Run train.py when the container launches
ENTRYPOINT ["python", "train.py"]