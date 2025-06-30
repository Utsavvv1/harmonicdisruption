import psutil
import json
import time
import win32gui
import win32process
import subprocess
import os
import sys

from prompt_ui import show_prompt
from firebase_db import send_distraction_event, get_focus_mode

# Get safe file path (for PyInstaller or script mode)
def get_resource_path(filename):
    if hasattr(sys, '_MEIPASS'):
        return os.path.join(sys._MEIPASS, filename)
    return os.path.join(os.path.dirname(__file__), filename)

# Load whitelist and blacklist JSONs
with open(get_resource_path("whitelist.json")) as f:
    WHITELIST = set(app.lower().replace('.exe', '') for app in json.load(f)["allowed_apps"])

with open(get_resource_path("blacklist.json")) as f:
    BLACKLIST = set(app.lower().replace('.exe', '') for app in json.load(f)["distraction_apps"])

# --- Globals ---
already_prompted = {}
COOLDOWN = 600  # seconds

# --- Helpers ---
def normalize(name):
    return name.lower().replace('.exe', '')

def is_focus_app_active():
    """True if any whitelisted app is running in background or foreground."""
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

def kill_all_instances(app_name):
    """Kills all processes with matching .exe name (e.g., Spotify.exe)"""
    try:
        subprocess.run(["taskkill", "/IM", app_name, "/F"], check=True)
        print(f"❌ All instances of {app_name} killed")
    except subprocess.CalledProcessError:
        print(f"⚠️ Could not kill all instances of {app_name}")

def skip_existing():
    now = int(time.time())
    for name, _ in get_foreground_apps():
        if name in BLACKLIST:
            already_prompted[name] = now
            print(f"⏳ Skipped existing: {name}")

# --- Main Logic ---
def monitor_and_prompt():
    now = int(time.time())
    running_processes = {
        normalize(p.info['name']): p.pid
        for p in psutil.process_iter(['name', 'pid']) if p.info['name']
    }

    if not is_focus_app_active():
        return

    if get_focus_mode():
        for name, pid in running_processes.items():
            if name not in BLACKLIST:
                continue
            if now - already_prompted.get(name, 0) < COOLDOWN:
                continue

            reason = show_prompt(name)
            send_distraction_event(name, reason)

            if not reason.strip():
                try:
                    subprocess.run(["taskkill", "/PID", str(pid), "/F"], check=True)
                    print(f"❌ Closed {name} (PID {pid})")
                except subprocess.CalledProcessError:
                    print(f"⚠️ Could not kill PID {pid} — permission denied or already closed")

                kill_all_instances(f"{name}.exe")  # full-force kill
            else:
                already_prompted[name] = now
                print(f"✅ Allowed {name}")
