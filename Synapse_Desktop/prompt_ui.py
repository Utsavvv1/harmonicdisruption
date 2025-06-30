import tkinter as tk

PRIMARY = "#362DB7"
ACCENT = "#6C64E9"
TEXT = "#F4EAEA"
BACKGROUND = "#1A171A"


def show_prompt(app_name):
    result = {"reason": ""}

    def submit():
        result["reason"] = text.get("1.0", "end-1c").strip()
        root.destroy()

    def on_close():
        # Treat window close (X) as no response → trigger kill
        result["reason"] = ""
        root.destroy()

    root = tk.Tk()
    root.title("🧠 Synapse – Distraction Monitor")
    root.geometry("450x350")
    root.resizable(False, False)
    root.configure(bg=BACKGROUND)
    root.protocol("WM_DELETE_WINDOW", on_close)  # Handle close button

    tk.Label(root, text="HOLD UP!", font=("Montserrat", 14, "bold"), fg=TEXT, bg=BACKGROUND).pack(pady=15)
    tk.Label(root, text="You are currently in focus mode.", font=("Montserrat", 10), fg=TEXT, bg=BACKGROUND).pack()
    tk.Label(root, text=f"What is your motive to open {app_name.title()}?", font=("Montserrat", 12), fg=TEXT, bg=BACKGROUND).pack(pady=(20, 5))


    text_border = tk.Frame(root, background=PRIMARY, bd=0)
    text_border.pack(pady=10)

    text = tk.Text(text_border, height=3, width=40, bg=BACKGROUND, fg="grey", bd=0, relief="flat", insertbackground="white")
    text.pack(padx=2, pady=2)


    tk.Button(root, text="Submit", bg=PRIMARY, fg="white", activebackground=ACCENT, activeforeground="white",
              font=("Montserrat", 11, "bold"), command=submit).pack(pady=15)

    root.mainloop()
    return result["reason"]
