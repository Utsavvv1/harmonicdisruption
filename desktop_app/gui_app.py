import tkinter as tk
from tkinter import messagebox
import threading
import json
import os
import sys
import time

from monitor import is_focus_app_active, monitor_and_prompt, skip_existing
from firebase_db import set_focus_state
from config import POLL_INTERVAL

# 🎨 Synapse Color Scheme
PRIMARY = "#362DB7"
ACCENT = "#6C64E9"
BACKGROUND = "#F4EAEA"
TEXT = "#1A171A"

monitoring = False
monitor_thread = None

def get_resource_path(filename):
    if hasattr(sys, '_MEIPASS'):
        return os.path.join(sys._MEIPASS, filename)
    return os.path.join(os.path.dirname(__file__), filename)

# --- Monitoring Thread Logic ---
def monitor_loop():
    skip_existing()
    while monitoring:
        focused = is_focus_app_active()
        set_focus_state(focused)
        if focused:
            monitor_and_prompt()
        time.sleep(POLL_INTERVAL)

# --- JSON List Editor (Live Dynamic) ---
def edit_app_list(filename, title):
    path = get_resource_path(filename)

    try:
        with open(path, "r") as f:
            raw_data = json.load(f)

        key = next((k for k in raw_data if isinstance(raw_data[k], list)), None)
        if not key:
            raise ValueError("No valid list key found in JSON.")

        data = raw_data[key]
    except Exception as e:
        messagebox.showerror("Error", f"Couldn't load {filename}:\n{e}")
        return

    editor = tk.Toplevel()
    editor.title(title + " (Live)")
    editor.geometry("400x400")
    editor.configure(bg=BACKGROUND)

    listbox = tk.Listbox(editor, selectmode=tk.MULTIPLE, bg="white", fg=TEXT)
    listbox.pack(padx=10, pady=10, fill=tk.BOTH, expand=True)

    for item in data:
        listbox.insert(tk.END, item)

    entry = tk.Entry(editor, width=30, bg="white", fg=TEXT)
    entry.pack(pady=5)

    def add_app():
        app = entry.get().strip()
        if app and app.lower().endswith(".exe") and app not in data:
            data.append(app)
            listbox.insert(tk.END, app)
            save_list()
            entry.delete(0, tk.END)

    def remove_selected():
        selected_indices = listbox.curselection()
        for index in reversed(selected_indices):
            app = listbox.get(index)
            if app in data:
                data.remove(app)
                listbox.delete(index)
        save_list()

    def save_list():
        try:
            raw_data[key] = data
            with open(path, "w") as f:
                json.dump(raw_data, f, indent=4)
            print(f"✅ {filename} updated")
        except Exception as e:
            messagebox.showerror("Error", f"Failed to save file:\n{e}")

    tk.Button(editor, text="Add App", command=add_app,
              bg=PRIMARY, fg="white", activebackground=ACCENT).pack(pady=5)

    tk.Button(editor, text="Remove Selected", command=remove_selected,
              bg="red", fg="white").pack(pady=5)

    tk.Button(editor, text="Close", command=editor.destroy,
              bg="gray", fg="white").pack(pady=10)

def build_gui():
    global monitoring, monitor_thread

    root = tk.Tk()
    root.title("🧠 Synapse Dashboard")
    root.geometry("400x300")
    root.configure(bg=BACKGROUND)

    # ✅ Ensure graceful_exit runs even on ❌ close
    def graceful_exit():
        global monitoring
        monitoring = False
        set_focus_state(False)  # 🔁 Reset focus mode on exit
        status_label.config(text="🔴 Monitoring: OFF")
        root.destroy()

    root.protocol("WM_DELETE_WINDOW", graceful_exit)

    tk.Label(root, text="Synapse – Focus Monitor", font=("Helvetica", 16, "bold"),
             fg=TEXT, bg=BACKGROUND).pack(pady=10)

    status_label = tk.Label(root, text="🔴 Monitoring: OFF", font=("Helvetica", 12),
                            fg=TEXT, bg=BACKGROUND)
    status_label.pack(pady=5)

    # ✅ Start monitoring immediately
    monitoring = True
    status_label.config(text="🟢 Monitoring: ON")
    monitor_thread = threading.Thread(target=monitor_loop, daemon=True)
    monitor_thread.start()

    tk.Button(root, text="Edit Whitelist (Live)", font=("Helvetica", 11),
              bg=PRIMARY, fg="white", activebackground=ACCENT,
              command=lambda: edit_app_list("whitelist.json", "Edit Whitelist")).pack(pady=5)

    tk.Button(root, text="Edit Blacklist (Live)", font=("Helvetica", 11),
              bg=PRIMARY, fg="white", activebackground=ACCENT,
              command=lambda: edit_app_list("blacklist.json", "Edit Blacklist")).pack(pady=5)

    tk.Button(root, text="Exit Synapse", font=("Helvetica", 11),
              bg="gray", fg="white", command=graceful_exit).pack(pady=20)

    root.mainloop()

# --- Entry Point ---
if __name__ == "__main__":
    set_focus_state(False)
    build_gui()