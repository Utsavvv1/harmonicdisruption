import os
import sys
from dotenv import load_dotenv
from nanoid import generate

# ✅ Get correct base path depending on PyInstaller or normal script
def get_base_path():
    if getattr(sys, 'frozen', False):
        return sys._MEIPASS  # PyInstaller temp folder
    return os.path.abspath(".")

# ✅ Get writeable path for persistent local data (next to the .exe or script)
def get_writable_data_path():
    if getattr(sys, 'frozen', False):
        base_path = os.path.dirname(sys.executable)  # actual EXE folder
    else:
        base_path = os.path.abspath(".")
    data_dir = os.path.join(base_path, "local_data")
    os.makedirs(data_dir, exist_ok=True)
    return data_dir

# 📁 Paths
RESOURCE_PATH = get_base_path()
DATA_DIR = get_writable_data_path()
USER_ID_FILE = os.path.join(DATA_DIR, "user_id.txt")

# 🔐 Load .env
load_dotenv(dotenv_path=os.path.join(RESOURCE_PATH, ".env"))

# 🔧 Config variables
FIREBASE_URL = os.getenv("FIREBASE_URL")
API_KEY = os.getenv("API_KEY")
POLL_INTERVAL = int(os.getenv("POLL_INTERVAL", 5))
DISTRACTION_PROMPT_INTERVAL = int(os.getenv("DISTRACTION_PROMPT_INTERVAL", 60))

# 🔑 Unique ID generation (uppercase alphanum)
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
