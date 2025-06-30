# 🧠 Synapse – Focus Monitor

A lightweight distraction-monitoring tool for Windows that detects and handles blacklisted apps during focus sessions. It prompts users with a reason box and automatically closes apps if no valid reason is provided.

---

## ✅ Features

- Detects foreground and background distraction apps.
- Prompts user for justification via a GUI.
- Automatically kills distracting apps if no reason is given.
- Real-time GUI to edit whitelist and blacklist.
- Firebase integration to log distraction events.
- Syncs with Flutter based phone app to prevent distactions on phone.

---

## 🧩 Requirements

- **Windows OS**
- **Python 3.8+**

---

## 🛠 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/Utsavvv1/harmonicdisruption.git
cd synapse-focus
```

### 2. Create a Virtual Environment (optional)

```bash
python -m venv venv
venv\Scripts\activate  # For Windows
```

### 3. Install Dependencies

```bash
pip install -r require.txt
```

## Run the App

```bash
python gui_app.py
```

## Optional: Create executable

```bash
pip install pyinstaller
pyinstaller gui_app.py --name Synapse --onefile --noconsole --icon=logosynapse.ico --add-data ".env;."
```