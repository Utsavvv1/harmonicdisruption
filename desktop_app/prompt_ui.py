# prompt_ui.py

import tkinter as tk

PRIMARY = "#362DB7"
ACCENT = "#6C64E9"
BACKGROUND = "#F4EAEA"
TEXT = "#1A171A"

def show_prompt(app_name):
    reason = []

    def submit():
        reason.append(text.get("1.0", "end-1c").strip())
        root.destroy()

    root = tk.Tk()
    root.title("🧠 Synapse – Distraction Monitor")
    root.geometry("400x300")
    root.configure(bg=BACKGROUND)

    tk.Label(root, text="🧠 Synapse Alert", font=("Helvetica", 16, "bold"), fg=TEXT, bg=BACKGROUND).pack(pady=15)
    tk.Label(root, text=f"You opened: {app_name}", font=("Helvetica", 12), fg=TEXT, bg=BACKGROUND).pack()
    tk.Label(root, text="Why do you need this app?", font=("Helvetica", 11), fg=TEXT, bg=BACKGROUND).pack(pady=(20, 5))

    text = tk.Text(root, height=5, width=40, bg="white", fg=TEXT, bd=1, relief="solid")
    text.pack()

    tk.Button(root, text="Submit", bg=PRIMARY, fg="white", activebackground=ACCENT, activeforeground="white", font=("Helvetica", 11, "bold"), command=submit).pack(pady=15)

    root.mainloop()
    return reason[0] if reason else "No response"
