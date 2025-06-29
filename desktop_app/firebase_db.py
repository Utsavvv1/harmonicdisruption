# firebase_db.py

import requests
from datetime import datetime
from config import FIREBASE_URL, API_KEY, USER_ID

def set_focus_state(is_working: bool):
    url = f"{FIREBASE_URL}/users/{USER_ID}/focusMode.json?auth={API_KEY}"
    try:
        res = requests.put(url, json=is_working)
        print(f"[Firebase] focusMode = {is_working}")
    except Exception as e:
        print("Firebase Error:", e)

def send_distraction_event(app_name, reason):
    url = f"{FIREBASE_URL}/users/{USER_ID}/distractions.json?auth={API_KEY}"
    event = {
        "app": app_name,
        "reason": reason,
        "timestamp": datetime.utcnow().isoformat()
    }
    try:
        res = requests.post(url, json=event)
        print(f"Sent distraction: {app_name}")
    except Exception as e:
        print("Error sending event:", e)
