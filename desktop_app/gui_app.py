import tkinter as tk
from tkinter import messagebox, simpledialog
import threading
import json
import time

from monitor import is_focus_app_active, monitor_and_prompt, skip_existing
from firebase_db import set_focus_state
from config import POLL_INTERVAL

# 🎨 Synapse Color Scheme
PRIMARY = "#362DB7"
ACCENT = "#6C64E9"
BACKGROUND = "#F4EAEA"
TEXT = "#1A171A"

# Global flag to control monitoring
monitoring = False
monitor_thread = None

# --- Start/Stop Logic ---
def toggle_monitoring(label):
    global monitoring, monitor_thread

    if not monitoring:
        monitoring = True
        label.config(text="🟢 Monitoring: ON")
        monitor_thread = threading.Thread(target=monitor_loop, daemon=True)
        monitor_thread.start()
    else:
        monitoring = False
        label.config(text="🔴 Monitoring: OFF")

def monitor_loop():
    skip_existing()
    while monitoring:
        focused = is_focus_app_active()
        set_focus_state(focused)
        if focused:
            monitor_and_prompt()
        time.sleep(POLL_INTERVAL)

# --- File Editor ---
def edit_json_file(filename, title):
    try:
        with open(filename, "r") as f:
            data = json.dumps(json.load(f), indent=4)
    except Exception as e:
        messagebox.showerror("Error", f"Couldn't load {filename}:\n{e}")
        return

    editor = tk.Toplevel()
    editor.title(title)
    editor.geometry("500x400")
    editor.configure(bg=BACKGROUND)

    text = tk.Text(editor, wrap=tk.WORD, bg="white", fg=TEXT)
    text.insert(tk.END, data)
    text.pack(padx=10, pady=10, fill=tk.BOTH, expand=True)

    def save_and_close():
        try:
            new_data = json.loads(text.get("1.0", tk.END))
            with open(filename, "w") as f:
                json.dump(new_data, f, indent=4)
            editor.destroy()
        except Exception as e:
            messagebox.showerror("Error", f"Invalid JSON:\n{e}")

    tk.Button(editor, text="Save & Close", command=save_and_close,
              bg=PRIMARY, fg="white", activebackground=ACCENT).pack(pady=10)

# --- GUI Layout ---
def build_gui():
    root = tk.Tk()
    root.title("🧠 Synapse Dashboard")
    root.geometry("400x300")
    root.configure(bg=BACKGROUND)

    tk.Label(root, text="Synapse – Focus Monitor", font=("Helvetica", 16, "bold"),
             fg=TEXT, bg=BACKGROUND).pack(pady=10)

    status_label = tk.Label(root, text="🔴 Monitoring: OFF", font=("Helvetica", 12),
                            fg=TEXT, bg=BACKGROUND)
    status_label.pack(pady=5)

    tk.Button(root, text="Toggle Monitoring", font=("Helvetica", 12, "bold"),
              bg=PRIMARY, fg="white", activebackground=ACCENT,
              command=lambda: toggle_monitoring(status_label)).pack(pady=10)

    tk.Button(root, text="Edit Whitelist", font=("Helvetica", 11),
              bg=PRIMARY, fg="white", activebackground=ACCENT,
              command=lambda: edit_json_file("whitelist.json", "Edit Whitelist")).pack(pady=5)

    tk.Button(root, text="Edit Blacklist", font=("Helvetica", 11),
              bg=PRIMARY, fg="white", activebackground=ACCENT,
              command=lambda: edit_json_file("blacklist.json", "Edit Blacklist")).pack(pady=5)

    tk.Button(root, text="Exit Synapse", font=("Helvetica", 11),
              bg="gray", fg="white", command=root.destroy).pack(pady=20)

    root.mainloop()

if __name__ == "__main__":
    build_gui()
