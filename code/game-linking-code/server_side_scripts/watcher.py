import os
import time
import re
import requests
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

FLASK_API_URL = os.getenv("FLASK_API_URL", "http://localhost:5000/api/minecraft-chat")
LOG_FILE_PATH = os.getenv("MINECRAFT_LOG_PATH")

if not LOG_FILE_PATH:
    raise ValueError("MINECRAFT_LOG_PATH is not set in your .env file!")

def tail_log_file(file_path):
    print(f"Starting Python log watcher, tracking hooks: {file_path}")
    
    while not os.path.exists(file_path):
        print("Waiting for log file to appear...")
        time.sleep(2)

    with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
        f.seek(0, os.SEEK_END)
        
        while True:
            line = f.readline()
            if not line:
                time.sleep(0.1)
                continue
            
            process_log_line(line.strip())

def process_log_line(line):
    # Regex to match our custom KubeJS log hook format
    # Example: [10:45:18] [Server thread/INFO]: MINECRAFT_WEB_HOOK:CyanidicRapterV3:!withdraw 500
    hook_regex = r"MINECRAFT_WEB_HOOK:([a-zA-Z0-9_]{3,16}):(.+)$"
    match = re.search(hook_regex, line)

    if match:
        username = match.group(1)
        message = match.group(2)

        print(f"[Command Triggered] {username}: {message}")

        try:
            response = requests.post(FLASK_API_URL, json={
                "username": username,
                "message": message
            })
            
            if response.status_code == 200:
                data = response.json()
                if not data.get("ignored"):
                    print(f"-> Flask response: {data}")
            else:
                print(f"-> Flask error status: {response.status_code}")

        except requests.exceptions.ConnectionError:
            print("-> Error: Could not connect to Flask server. Is it running?")
        except Exception as e:
            print(f"-> Unexpected error: {e}")

if __name__ == "__main__":
    try:
        tail_log_file(LOG_FILE_PATH)
    except KeyboardInterrupt:
        print("\nStopping log watcher gracefully.")