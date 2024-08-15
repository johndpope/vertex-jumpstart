import time
import os
import subprocess
import argparse
from google.cloud import aiplatform

def get_job_state(job_name):
    job = aiplatform.CustomJob.get(resource_name=job_name)
    return job.state

def play_sound():
    sound_file = '/usr/share/sounds/ubuntu/stereo/system-ready.ogg'
    
    if os.path.exists(sound_file):
        try:
            subprocess.run(['paplay', sound_file], check=True)
        except subprocess.CalledProcessError:
            print("Error playing sound. Make sure 'paplay' is installed.")
    else:
        print("✅ Job is live. check ngrok - https://dashboard.ngrok.com/cloud-edge/endpoints/")

def poll_job_state(job_name):
    print(f"Starting to poll job: {job_name}")
    while True:
        current_state = get_job_state(job_name)
        print(f"Current job state: {current_state}")
        
        if current_state == 3:
            print(f"Job state changed to: {current_state}")
            play_sound()
            break
        
        time.sleep(60)  # Wait for 60 seconds before polling again

def main():
    parser = argparse.ArgumentParser(description="Poll Vertex AI Custom Job State")
    parser.add_argument("job_name", help="Full resource name of the Vertex AI Custom Job")
    args = parser.parse_args()

    # Get the project ID from environment variable
    project_id = os.environ.get('GCP_PROJECT')
    if not project_id:
        raise ValueError("GCP_PROJECT environment variable is not set. Please set it to your Google Cloud project ID.")

    # Initialize the AI Platform client
    aiplatform.init(project=project_id, location='us-central1')

    poll_job_state(args.job_name)

if __name__ == "__main__":
    main()