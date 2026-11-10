import sqlite3
from threading import local
from typing import Optional

from supabase import Client

from server_side_scripts.modules.classes.home import Home

FIRST = 0

class SqliteAssistantServerSide:
    
    
    def __init__(self,) -> None:
        
        self.conn = sqlite3.connect("local.db", timeout=10)
        self.conn.row_factory = sqlite3.Row
        self.conn.execute("PRAGMA journal_mode=WAL;")
        self.conn.execute("PRAGMA busy_timeout = 10000;")
        
        
        self.__init_tables__()
    
    
    def __init_tables__(self):
        
        with self.conn:
            
            cursor = self.conn.cursor()
            cursor.execute("""
    CREATE TABLE IF NOT EXISTS home (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        x_cord INTEGER NOT NULL DEFAULT 0,
        y_cord INTEGER NOT NULL DEFAULT 0,
        z_cord INTEGER NOT NULL DEFAULT 0,
        username TEXT NOT NULL DEFAULT ''
    );
""")
            
            cursor.close()
    
    def __enter__(self):
        return self
    
    def __exit__(self, exc_type, exc, traceback):
        self.conn.close()
        
    def get_home_coordinates_for_user(self, username: str) -> Home:
        
        cursor = self.conn.cursor()
        
        cursor.execute("SELECT * FROM home WHERE username = ?", (username,))
        home = cursor.fetchone()
        
        cursor.close()
        
        if home is None:
            raise ValueError(f"No home found for user '{username}'")
        
        return Home(
            x_cord=home["x_cord"],
            y_cord=home["y_cord"],
            z_cord=home["z_cord"],
            username=home["username"]
        )
    
    def set_home_coordinates_for_user(self, username: str, x_cord: int, y_cord: int, z_cord: int) -> None:
        
        cursor = self.conn.cursor()
        
        cursor.execute("SELECT * FROM home WHERE username = ?", (username,))
        home = cursor.fetchone()
        
        if home is None:
            cursor.execute(
                "INSERT INTO home (username, x_cord, y_cord, z_cord) VALUES (?, ?, ?, ?)",
                (username, x_cord, y_cord, z_cord)
            )
        else:
            cursor.execute(
                "UPDATE home SET x_cord = ?, y_cord = ?, z_cord = ? WHERE username = ?",
                (x_cord, y_cord, z_cord, username)
            )
        
        self.conn.commit()
        cursor.close()
    
            
    
    
        