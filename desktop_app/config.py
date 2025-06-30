import os
import sys
import json
from dotenv import load_dotenv
from nanoid import generate

# ✅ Get correct base path
def get_base_path():
    return getattr(sys, '_MEIPASS', os.path.abspath("."))

# ✅ Get writeable path for persistent data
def get_writable_data_path():
    base = os.path.dirname(sys.executable) if getattr(sys, 'frozen', False) else os.path.abspath(".")
    data_dir = os.path.join(base, "local_data")
    os.makedirs(data_dir, exist_ok=True)
    return data_dir

# 📁 Paths
RESOURCE_PATH = get_base_path()
DATA_DIR = get_writable_data_path()
USER_ID_FILE = os.path.join(DATA_DIR, "user_id.txt")
WHITELIST_FILE = os.path.join(DATA_DIR, "whitelist.json")
BLACKLIST_FILE = os.path.join(DATA_DIR, "blacklist.json")

# 🔐 Load .env
load_dotenv(dotenv_path=os.path.join(RESOURCE_PATH, ".env"))

# 🔧 Config variables
FIREBASE_URL = os.getenv("FIREBASE_URL")
API_KEY = os.getenv("API_KEY")
POLL_INTERVAL = int(os.getenv("POLL_INTERVAL", 5))
DISTRACTION_PROMPT_INTERVAL = int(os.getenv("DISTRACTION_PROMPT_INTERVAL", 60))

# 🔑 Unique user ID
def generate_user_id(length=8):
    return generate('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', length)

def get_or_create_user_id():
    if os.path.exists(USER_ID_FILE):
        with open(USER_ID_FILE, "r") as f:
            return f.read().strip()
    user_id = generate_user_id()
    with open(USER_ID_FILE, "w") as f:
        f.write(user_id)
    return user_id

USER_ID = get_or_create_user_id()

# ✅ Default app lists
DEFAULT_WHITELIST = {
    "allowed_apps": [
        "Notion.exe", "Code.exe", "Word.exe", "Excel.exe", "PowerPoint.exe",
        "Acrobat.exe", "obsidian.exe", "pycharm64.exe", "idea64.exe", "chrome.exe",
        "firefox.exe", "Postman.exe", "Teams.exe", "Zoom.exe", "OneNote.exe",
        "Outlook.exe"
    ]
}

DEFAULT_BLACKLIST = {
    "distraction_apps": [
        "YouTube.exe", "Discord.exe", "Instagram.exe", "WhatsApp.exe", "Telegram.exe",
        "Snapchat.exe", "Netflix.exe", "Facebook.exe", "Reddit.exe", "Steam.exe",
        "Valorant.exe", "EpicGamesLauncher.exe", "robloxplayerbeta.exe", "Twitch.exe",
        "TikTok.exe", "OperaGX.exe", "Messenger.exe", "VLC.exe", "CrabGame.exe",
        "LeagueClient.exe", "Spotify.exe"
    ]
}

# ✅ Ensure files exist
def ensure_default_json_files():
    if not os.path.exists(WHITELIST_FILE):
        with open(WHITELIST_FILE, "w") as f:
            json.dump(DEFAULT_WHITELIST, f, indent=2)
    if not os.path.exists(BLACKLIST_FILE):
        with open(BLACKLIST_FILE, "w") as f:
            json.dump(DEFAULT_BLACKLIST, f, indent=2)

ensure_default_json_files()
