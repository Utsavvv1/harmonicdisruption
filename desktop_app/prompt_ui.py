from tkinter import Tk, Label, Text, Button

def show_prompt(app_name):
    reason = []

    def submit():
        reason.append(text.get("1.0", "end-1c").strip())
        root.destroy()

    root = Tk()
    root.title("⚠ Focus Mode Alert")
    root.geometry("400x300")
    Label(root, text=f"You opened: {app_name}", font=("Helvetica", 14)).pack(pady=10)
    Label(root, text="Why do you need it?", font=("Helvetica", 12)).pack()
    text = Text(root, height=5, width=40)
    text.pack(padx=10)
    Button(root, text="Submit", command=submit).pack(pady=10)
    root.mainloop()

    return reason[0] if reason else "No response"
