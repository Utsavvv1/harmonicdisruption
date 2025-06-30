import tkinter as tk
from tkinter import messagebox
import threading
import json
import time
from monitor import is_focus_app_active, monitor_and_prompt, skip_existing
from firebase_db import set_focus_state
from config import POLL_INTERVAL, WHITELIST_FILE, BLACKLIST_FILE
from config import USER_ID

PRIMARY = "#362DB7"
ACCENT = "#6C64E9"
TEXT = "#F4EAEA"
BACKGROUND = "#1A171A"

monitoring = False
monitor_thread = None

def monitor_loop():
    skip_existing()
    while monitoring:
        focused = is_focus_app_active()
        set_focus_state(focused)

        if focused:
            status_label.after(0, lambda: status_label.config(text="Focus Mode: ON", fg="green"))
            monitor_and_prompt()
        else:
            status_label.after(0, lambda: status_label.config(text="Focus Mode OFF", fg="red"))

        time.sleep(POLL_INTERVAL)

def edit_app_list(filepath, title):
    try:
        with open(filepath, "r") as f:
            raw_data = json.load(f)
        key = next((k for k in raw_data if isinstance(raw_data[k], list)), None)
        data = raw_data[key]
    except Exception as e:
        messagebox.showerror("Error", f"Couldn't load {title}:\n{e}")
        return

    editor = tk.Toplevel()
    editor.title(title + " (Live)")
    editor.geometry("600x600")
    editor.configure(bg=BACKGROUND)

    listbox = tk.Listbox(editor, selectmode=tk.MULTIPLE, bg=BACKGROUND, fg=TEXT)
    listbox.pack(padx=10, pady=10, fill=tk.BOTH, expand=True)

    for item in data:
        listbox.insert(tk.END, item)

    entry = tk.Entry(editor, width=30, bg=BACKGROUND, fg=TEXT)
    entry.pack(pady=5)

    def add_app():
        app = entry.get().strip()
        if app and app.lower().endswith(".exe") and app not in data:
            data.append(app)
            listbox.insert(tk.END, app)
            save_list()
            entry.delete(0, tk.END)

    def remove_selected():
        for index in reversed(listbox.curselection()):
            app = listbox.get(index)
            if app in data:
                data.remove(app)
                listbox.delete(index)
        save_list()

    def save_list():
        try:
            raw_data[key] = data
            with open(filepath, "w") as f:
                json.dump(raw_data, f, indent=2)
            print(f"✅ Updated: {filepath}")
        except Exception as e:
            messagebox.showerror("Error", f"Failed to save:\n{e}")

    tk.Button(editor, text="Add App", command=add_app, bg=PRIMARY, fg="white").pack(pady=5)
    tk.Button(editor, text="Remove Selected", command=remove_selected, bg="red", fg="white").pack(pady=5)
    tk.Button(editor, text="Close", command=editor.destroy, bg="gray", fg="white").pack(pady=5)

def draw_rounded_rect(canvas, x1, y1, x2, y2, r, **kwargs):
    canvas.create_arc(x1, y1, x1+r*2, y1+r*2, start=90, extent=90, style='pieslice', **kwargs)
    canvas.create_arc(x2-r*2, y1, x2, y1+r*2, start=0, extent=90, style='pieslice', **kwargs)
    canvas.create_arc(x1, y2-r*2, x1+r*2, y2, start=180, extent=90, style='pieslice', **kwargs)
    canvas.create_arc(x2-r*2, y2-r*2, x2, y2, start=270, extent=90, style='pieslice', **kwargs)
    canvas.create_rectangle(x1+r, y1, x2-r, y2, **kwargs)
    canvas.create_rectangle(x1, y1+r, x2, y2-r, **kwargs)

def build_gui():
    global monitoring, monitor_thread

    root = tk.Tk()
    root.title("🧠 Synapse Dashboard")
    root.geometry("500x420")
    root.resizable(False, False)
    root.configure(bg=BACKGROUND)

    def graceful_exit():
        global monitoring
        monitoring = False
        set_focus_state(False)
        root.destroy()

    root.protocol("WM_DELETE_WINDOW", graceful_exit)

    tk.Label(root, text="Synapse", font=("Montserrat", 16, "bold"),
             fg=TEXT, bg=BACKGROUND).pack(pady=(10, 5))

    user_canvas = tk.Canvas(root, width=400, height=30, bg=BACKGROUND, highlightthickness=0)
    user_canvas.pack(pady=(0, 5))

    font_spec = ("Montserrat", 14)

    tmp = tk.Label(root, font=font_spec)
    user_id_text = f"{USER_ID}"
    label_text = "User ID:"
    label_width = tmp.tk.call("font", "measure", font_spec, "-displayof", ".", label_text)
    user_id_width = tmp.tk.call("font", "measure", font_spec, "-displayof", ".", user_id_text)
    total_width = int(label_width) + int(user_id_width) + 1
    start_x = 200 - (total_width // 2)

    user_canvas.create_text(start_x, 15, text=label_text, fill=TEXT, font=font_spec, anchor="w")
    user_canvas.create_text(start_x + label_width, 15, text=user_id_text, fill=ACCENT, font=font_spec, anchor="w")

    instruction_canvas = tk.Canvas(root, width=380, height=40, bg=BACKGROUND, highlightthickness=0)
    instruction_canvas.pack(pady=(0, 10))
    draw_rounded_rect(instruction_canvas, 5, 5, 375, 35, r=10, fill="#2A2A2A", outline="#2A2A2A")
    instruction_canvas.create_text(190, 20, text="Enter this on your phone to sync with your PC",
                                   fill=TEXT, font=("Montserrat", 12))

    global status_label
    status_label = tk.Label(root, text="Focus Mode: OFF", font=("Montserrat", 12),
                            fg="red", bg=BACKGROUND)
    status_label.pack(pady=5)

    monitoring = True
    monitor_thread = threading.Thread(target=monitor_loop, daemon=True)
    monitor_thread.start()

    button_frame = tk.Frame(root, bg=BACKGROUND)
    button_frame.pack(pady=(10, 20), fill=tk.X)

    def create_rounded_canvas_button(text, bg_color, command):
        frame = tk.Frame(button_frame, bg=BACKGROUND)
        frame.pack(pady=5, padx=40, fill=tk.X)

        canvas = tk.Canvas(frame, height=45, bg=BACKGROUND, highlightthickness=0)
        canvas.pack(fill=tk.X)

        width = 380
        radius = 15
        x1, y1, x2, y2 = 5, 5, width-5, 40

        draw_rounded_rect(canvas, x1, y1, x2, y2, r=radius, fill=bg_color, outline=bg_color)

        canvas_id = canvas.create_text((width)//2, 22, text=text, fill="white",
                                       font=("Montserrat", 11, "bold"))

        def on_click(event):
            command()

        canvas.tag_bind(canvas_id, "<Button-1>", on_click)
        canvas.tag_bind(canvas_id, "<Enter>", lambda e: canvas.config(cursor="hand2"))
        canvas.tag_bind(canvas_id, "<Leave>", lambda e: canvas.config(cursor=""))

    create_rounded_canvas_button("Edit Work Apps", ACCENT,
                                 lambda: edit_app_list(WHITELIST_FILE, "Whitelist"))

    create_rounded_canvas_button("Edit Distractions", PRIMARY,
                                 lambda: edit_app_list(BLACKLIST_FILE, "Blacklist"))

    create_rounded_canvas_button("Exit Synapse", "gray", graceful_exit)

    root.mainloop()

if __name__ == "__main__":
    set_focus_state(False)
    build_gui()
