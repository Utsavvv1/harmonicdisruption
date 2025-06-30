# 🧠 Synapse – Focus Monitor

A lightweight distraction-monitoring tool for Windows that detects and handles blacklisted apps during focus sessions. It prompts users with a reason box and automatically closes apps if no valid reason is provided.

---

## ✅ Features

- Detects foreground and background distraction apps.
- Prompts user for justification via a GUI.
- Automatically kills distracting apps if no reason is given.
- Real-time GUI to edit whitelist and blacklist.
- Firebase integration to log distraction events (optional).

---

## 🧩 Requirements

- **Windows OS**
- **Python 3.8+**

---

## 🛠 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/synapse-focus.git
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

## Configuration

### Whitelist and Blacklist

Edit these two JSON files in the root folder:
- whitelist.json (for allowed productive apps)
- blacklist.json (for distracting apps)

## Run the App

```bash
python gui_app.py
```

## Optional: Create executable

```bash
pip install pyinstaller
pyinstaller --noconfirm --windowed --onefile app.py
```