import os
import time
import re
import requests
import json
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
    # Regex to capture everything after MINECRAFT_WEB_HOOK:
    hook_regex = r"MINECRAFT_WEB_HOOK:(.+)$"
    match = re.search(hook_regex, line)

    if match:
        json_str = match.group(1).strip()
        
        try:
            """
            ====================================================================
            INCOMING JSON PAYLOAD REFERENCE (Forwarded from KubeJS -> Watcher -> Flask)
            ====================================================================
            {
                "username": "PlayerName",       # Minecraft username (str)
                "uuid": "uuid-string-here",     # Unique player UUID (str)
                "message": "!withdraw 500",     # Triggered command / message (str)
                "x": 100.52,                    # Exact X coordinate, rounded (float)
                "y": 64.0,                      # Exact Y coordinate (float)
                "z": -204.15,                   # Exact Z coordinate (float)
                "dimension": "minecraft:overworld", # Current dimension ID (str)
                "health": 20.0,                 # Current health points (float)
                "maxHealth": 20.0,              # Maximum health points (float)
                "foodLevel": 20,                # Hunger / food level (int)
                "mainHand": "minecraft:diamond",# Item ID held in main hand (str)
                "gameMode": "survival"          # Current game mode (str)
            }
            ====================================================================
            """
            player_data = json.loads(json_str)
            
            username = player_data.get("username")
            message = player_data.get("message")

            print(f"[Command Triggered] {username}: {message}")

            # Forward the entire dictionary (containing username, message, and all player attributes) to Flask
            response = requests.post(FLASK_API_URL, json=player_data)
            
            if response.status_code == 200:
                data = response.json()
                if not data.get("ignored"):
                    print(f"-> Flask response: {data}")
            else:
                print(f"-> Flask error status: {response.status_code}")

        except json.JSONDecodeError:
            print(f"-> Error: Could not decode JSON from log hook: {json_str}")
        except requests.exceptions.ConnectionError:
            print("-> Error: Could not connect to Flask server. Is it running?")
        except Exception as e:
            print(f"-> Unexpected error: {e}")

if __name__ == "__main__":
    try:
        tail_log_file(LOG_FILE_PATH)
    except KeyboardInterrupt:
        print("\nStopping log watcher gracefully.")