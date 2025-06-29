import psutil
import json
import os
import time
import win32gui
import win32process
from firebase_db import send_distraction_event
from prompt_ui import show_prompt

# Load whitelist (allowed focus apps)
with open("whitelist.json", "r") as f:
    WHITELIST = set(app.lower().replace('.exe', '') for app in json.load(f)["allowed_apps"])

# Load distraction list (apps to block)
with open("blacklist.json", "r") as f:
    DISTRACTION_LIST = set(app.lower().replace('.exe', '') for app in json.load(f)["distraction_apps"])

already_prompted = {}
PROMPT_COOLDOWN_SECONDS = 600  # 10 minutes

def normalize_process_name(name):
    """Standardize process names for comparison."""
    return name.lower().replace('.exe', '')

def is_focus_app_active():
    """Returns True if any allowed focus app is running (from whitelist)."""
    for proc in psutil.process_iter(['name']):
        pname = proc.info['name']
        if pname and normalize_process_name(pname) in WHITELIST:
            return True
    return False

def get_foreground_processes():
    """Returns a list of (normalized_process_name, pid) for visible window apps."""
    visible_processes = set()

    def callback(hwnd, extra):
        if win32gui.IsWindowVisible(hwnd) and win32gui.GetWindowText(hwnd):
            try:
                _, pid = win32process.GetWindowThreadProcessId(hwnd)
                p = psutil.Process(pid)
                pname = p.name()
                visible_processes.add((normalize_process_name(pname), pid))
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                pass
        return True

    win32gui.EnumWindows(callback, None)
    return list(visible_processes)

def preempt_existing_foreground_distractions():
    """Skip apps already open when script starts (so we don't spam user instantly)."""
    current_time = int(time.time())
    foreground_procs = get_foreground_processes()

    for name, _ in foreground_procs:
        if name in DISTRACTION_LIST:
            already_prompted[name] = current_time
            print(f"⏳ Skipping initial prompt for {name} (already running when app started)")

def monitor_and_prompt_distractions():
    current_time = int(time.time())
    foreground_procs = get_foreground_processes()

    for name, pid in foreground_procs:
        if name not in DISTRACTION_LIST:
            continue  # Ignore apps not in the distraction list

        # Check if user is currently in focus mode
        if not is_focus_app_active():
            continue  # Don't bother if user isn't working anyway

        # Check cooldown
        last_prompt = already_prompted.get(name, 0)
        if current_time - last_prompt < PROMPT_COOLDOWN_SECONDS:
            continue  # Still cooling down, skip

        print(f"🚫 Distraction detected: {name}")

        # Show prompt and get reason
        reason = show_prompt(name)
        print(f"User reason for opening {name}: {reason}")

        # Send event to Firebase
        send_distraction_event(name, reason)

        if not reason.strip():
            # No reason given, kill the app
            try:
                os.system(f'taskkill /PID {pid} /F')
                print(f"❌ Killed process: {name}")
            except Exception as e:
                print(f"Error killing {name}: {e}")
        else:
            # Reason given, start cooldown
            already_prompted[name] = current_time
            print(f"✅ Allowed {name} for now (user gave reason)")

if __name__ == "__main__":
    print("🔍 FocusBridge Desktop Agent started.")
    preempt_existing_foreground_distractions()

    while True:
        monitor_and_prompt_distractions()
        time.sleep(5)  # Check every 5 seconds
