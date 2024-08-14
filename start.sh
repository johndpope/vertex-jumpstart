#!/bin/bash


gcsfuse --implicit-dirs "gs://jp-ai-experiments" /mnt/gcs_bucket

python train.py

fusermount -u /mnt/gcs_bucket