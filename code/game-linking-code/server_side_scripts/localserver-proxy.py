# app.py
from calendar import c

import re
import sys
import os

from flask import Flask, jsonify, request, Response
from flask_cors import CORS


parent_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
if parent_dir not in sys.path:
    sys.path.insert(0, parent_dir)


from modules.utility.local_server_utility import *

from dotenv import load_dotenv

app = Flask(__name__)
CORS(app)




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
    
    data = request.json or {}
    username = data.get('username', '').strip()
    player_message = data.get('message', '').strip()
    
    COMMAND_ROUTES = [
    (re.compile(r'^!op\s+self$'), handle_op_self),
    (re.compile(r'^!deop\s+self$'), handle_deop_self),
    (re.compile(r'^!spawn$'), handle_spawn),
    (re.compile(r'^!withdraw\s+([1-9][0-9]{0,3}|640000)$'), handle_withdraw),
    (re.compile(r'^!inventory\s+claim\s+([a-zA-Z0-9_.-]+):([a-zA-Z0-9_.-]+)(?:\s+([1-9][0-9]{0,3}|6400))?$'), handle_inventory_claim),
    (re.compile(r'^!inventory\s+deposit\s+([a-zA-Z0-9_.-]+):([a-zA-Z0-9_.-]+)(?:\s+(-?[1-9][0-9]{0,3}|-?6400|0))?$' ), handle_inventory_deposit),
    (re.compile(r'^!inventory\s+list$'), handle_inventory_list),
    (re.compile(r'^!home\s+go$'), handle_home_go),
    (re.compile(r'^!home\s+set$'), handle_home_set),
    (re.compile(r'^!player_join$'), handle_player_join),
    ]
    
    # Ignore empty messages or non-commands
    if not username or not player_message or not player_message.startswith('!'):
        return jsonify({'success': True, 'ignored': True})
    
    # Loop through our route table to find a matching pattern
    for pattern, handler in COMMAND_ROUTES:
        match = pattern.match(player_message)
        if match:
            # Pass captured regex groups (if any) directly to the handler
            handler(username, match.groups(), data)
            return jsonify({'success': True})
    
    # Fallback if command starts with '!' but matches nothing
    notify_player(username, "Unknown command. Use !help for a list of commands.")
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


if __name__ == '__main__':
    print(RCON_HOST, RCON_PORT, RCON_PASSWORD)
    app.run(host='127.0.0.1', port=5000, debug=False)
    CORS(app)
