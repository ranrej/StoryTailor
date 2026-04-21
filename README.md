# StoryTailor

## Simple Mode

### Run via the website (no setup required)

The app is live and ready to use at:

**https://storygenaiv2-157136237046.europe-west1.run.app**

Open the link in any browser — no installation needed.

### Run via the desktop executable (macOS)

1. Download `StoryTailor.app`
2. Double-click it — the app starts and opens in your browser automatically
3. No Python, no terminal, no dependencies required

> **First-time setup:** Once the app opens, go to **Settings** and enter your API keys (`OPENAI_API_KEY` and `GOOGLE_API_KEY`).

---

## Developer Mode

### API Keys

The app requires two API keys:

| Key | Purpose | Where to get it |
|-----|---------|-----------------|
| `OPENAI_API_KEY` | Story generation (required) | https://platform.openai.com/api-keys |
| `GOOGLE_API_KEY` | Image generation via Gemini (optional) | https://aistudio.google.com/app/apikey |

#### Option 1 — `.env` file (simplest)

Create a `.env` file inside the `StoryTailor/` folder (it is already listed in `.gitignore` so it will never be committed):

```
StoryTailor/
└── .env          ← create this file
```

Contents of `.env`:

```bash
OPENAI_API_KEY="sk-..."
GOOGLE_API_KEY="AIza..."
```

The app loads this file automatically on startup.

#### Option 2 — macOS Keychain (more secure)

Store keys in your OS keychain so they are never in any file:

```bash
python -m keyring set storygenai OPENAI_API_KEY
# paste your key when prompted

python -m keyring set storygenai GOOGLE_API_KEY
# paste your key when prompted
```

The app reads from the keychain automatically if no `.env` or environment variable is found.

#### Option 3 — Environment variable (shell session)

```bash
export OPENAI_API_KEY="sk-..."
export GOOGLE_API_KEY="AIza..."
```

The app checks for these variables first on every startup.

---

### Installation

**Requirements:** Python 3.11+

```bash
# 1. Clone the repo and enter the project folder
cd StoryTailor

# 2. Create and activate a virtual environment
python3 -m venv .venv
source .venv/bin/activate        # macOS / Linux
# .venv\Scripts\activate         # Windows

# 3. Install dependencies
pip install -r requirements.txt
```

Alternatively, with [uv](https://docs.astral.sh/uv/):

```bash
cd StoryTailor
uv sync
```

---

### Run locally

With pip + venv:

```bash
source .venv/bin/activate
python main.py
```

With uv:

```bash
uv run storygenai
```

Then open **http://127.0.0.1:8080** in your browser.

To use a different port:

```bash
PORT=9000 python main.py
```

---

### Build the desktop executable

To produce a self-contained `StoryTailor.app` for macOS distribution:

```bash
# From the project root (not inside StoryTailor/)
bash build_app.sh
```

The finished app will be at `dist/StoryTailor.app`. Drag it to `/Applications` or zip it to share.
# StoryTailor
