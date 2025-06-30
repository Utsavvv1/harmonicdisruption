import requests
from datetime import datetime
from config import FIREBASE_URL, API_KEY, USER_ID

# ➤ Write to: users/User1/settings/focusMode
def set_focus_state(is_working: bool):
    url = f"{FIREBASE_URL}/users/{USER_ID}/settings/focusMode.json?auth={API_KEY}"
    try:
        res = requests.put(url, json=is_working)
        if res.status_code == 200:
            print(f"[Firebase] focusMode = {is_working}")
        else:
            print("❌ Failed to update focusMode:", res.text)
    except Exception as e:
        print("Firebase Error:", e)

# ➤ Write to: users/User1/distractions/auto_generated_key
def send_distraction_event(app_name: str, reason: str):
    url = f"{FIREBASE_URL}/users/{USER_ID}/distractions.json?auth={API_KEY}"
    event = {
        "app": app_name,
        "reason": reason,
        "timestamp": datetime.utcnow().isoformat()
    }
    try:
        res = requests.post(url, json=event)
        if res.status_code == 200:
            print(f"📨 Distraction event sent: {app_name}")
        else:
            print("❌ Failed to send distraction event:", res.text)
    except Exception as e:
        print("Firebase Error:", e)

# ➤ Read from: users/User1/settings/focusMode
def get_focus_mode():
    url = f"{FIREBASE_URL}/users/{USER_ID}/settings/focusMode.json?auth={API_KEY}"
    try:
        res = requests.get(url)
        if res.status_code == 200:
            return res.json() is True  # ensure it's a boolean True
        else:
            print("❌ Failed to read focusMode:", res.text)
            return False
    except Exception as e:
        print("Firebase Error (read):", e)
        return False
