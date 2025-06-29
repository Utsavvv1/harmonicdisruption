import time
import json
import os
from dotenv import load_dotenv
from process_monitor import (
    is_focus_app_active,
    monitor_and_prompt_distractions,
    preempt_existing_foreground_distractions,
)
from firebase_db import set_focus_state
load_dotenv()
POLL_INTERVAL = int(os.getenv("POLL_INTERVAL", 5))

def main():
    print("🧠 Focus Guardian Running (PC)...")

    preempt_existing_foreground_distractions()

    while True:
        focused = is_focus_app_active()
        set_focus_state(focused)

        if focused:
            monitor_and_prompt_distractions()

        time.sleep(POLL_INTERVAL)

if __name__ == "__main__":
    main()
