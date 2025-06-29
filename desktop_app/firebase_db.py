import requests
from datetime import datetime


from config import FIREBASE_URL, API_KEY, USER_ID


def set_focus_state(is_working: bool):
    url = f"{FIREBASE_URL}/users/{USER_ID}/focusMode.json?auth={API_KEY}"
    try:
        res = requests.put(url, json=is_working)
        if res.status_code == 200:
            print(f"✅ [Firebase] focusMode = {is_working}")
        else:
            print("❌ Failed to set focus mode:", res.text)
    except Exception as e:
        print("❌ Firebase Error:", e)

def send_distraction_event(app_name: str, reason: str):
    event = {
        "app": app_name,
        "reason": reason,
        "timestamp": datetime.utcnow().isoformat()
    }
    url = f"{FIREBASE_URL}/users/{USER_ID}/distractions.json?auth={API_KEY}"
    try:
        res = requests.post(url, json=event)
        if res.status_code == 200:
            print(f"📨 Distraction event sent: {app_name}")
        else:
            print("❌ Failed to send distraction event:", res.text)
    except Exception as e:
        print("❌ Firebase Error:", e)
