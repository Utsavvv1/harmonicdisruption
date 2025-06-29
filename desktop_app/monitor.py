# monitor.py

import psutil
import json
import time
import win32gui
import win32process
from prompt_ui import show_prompt
from firebase_db import send_distraction_event

import os
import sys
import json

def get_resource_path(filename):
    """Returns the correct path whether bundled or not."""
    if hasattr(sys, '_MEIPASS'):
        return os.path.join(sys._MEIPASS, filename)  # PyInstaller temp dir
    return os.path.join(os.path.dirname(__file__), filename)

# Load files
with open(get_resource_path("whitelist.json")) as f:
    WHITELIST = set(app.lower().replace('.exe', '') for app in json.load(f)["allowed_apps"])

with open(get_resource_path("blacklist.json")) as f:
    BLACKLIST = set(app.lower().replace('.exe', '') for app in json.load(f)["distraction_apps"])


already_prompted = {}
COOLDOWN = 600

def normalize(name):
    return name.lower().replace('.exe', '')

def is_focus_app_active():
    return any(normalize(p.info['name']) in WHITELIST for p in psutil.process_iter(['name']) if p.info['name'])

def get_foreground_apps():
    visible = set()
    def callback(hwnd, _):
        if win32gui.IsWindowVisible(hwnd) and win32gui.GetWindowText(hwnd):
            _, pid = win32process.GetWindowThreadProcessId(hwnd)
            try:
                name = normalize(psutil.Process(pid).name())
                visible.add((name, pid))
            except:
                pass
        return True
    win32gui.EnumWindows(callback, None)
    return list(visible)

def skip_existing():
    now = int(time.time())
    for name, _ in get_foreground_apps():
        if name in BLACKLIST:
            already_prompted[name] = now
            print(f"⏳ Skipped existing: {name}")

def monitor_and_prompt():
    now = int(time.time())
    for name, pid in get_foreground_apps():
        if name not in BLACKLIST: continue
        if not is_focus_app_active(): continue
        if now - already_prompted.get(name, 0) < COOLDOWN: continue

        reason = show_prompt(name)
        send_distraction_event(name, reason)

        if not reason.strip():
            os.system(f'taskkill /PID {pid} /F')
            print(f"❌ Closed {name}")
        else:
            already_prompted[name] = now
            print(f"✅ Allowed {name}")
