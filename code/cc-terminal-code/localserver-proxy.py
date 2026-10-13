# app.py
import os

from flask import Flask, jsonify, request, Response
from flask_cors import CORS
import supabase
import socket
import struct

from dotenv import load_dotenv

app = Flask(__name__)
CORS(app)

load_dotenv()

RCON_HOST = os.getenv("RCON_HOST")
RCON_PORT = int(os.getenv("RCON_PORT", 25575))  
RCON_PASSWORD = os.getenv("RCON_PASSWORD")



@app.route('/')
def home():
    return 'Hello, Flask!'

@app.route('/')
def hello():
    return 'hello world'

# Debug GET route
@app.route('/proxy-test', methods=['GET'])
def debug_get():
    return f"GET request received", 200, {'Content-Type': 'text/plain'}

# Debug POST route
@app.route('/debug-post', methods=['POST'])
def debug_post():
    data = request
    return f"POST request received. Data: {data}", 200, {'Content-Type': 'text/plain'}

@app.route('/login', methods=['POST'])
def login():
    data = request.json
    print(data)
    email = data.get('email')
    password = data.get('password')

    try:
        SUPABASE_URL = ""
        SUPABASE_SERVICE_ROLE_KEY = ""
        supabase_client = supabase.create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
        
        response = supabase_client.auth.sign_in_with_password({
                    "email": email,
                    "password": password
                })

        user_id = response.user.id
    except:
        return {"error": "Invalid email or password"}, 401

    # return user_id or an error message
    if user_id:
        #return {"user_id": user_id}, 200
        return Response(user_id, mimetype='text/plain')
    else:
        return {"error": "Invalid email or password"}, 401

@app.route('/withdraw-1', methods=['POST'])
def withdraw_1():
    data = request.json
    user_id = data.get('user_id')
    response = withdraw(100, user_id)
    if response:
        return "Withdrawal of 1 successful", 200, {'Content-Type': 'text/plain'}
    else:
        return "Withdrawal of 1 failed", 400, {'Content-Type': 'text/plain'}
    

@app.route('/withdraw-5', methods=['POST'])
def withdraw_5():
    data = request.json
    user_id = data.get('user_id')
    response = withdraw(500, user_id)
    if response:
        return "Withdrawal of 5 successful", 200, {'Content-Type': 'text/plain'}
    else:
        return "Withdrawal of 5 failed", 400, {'Content-Type': 'text/plain'}

@app.route('/withdraw-10', methods=['POST'])
def withdraw_10():
    data = request.json
    user_id = data.get('user_id')
    response = withdraw(1000, user_id)
    if response:
        return "Withdrawal of 10 successful", 200, {'Content-Type': 'text/plain'}
    else:
        return "Withdrawal of 10 failed", 400, {'Content-Type': 'text/plain'}

@app.route('/withdraw-20', methods=['POST'])
def withdraw_20():
    data = request.json
    user_id = data.get('user_id')
    response = withdraw(2000, user_id)
    if response:
        return "Withdrawal of 20 successful", 200, {'Content-Type': 'text/plain'}
    else:
        return "Withdrawal of 20 failed", 400, {'Content-Type': 'text/plain'}

@app.route('/withdraw-32', methods=['POST'])
def withdraw_32():
    data = request.json
    user_id = data.get('user_id')
    response = withdraw(3200, user_id)
    if response:
        return "Withdrawal of 32 successful", 200, {'Content-Type': 'text/plain'}
    else:
        return "Withdrawal of 32 failed", 400, {'Content-Type': 'text/plain'}

@app.route('/withdraw-64', methods=['POST'])
def withdraw_64():
    data = request.json
    user_id = data.get('user_id')
    response = withdraw(6400, user_id)
    if response:
        return "Withdrawal of 64 successful", 200, {'Content-Type': 'text/plain'}
    else:
        return "Withdrawal of 64 failed", 400, {'Content-Type': 'text/plain'}

@app.route('/deposit-1', methods=['POST'])
def deposit_1():
    data = request.json
    user_id = data.get('user_id')
    print(f"user_id is {user_id}")
    response = deposit(100, user_id)
    if response:
        return "Deposit of 1 successful", 200, {'Content-Type': 'text/plain'}
    else:
        return "Deposit of 1 failed", 400, {'Content-Type': 'text/plain'}

@app.route('/deposit-5', methods=['POST'])
def deposit_5():
    data = request.json
    user_id = data.get('user_id')
    response = deposit(500, user_id)
    if response:
        return "Deposit of 5 successful", 200, {'Content-Type': 'text/plain'}
    else:
        return "Deposit of 5 failed", 400, {'Content-Type': 'text/plain'}

@app.route('/deposit-10', methods=['POST'])
def deposit_10():
    data = request.json
    user_id = data.get('user_id')
    response = deposit(1000, user_id)
    if response:
        return "Deposit of 10 successful", 200, {'Content-Type': 'text/plain'}
    else:
        return "Deposit of 10 failed", 400, {'Content-Type': 'text/plain'}

@app.route('/deposit-20', methods=['POST'])
def deposit_20():
    data = request.json
    user_id = data.get('user_id')
    response = deposit(2000, user_id)
    if response:
        return "Deposit of 20 successful", 200, {'Content-Type': 'text/plain'}
    else:
        return "Deposit of 20 failed", 400, {'Content-Type': 'text/plain'}

@app.route('/deposit-32', methods=['POST'])
def deposit_32():
    data = request.json
    user_id = data.get('user_id')
    response = deposit(3200, user_id)
    if response:
        return "Deposit of 32 successful", 200, {'Content-Type': 'text/plain'}
    else:
        return "Deposit of 32 failed", 400, {'Content-Type': 'text/plain'}

@app.route('/deposit-64', methods=['POST'])
def deposit_64():
    data = request.json
    user_id = data.get('user_id')
    response = deposit(6400, user_id)
    if response:
        return "Deposit of 64 successful", 200, {'Content-Type': 'text/plain'}
    else:
        return "Deposit of 64 failed", 400, {'Content-Type': 'text/plain'}

def deposit(amount, user_id):
    SUPABASE_URL = ""
    SUPABASE_SERVICE_ROLE_KEY = ""
    supabase_client = supabase.create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
    print(f"Attempting to deposit {amount} for user ID {user_id}")
    response = supabase_client.table('users').select('money').eq('user_id', user_id).execute()
    print(f"Response data: {response.data}")
    if response.data:
        current_balance = response.data[0]['money']
        new_balance = current_balance + amount
        supabase_client.table('users').update({'money': new_balance}).eq('user_id', user_id).execute()
        return True
    else:
        return False
    pass

def withdraw(amount, user_id):
    SUPABASE_URL = ""
    SUPABASE_SERVICE_ROLE_KEY = ""
    supabase_client = supabase.create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
    print(f"Attempting to withdraw {amount} for user ID {user_id}")
    response = supabase_client.table('users').select('money').eq('user_id', user_id).execute()
    if response.data:
        current_balance = response.data[0]['money']
        if current_balance >= amount:
            new_balance = current_balance - amount
            supabase_client.table('users').update({'money': new_balance}).eq('user_id', user_id).execute()
            return True
        else:
            return False
    else:
        return False
    pass

def send_rcon_command(host, port, password, command):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((host, port))
        
        def send_net_packet(req_id, cmd_type, payload):
            body = payload.encode('utf8') + b'\x00\x00'
            length = len(body) + 8
            packet = struct.pack('<ii', length, req_id) + struct.pack('<i', cmd_type) + body
            s.sendall(packet)

        def read_net_packet():
            # RCON header consists of length (4 bytes), id (4 bytes), type (4 bytes) = 12 bytes total
            raw_header = s.recv(12)
            if len(raw_header) < 12:
                return ""
            length, req_id, cmd_type = struct.unpack('<iii', raw_header)
            
            # Read the payload body based on the packet length (length includes type(4) + id(4) + body + nulls)
            body_length = length - 8
            data = b""
            while len(data) < body_length:
                packet_chunk = s.recv(body_length - len(data))
                if not packet_chunk:
                    break
                data += packet_chunk
            
            return data.decode('utf8', errors='ignore').rstrip('\x00')

        # 1. Authenticate (Type 3)
        send_net_packet(42, 3, password)
        auth_resp = read_net_packet()

        # 2. Execute Command (Type 2)
        send_net_packet(42, 2, command)
        response = read_net_packet()
        return response


@app.route('/api/minecraft-chat', methods=['POST'])
def handle_chat():
    data = request.json
    username = data.get('username')
    message = data.get('message')
    
    if message.strip() == "!claim":
        # --- Database logic here ---
        has_reward = True # Simulated check
        
        if not has_reward:
            return jsonify({"success": False, "reply": f"Sorry {username}, no rewards found."})
        
       # try:
            # Send command using our socket helper instead of mcrcon
        send_rcon_command(RCON_HOST, RCON_PORT, RCON_PASSWORD, f"give {username} diamond 1")
        send_rcon_command(RCON_HOST, RCON_PORT, RCON_PASSWORD, f"tellraw {username} [\"\"][\"Successfully claimed your reward!\"]")
            
        return jsonify({"success": True})
        
            
    return jsonify({"success": True, "ignored": True})

if __name__ == '__main__':
    print(RCON_HOST, RCON_PORT, RCON_PASSWORD)
    app.run(host="127.0.0.1", port=5000, debug=False)
    CORS(app)
