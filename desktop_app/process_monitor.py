import psutil
import json
import os
import time
import win32gui
import win32process
from firebase_db import send_distraction_event
from prompt_ui import show_prompt

# Load allowed focus apps
with open("whitelist.json", "r") as f:
    WHITELIST = json.load(f)["allowed_apps"]

already_prompted = {}
PROMPT_COOLDOWN_SECONDS = 600  # 600 seconds = 10 minutes

def is_focus_app_active():
    """Returns True if any focus/whitelisted app is running."""
    for proc in psutil.process_iter(['name']):
        if proc.info['name'] in WHITELIST:
            return True
    return False

def get_foreground_processes():
    """Returns a list of (process_name, pid) for visible window apps."""
    visible_processes = set()

    def callback(hwnd, extra):
        if win32gui.IsWindowVisible(hwnd) and win32gui.GetWindowText(hwnd):
            try:
                _, pid = win32process.GetWindowThreadProcessId(hwnd)
                p = psutil.Process(pid)
                visible_processes.add((p.name(), pid))
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                pass
        return True

    win32gui.EnumWindows(callback, None)
    return list(visible_processes)

def preempt_existing_foreground_distractions():
    """Mark already visible, non-whitelisted apps as recently prompted."""
    current_time = int(time.time())
    foreground_procs = get_foreground_processes()

    for name, _ in foreground_procs:
        if name not in WHITELIST:
            already_prompted[name] = current_time
            print(f"🕒 Skipping initial prompt for {name} (already open)")

def monitor_and_prompt_distractions():
    current_time = int(time.time())
    foreground_procs = get_foreground_processes()

    for name, pid in foreground_procs:
        if name in WHITELIST:
            continue

        last_prompt = already_prompted.get(name, 0)
        if current_time - last_prompt < PROMPT_COOLDOWN_SECONDS:
            continue  # Still cooling down

        print(f"⚠ Foreground distraction detected: {name}")

        reason = show_prompt(name)
        print(f"User reason: {reason}")

        send_distraction_event(name, reason)

        if not reason.strip():
            try:
                os.system(f'taskkill /PID {pid} /F')
                print(f"❌ Killed: {name} (no reason given)")
            except Exception as e:
                print(f"Error killing {name}: {e}")
        else:
            already_prompted[name] = current_time  # ✅ Only if reason is given
            print(f"✅ Allowed: {name} (reason given)")
