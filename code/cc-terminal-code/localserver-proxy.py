# app.py
from calendar import c
import os
import re

from flask import Flask, jsonify, request, Response
from flask_cors import CORS
import supabase
import socket
import struct

from dotenv import load_dotenv

app = Flask(__name__)
CORS(app)

load_dotenv()

RCON_HOST = os.getenv('RCON_HOST')
RCON_PORT = int(os.getenv('RCON_PORT', 25575))  
RCON_PASSWORD = os.getenv('RCON_PASSWORD')
SUPABASE_URL = os.getenv('SUPABASE_URL')
SUPABASE_SERVICE_ROLE_KEY = os.getenv('SUPABASE_SERVICE_ROLE_KEY')



@app.route('/')
def home():
    return 'Hello, Flask!'

@app.route('/')
def hello():
    return 'hello world'

# Debug GET route
@app.route('/proxy-test', methods=['GET'])
def debug_get():
    return f'GET request received', 200, {'Content-Type': 'text/plain'}

# Debug POST route
@app.route('/debug-post', methods=['POST'])
def debug_post():
    data = request
    return f'POST request received. Data: {data}', 200, {'Content-Type': 'text/plain'}

@app.route('/api/minecraft-chat', methods=['POST'])
def handle_chat():
    data = request.json
    
    username = data.get('username')
    player_message = data.get('message')
    
    username = username.strip() if username else ''
    player_message = player_message.strip() if player_message else ''
    
    withdraw_pattern = re.compile(r'^!withdraw\s+([1-9][0-9]{0,3}|640000)$')
    inventory_claim_pattern = re.compile(
    r"^!inventory\s+claim\s+([a-zA-Z0-9_.-]+):([a-zA-Z0-9_.-]+)(?:\s+([1-9][0-9]{0,3}|6400))?$"
)
    
    if username and player_message:
        
        if not player_message.startswith('!'):
            return jsonify({'success': True, 'ignored': True})
        
        elif player_message.startswith('!op self'):
            
            if username.strip() != 'CyanidicRapterV3':
                print(f'-> Ignored !op self command from {username}')
                return jsonify({'success': True, 'ignored': True})
            
            command = f'op {username}'
            tellraw_command = f'tellraw {username} "You have been opped!"'
            
            send_rcon_command(command=command)
            send_rcon_command(command=tellraw_command)
    
        elif player_message.startswith('!deop self'):
            
            if username.strip() != 'CyanidicRapterV3':
                print(f'-> Ignored !deop self command from {username}')
                return jsonify({'success': True, 'ignored': True})
            
            command = f'deop {username}'
            tellraw_command = f'tellraw {username} "You have been deopped!"'
            
            send_rcon_command(command=command)
            send_rcon_command(command=tellraw_command)
        
        elif player_message.startswith('!spawn'):
            command = f'tp {username} 0 ~ 0'
            tellraw_command = f'tellraw {username} "Teleporting to spawn!"'
            send_rcon_command(command=command)
            send_rcon_command(command=tellraw_command)
            
        elif withdraw_pattern.match(player_message):
            
            preprocess_command = f'tellraw {username} "Processing your withdraw request..."'
            send_rcon_command(command=preprocess_command)
            
            amount = int(player_message.split()[1])
            
            if amount % 100 != 0:
                tellraw_command = f'tellraw {username} "withdraw amount must be a multiple of 100 to use the !withdraw command. To withdraw amounts not divisible by 100, please use the atm located at spawn."'
                send_rcon_command(command=tellraw_command)
                return jsonify({'success': True, 'ignored': True})
            
            response = withdraw_player_name(amount, username)
            if response:
                
                command = f'give {username} lightmanscurrency:coin_diamond {int(amount/100)}'
                tellraw_command = f'tellraw {username} "withdraw of {amount} successful!"'
                send_rcon_command(command=command)
                send_rcon_command(command=tellraw_command)
            else:
                command = f''
                tellraw_command = f'tellraw {username} "withdraw of {amount} failed! Insufficient funds."'
                send_rcon_command(command=command)
                send_rcon_command(command=tellraw_command)
            
        elif inventory_claim_pattern.match(player_message):
            
            sections = player_message.split()
            
            if len(sections) < 3:
                tellraw_command = f'tellraw {username} "Invalid command format. Use: !inventory claim <minecraft_item_tag> [amount]"'
                send_rcon_command(command=tellraw_command)
                return jsonify({'success': True, 'ignored': True})
            
            minecraft_item_tag = sections[2]
            amount = int(sections[3]) 
            
            preprocess_command = f'tellraw {username} "Processing your inventory claim request for {amount} of {minecraft_item_tag}..."'
            send_rcon_command(command=preprocess_command)
            
            
            response = withdraw_inventory_tag(username, minecraft_item_tag, amount)
            if response:
                command = f'give {username} {minecraft_item_tag} {amount}'
                tellraw_command = f'tellraw {username} "Successfully claimed {amount} of {minecraft_item_tag}!"'
                send_rcon_command(command=command)
                send_rcon_command(command=tellraw_command)
            else:
                command = f''
                tellraw_command = f'tellraw {username} "Failed to claim {amount} of {minecraft_item_tag}. Insufficient quantity in inventory."'
                send_rcon_command(command=command)
                send_rcon_command(command=tellraw_command)
        
        else:
            command = f''
            tellraw_command = f'tellraw {username} "Unknown Command use !help for a list of commands"'
            send_rcon_command(command=command)
            send_rcon_command(command=tellraw_command)
        
        
       # try:
            # Send command using our socket helper instead of mcrcon
        
            
        return jsonify({'success': True})
        
            
    return jsonify({'success': True, 'ignored': True})

@app.route('/login', methods=['POST'])
def login():
    data = request.json
    print(data)
    email = data.get('email')
    password = data.get('password')

    try:
    
        supabase_client = supabase.create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
        
        response = supabase_client.auth.sign_in_with_password({
                    'email': email,
                    'password': password
                })

        user_id = response.user.id
    except:
        return {'error': 'Invalid email or password'}, 401

    # return user_id or an error message
    if user_id:
        #return {'user_id': user_id}, 200
        return Response(user_id, mimetype='text/plain')
    else:
        return {'error': 'Invalid email or password'}, 401

@app.route('/withdraw-1', methods=['POST'])
def withdraw_1():
    data = request.json
    user_id = data.get('user_id')
    amount = data.get('amount')  # Default to 100 if not provided
    response = withdraw(amount, user_id)
    if response:
        return 'withdraw of 1 successful', 200, {'Content-Type': 'text/plain'}
    else:
        return 'withdraw of 1 failed', 400, {'Content-Type': 'text/plain'}

@app.route('/deposit-1', methods=['POST'])
def deposit_1():
    data = request.json
    user_id = data.get('user_id')
    amount = data.get('amount')  # Default to 100 if not provided
    response = deposit(amount, user_id)
    if response:
        return 'Deposit of 1 successful', 200, {'Content-Type': 'text/plain'}
    else:
        return 'Deposit of 1 failed', 400, {'Content-Type': 'text/plain'}


def deposit(amount, user_id):
    supabase_client = supabase.create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
    print(f'Attempting to deposit {amount} for user ID {user_id}')
    response = supabase_client.table('users').select('money').eq('user_id', user_id).execute()
    print(f'Response data: {response.data}')
    if response.data:
        current_balance = response.data[0]['money']
        new_balance = current_balance + amount
        supabase_client.table('users').update({'money': new_balance}).eq('user_id', user_id).execute()
        return True
    else:
        return False
    pass

def withdraw(amount, user_id):
    supabase_client = supabase.create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
    print(f'Attempting to withdraw {amount} for user ID {user_id}')
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

def withdraw_player_name(amount, player_name):
    supabase_client = supabase.create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
    print(f'Attempting to withdraw {amount} for player {player_name}')
    response = supabase_client.table('users').select('money').eq('minecraft_username', player_name).execute()
    if response.data:
        current_balance = response.data[0]['money']
        if current_balance >= amount:
            new_balance = current_balance - amount
            supabase_client.table('users').update({'money': new_balance}).eq('minecraft_username', player_name).execute()
            return True
        else:
            return False
    else:
        return False
    pass

def deposit_player_name(amount, player_name):
    supabase_client = supabase.create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
    print(f'Attempting to deposit {amount} for player {player_name}')
    response = supabase_client.table('users').select('money').eq('minecraft_username', player_name).execute()
    print(f'Response data: {response.data}')
    if response.data:
        current_balance = response.data[0]['money']
        new_balance = current_balance + amount
        supabase_client.table('users').update({'money': new_balance}).eq('minecraft_username', player_name).execute()
        return True
    else:
        return False
    pass

def withdraw_inventory_tag(player_name, minecraft_item_tag, amount):
    supabase_client = supabase.create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
    print(f'Attempting to withdraw {amount} of {minecraft_item_tag} for player {player_name}')
    response = supabase_client.table('inventory').select('quantity, users!inner (user_id, minecraft_username)').eq('minecraft_id', minecraft_item_tag).eq('users.minecraft_username', player_name).execute()
    if response.data:
        user_id = response.data[0]['users']['user_id']
        current_quantity = response.data[0]['quantity']
        if current_quantity >= amount:
            new_quantity = current_quantity - amount
            supabase_client.table('inventory').update({'quantity': new_quantity}).eq('minecraft_id', minecraft_item_tag).eq('user_id', user_id).execute()
            return True
        else:
            return False
    else:
        return False
    pass 




def send_rcon_command(host = RCON_HOST, port = RCON_PORT, password = RCON_PASSWORD, command = ''):
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
                return ''
            length, req_id, cmd_type = struct.unpack('<iii', raw_header)
            
            # Read the payload body based on the packet length (length includes type(4) + id(4) + body + nulls)
            body_length = length - 8
            data = b''
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

if __name__ == '__main__':
    print(RCON_HOST, RCON_PORT, RCON_PASSWORD)
    app.run(host='127.0.0.1', port=5000, debug=False)
    CORS(app)
