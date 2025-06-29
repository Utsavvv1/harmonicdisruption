# main.py

import time
from monitor import is_focus_app_active, monitor_and_prompt, skip_existing
from firebase_db import set_focus_state
from config import POLL_INTERVAL

def main():
    print("🧠 Synapse Desktop Monitor Running...")
    skip_existing()

    while True:
        focus = is_focus_app_active()
        set_focus_state(focus)

        if focus:
            monitor_and_prompt()

        time.sleep(POLL_INTERVAL)

if __name__ == "__main__":
    main()
