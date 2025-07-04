import psutil
import json
import time
import win32gui
import win32process
import subprocess

from prompt_ui import show_prompt
from firebase_db import send_distraction_event, get_focus_mode
from config import WHITELIST_FILE, BLACKLIST_FILE

# --- Helpers ---
def normalize(name):
    return name.lower().replace('.exe', '')

def load_whitelist():
    try:
        with open(WHITELIST_FILE) as f:
            return set(normalize(app) for app in json.load(f).get("allowed_apps", []))
    except Exception as e:
        print("⚠️ Failed to load whitelist:", e)
        return set()

def load_blacklist():
    try:
        with open(BLACKLIST_FILE) as f:
            return set(normalize(app) for app in json.load(f).get("distraction_apps", []))
    except Exception as e:
        print("⚠️ Failed to load blacklist:", e)
        return set()

already_prompted = {}
COOLDOWN = 120

def is_focus_app_active():
    whitelist = load_whitelist()
    return any(
        normalize(p.info['name']) in whitelist
        for p in psutil.process_iter(['name']) if p.info['name']
    )

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
    try:
        subprocess.run(["taskkill", "/IM", app_name, "/F"], check=True)
        print(f"❌ All instances of {app_name} killed")
    except subprocess.CalledProcessError:
        print(f"⚠️ Could not kill {app_name}")

def skip_existing():
    now = int(time.time())
    blacklist = load_blacklist()
    for name, _ in get_foreground_apps():
        if name in blacklist:
            already_prompted[name] = now
            print(f"⏳ Skipped existing: {name}")

def monitor_and_prompt():
    now = int(time.time())
    running = {
        normalize(p.info['name']): p.pid
        for p in psutil.process_iter(['name', 'pid']) if p.info['name']
    }

    if not is_focus_app_active():
        return

    if get_focus_mode():
        blacklist = load_blacklist()
        for name, pid in running.items():
            if name not in blacklist:
                continue
            if now - already_prompted.get(name, 0) < COOLDOWN:
                continue

            reason = show_prompt(name)
            send_distraction_event(name, reason)

            if not reason.strip():
                try:
                    subprocess.run(["taskkill", "/PID", str(pid), "/F"], check=True)
                    print(f"❌ Closed {name} (PID {pid})")
                except:
                    print(f"⚠️ Could not kill {pid}")
                kill_all_instances(f"{name}.exe")
            else:
                already_prompted[name] = now
                print(f"✅ Allowed {name}")
