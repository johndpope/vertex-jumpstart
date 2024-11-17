import time
import os
import subprocess
import argparse
from google.cloud import aiplatform

# Map of job states to human-readable values
JOB_STATES = {
    0: "JOB_STATE_UNSPECIFIED",
    1: "JOB_STATE_QUEUED",
    2: "JOB_STATE_PENDING",
    3: "JOB_STATE_RUNNING",
    4: "JOB_STATE_SUCCEEDED",
    5: "JOB_STATE_FAILED",
    6: "JOB_STATE_CANCELLING",
    7: "JOB_STATE_CANCELLED",
    8: "JOB_STATE_PAUSED"
}

def get_job_state(job_name):
    job = aiplatform.CustomJob.get(resource_name=job_name)
    return job.state

def get_readable_state(state):
    return JOB_STATES.get(state, f"UNKNOWN_STATE_{state}")

def play_sound():
    sound_file = '/usr/share/sounds/ubuntu/stereo/system-ready.ogg'
    
    if os.path.exists(sound_file):
        try:
            subprocess.run(['paplay', sound_file], check=True)
        except subprocess.CalledProcessError:
            print("Error playing sound. Make sure 'paplay' is installed.")

def poll_job_state(job_name, project_id):
    print(f"🔍 Starting to poll job: {job_name}")
    print(f"🏂 Monitor job at: https://console.cloud.google.com/vertex-ai/training/custom-jobs?project={project_id}")
    print("\n")
    
    try:
        while True:
            current_state = get_job_state(job_name)
            readable_state = get_readable_state(current_state)
            print(f"⏳ Current job state: {readable_state} ({current_state})")
            
            # Check for terminal states
            if current_state == 4:  # SUCCEEDED
                print("✅ Job completed successfully!")
                play_sound()
                break
            elif current_state == 5:  # FAILED
                print("❌ Job failed!")
                play_sound()
                break
            elif current_state == 7:  # CANCELLED
                print("🚫 Job was cancelled!")
                play_sound()
                break
            elif current_state == 3:  # RUNNING
                print("🚀 Job is now running!")
                play_sound()
                break
            
            time.sleep(60)  # Wait for 60 seconds before polling again
            
    except KeyboardInterrupt:
        print("\n👋 Polling stopped by user")
    except Exception as e:
        print(f"❌ Error while polling: {str(e)}")

def main():
    parser = argparse.ArgumentParser(description="Poll Vertex AI Custom Job State")
    parser.add_argument("job_name", help="Full resource name of the Vertex AI Custom Job")
    parser.add_argument("--project", help="GCP Project ID", required=True)
    args = parser.parse_args()

    # Initialize the AI Platform client
    aiplatform.init(project=args.project, location='us-central1')

    poll_job_state(args.job_name, args.project)

if __name__ == "__main__":
    main()