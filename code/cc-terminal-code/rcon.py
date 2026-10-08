from flask import Flask, request, jsonify
from mcrcon import MCRcon

app = Flask(__name__)

RCON_HOST = "127.0.0.1"
RCON_PORT = 25575
RCON_PASSWORD = "admin"

@app.route('/api/minecraft-chat', methods=['POST'])
def handle_chat():
    data = request.json
    username = data.get('username')
    message = data.get('message')
    
    # Check if the message is a specific trigger, e.g., "!claim"
    if message.strip() == "!claim":
        # --- 1. Query your cloud database here ---
        # has_reward = db.check_reward(username)
        has_reward = True # Simulated check
        
        if not has_reward:
            return jsonify({"success": False, "reply": f"Sorry {username}, no rewards found."})
        
        # --- 2. Execute command via RCON ---
        try:
            with MCRcon(RCON_HOST, RCON_PASSWORD, port=RCON_PORT) as mcr:
                mcr.command(f"give {username} diamond 1")
                mcr.command(f"tellraw {username} [\"\"][\"Successfully claimed your reward!\"]")
                
            return jsonify({"success": True})
        except Exception as e:
            return jsonify({"success": False, "error": str(e)}), 500
            
    return jsonify({"success": True, "ignored": True})

if __name__ == '__main__':
    app.run(port=5000)