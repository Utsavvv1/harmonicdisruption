# config.py

import os
from dotenv import load_dotenv

load_dotenv()

POLL_INTERVAL = int(os.getenv("POLL_INTERVAL", 5))
FIREBASE_URL = os.getenv("FIREBASE_URL")
API_KEY = os.getenv("API_KEY")
USER_ID = os.getenv("USER_ID")
