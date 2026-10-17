import socket
import struct
import time
from dotenv import load_dotenv
import os
import supabase
from server_side_scripts.modules.services.sqlite_assistant_server_side import SqliteAssistantServerSide

load_dotenv()


RCON_HOST = os.getenv('RCON_HOST')
RCON_PORT = int(os.getenv('RCON_PORT', 25575))  
RCON_PASSWORD = os.getenv('RCON_PASSWORD')
SUPABASE_URL = os.getenv('SUPABASE_URL')
SUPABASE_SERVICE_ROLE_KEY = os.getenv('SUPABASE_SERVICE_ROLE_KEY')

def send_rcon_command(host = RCON_HOST, port = RCON_PORT, password = RCON_PASSWORD, command = ''):
    
    print(f"Sending RCON command: {command} to {host}:{port}")
    
    
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


def notify_player(username, message):
    """Sends a formatted chat message to a specific player via RCON."""
    # JSON formatting in tellraw ensures spaces and quotes don't break
    send_rcon_command(command=f'tellraw {username} {{"text": "{message}"}}')

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

def deposit_inventory_tag(player_name, minecraft_item_tag, amount):
    supabase_client = supabase.create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
    print(f'Attempting to deposit {amount} of {minecraft_item_tag} for player {player_name}')
    response = supabase_client.table('inventory').select('quantity, users!inner (user_id, minecraft_username)').eq('minecraft_id', minecraft_item_tag).eq('users.minecraft_username', player_name).execute()
    if response.data:
        user_id = response.data[0]['users']['user_id']
        current_quantity = response.data[0]['quantity']
        new_quantity = current_quantity + amount
        supabase_client.table('inventory').update({'quantity': new_quantity}).eq('minecraft_id', minecraft_item_tag).eq('user_id', user_id).execute()
        return True
    else:
        # If the item doesn't exist in the inventory, create a new entry
        user_response = supabase_client.table('users').select('user_id').eq('minecraft_username', player_name).execute()
        if user_response.data:
            user_id = user_response.data[0]['user_id']
            supabase_client.table('inventory').insert({'minecraft_id': minecraft_item_tag, 'quantity': amount, 'user_id': user_id}).execute()
            return True
        else:
            return False
    pass

def handle_op_self(username, _matches, _data):
    if username.strip() != 'CyanidicRapterV3':
        print(f'-> Ignored !op self command from {username}')
        return
    
    command = f'op {username}'
    tellraw_command = f'tellraw {username} "You have been opped!"'
    
    send_rcon_command(command=command)
    send_rcon_command(command=tellraw_command)

def handle_deop_self(username, _matches, _data):
    if username != 'CyanidicRapterV3':
        print(f'-> Ignored !deop self command from {username}')
        return
    send_rcon_command(command=f'deop {username}')
    notify_player(username, "You have been deopped!")

def handle_spawn(username, _matches, _data):
    send_rcon_command(command=f'tp {username} 0 ~ 0')
    notify_player(username, "Teleporting to spawn!")

def handle_withdraw(username, matches, _data):
    
    amount = int(matches[0])
    
    # 1. Validate multiple constraint
    if amount % 100 != 0:
        notify_player(username, "Withdraw amount must be a multiple of 100. To withdraw amounts not divisible by 100, please use the ATM located at spawn.")
        return

    notify_player(username, "Processing your withdraw request...")
    
    # 2. Call your Supabase withdrawal helper
    success = withdraw_player_name(amount, username)
    
    if success:
        # 100 money per diamond coin (adjust ratio if needed)
        coins = int(amount / 100)
        send_rcon_command(command=f'give {username} lightmanscurrency:coin_diamond {coins}')
        notify_player(username, f"Withdraw of {amount} successful!")
    else:
        notify_player(username, f"Withdraw of {amount} failed! Insufficient funds.")

def handle_inventory_claim(username, matches, _data):
    # matches[0] is namespace, matches[1] is item name (e.g., 'mod:item')
    # Let's combine them securely or use the pattern groups cleanly:
    # If your regex captures them separately as group 0 and 1, adjust accordingly:
    # Assuming group 0 is the full item tag or namespace:item based on your regex:
    
    name_space = matches[0]
    item_name = matches[1]
    item_tag = f"{name_space}:{item_name}"
    # Handle amount if captured in the third regex group, else default to 1
    amount = int(matches[2]) if len(matches) > 2 and matches[2] else 1
    
    notify_player(username, f"Processing your inventory claim for {amount} of {item_tag}...")
    
    # 1. Call your Supabase inventory helper
    success = withdraw_inventory_tag(username, item_tag, amount)
    
    if success:
        send_rcon_command(command=f'give {username} {item_tag} {amount}')
        notify_player(username, f"Successfully claimed {amount} of {item_tag}!")
    else:
        notify_player(username, f"Failed to claim {amount} of {item_tag}. Insufficient quantity in inventory.")



def handle_inventory_deposit(username, matches, _data):
    # matches[0] is namespace, matches[1] is item name (e.g., 'mod:item')
    # Let's combine them securely or use the pattern groups cleanly:
    # If your regex captures them separately as group 0 and 1, adjust accordingly:
    # Assuming group 0 is the full item tag or namespace:item based on your regex:
    
    name_space = matches[0]
    item_name = matches[1]
    item_tag = f"{name_space}:{item_name}"
    # Handle amount if captured in the third regex group, else default to 1
    amount = int(matches[2]) if len(matches) > 2 and matches[2] else 1
    
    if amount == -99:
        notify_player(username, f"You do not have any of {item_tag} in your inventory to deposit.")
        return
    
    elif amount <= 0:
        notify_player(username, f"Invalid deposit amount: {amount}. Please specify a positive number.")
        return
    
    notify_player(username, f"Processing your inventory deposit for {amount} of {item_tag}...")
    
    # 1. Call your Supabase inventory helper
    success = deposit_inventory_tag(username, item_tag, amount)
    
    if success:
        notify_player(username, f"Successfully deposited {amount} of {item_tag}!")
    else:
        notify_player(username, f"Failed to deposit {amount} of {item_tag}. Insufficient quantity in inventory.")

def handle_inventory_list(username, _matches, _data):
    supabase_client = supabase.create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
    response = supabase_client.table('inventory').select('minecraft_id, quantity, users!inner (user_id, minecraft_username)').eq('users.minecraft_username', username).execute()
    
    if response.data:
        for item in response.data:
            item_tag = item['minecraft_id']
            quantity = item['quantity']
            notify_player(username, f"Item: {item_tag}, Quantity: {quantity}")
    else:
        notify_player(username, "Your inventory is empty.")

def handle_home_go(username, _matches, _data):
    
    with SqliteAssistantServerSide() as db:
        try:
            home = db.get_home_coordinates_for_user(username)
            
            notify_player(username, "Teleporting in 3 seconds...")
            
            time.sleep(1)
            notify_player(username, "Teleporting in 2 seconds...")
            
            time.sleep(1)
            notify_player(username, "Teleporting in 1 second...")
            
            time.sleep(1)
            
            send_rcon_command(command=f'tp {username} {home.x_cord} {home.y_cord} {home.z_cord}')
            notify_player(username, f"Teleported to your home at ({home.x_cord}, {home.y_cord}, {home.z_cord})!")
        except ValueError as e:
            notify_player(username, str(e))

def handle_home_set(username, _matches, data):
    
    with SqliteAssistantServerSide() as db:
        # Get the player's current position using RCON
        x=data.get('x')
        y=data.get('y')
        z=data.get('z')
        
        # The response will be in the format: "Pos: [x, y, z]"
        try:
            db.set_home_coordinates_for_user(username, x, y, z)
            notify_player(username, f"Home set at ({x}, {y}, {z})!")
        except Exception as e:
            notify_player(username, f"Failed to set home: {str(e)}")