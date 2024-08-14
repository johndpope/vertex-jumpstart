# docker run -it gcr.io/kommunityproject/pytorch-training:v1.04 --env-file ./env.list
docker run -it -e GCS_BUCKET_NAME="gs://jp-ai-experiments" -e BRANCH_NAME="feat/ada-fixed4" -e GITHUB_REPO="https://github.com/johndpope/imf.git" gcr.io/kommunityproject/pytorch-training:v1.04
