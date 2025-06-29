# config.py

import os
from dotenv import load_dotenv

# Load .env variables
load_dotenv()

# Access and expose values
POLL_INTERVAL = int(os.getenv("POLL_INTERVAL", 5))  # Default = 5 seconds
FIREBASE_URL = os.getenv("FIREBASE_URL", "")
API_KEY = os.getenv("API_KEY", "")
USER_ID = os.getenv("USER_ID", "")
