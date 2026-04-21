#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# StoryTailor macOS App Builder
#
# Creates dist/StoryTailor.app — a fully self-contained, double-click launcher.
# No Python installation or pip commands required by end users.
#
# Usage (from the project root):
#   bash build_app.sh
#
# Requirements for the person running this build script:
#   - Python 3.11+ in PATH
#   - macOS (builds are platform-specific)
#
# Output:
#   dist/StoryTailor.app   ← drag this to /Applications to install
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_SRC="$SCRIPT_DIR/StoryTailor"
DIST_DIR="$SCRIPT_DIR/dist"
BUILD_DIR="$SCRIPT_DIR/build"
VENV_DIR="$SCRIPT_DIR/.build_venv"
STAGE_DIR="$SCRIPT_DIR/.build_stage"
SRC_DB="$APP_SRC/database/tables/storygenai.db"
SEED_DB_DIR="$STAGE_DIR/database/tables"

# ─────────────────────────────────────────────────────────────────────────────
echo "╔══════════════════════════════════════════════╗"
echo "║         StoryTailor macOS App Builder        ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# ── 1. Verify Python ─────────────────────────────────────────────────────────
if ! command -v python3 &>/dev/null; then
    echo "ERROR: python3 not found."
    echo "       Install Python 3.11+ from https://python.org and try again."
    exit 1
fi
PY_VER=$(python3 -c "import sys; v=sys.version_info; print(f'{v.major}.{v.minor}')")
echo "→ Python $PY_VER detected"

# ── 2. Set up an isolated build virtual environment ──────────────────────────
echo "→ Setting up build environment (this may take a minute)..."
python3 -m venv "$VENV_DIR"
# shellcheck disable=SC1091
source "$VENV_DIR/bin/activate"
pip install --quiet --upgrade pip
pip install --quiet -r "$APP_SRC/requirements.txt"
pip install --quiet pyinstaller
echo "   Dependencies installed."

# ── 3. Stage assets ──────────────────────────────────────────────────────────
#   • Copy templates + static files (strip generated/ to keep bundle lean)
#   • Create a clean seed database: AoA words only, no user story data
echo "→ Staging assets..."
rm -rf "$STAGE_DIR"
mkdir -p "$STAGE_DIR/app"

cp -r "$APP_SRC/app/templates" "$STAGE_DIR/app/templates"
cp -r "$APP_SRC/app/static"    "$STAGE_DIR/app/static"
# Remove existing generated images — they'll be re-created at runtime
rm -rf "$STAGE_DIR/app/static/generated"
mkdir -p "$STAGE_DIR/app/static/generated"

# ── 4. Create seed database (AoA reference data only, no user stories) ────────
echo "→ Creating seed database..."
mkdir -p "$SEED_DB_DIR"

python3 - "$SRC_DB" "$SEED_DB_DIR/storygenai.db" <<'PYEOF'
import sys, sqlite3, os

src_path  = sys.argv[1]
dest_path = sys.argv[2]

dest = sqlite3.connect(dest_path)
dest.execute("PRAGMA journal_mode=WAL;")

# Always create the user-facing tables (empty)
dest.execute("""
    CREATE TABLE IF NOT EXISTS system_instructions_log (
        system_instructions_prefilter_id  TEXT PRIMARY KEY,
        user_id            TEXT,
        input_id           TEXT,
        child_name         TEXT,
        child_age          TEXT,
        child_gender       TEXT,
        child_grade        TEXT,
        selected_topic     TEXT,
        learning_goal      TEXT,
        main_char_name     TEXT,
        support_char_names TEXT,
        location_text      TEXT,
        mood_text          TEXT,
        page_cnt           TEXT,
        sentence_cnt       TEXT,
        system_instructions TEXT NOT NULL,
        created_at          TEXT NOT NULL
    )
""")
dest.execute("""
    CREATE TABLE IF NOT EXISTS evaluation_log (
        id                   TEXT PRIMARY KEY,
        prefilter_id         TEXT NOT NULL,
        attempt              INTEGER NOT NULL DEFAULT 1,
        all_pass             INTEGER NOT NULL DEFAULT 0,
        story_text           TEXT,
        structure_result     TEXT,
        elements_result      TEXT,
        vocabulary_result    TEXT,
        readability_result   TEXT,
        learning_goal_result TEXT,
        failures_summary     TEXT,
        created_at           TEXT NOT NULL,
        FOREIGN KEY (prefilter_id)
            REFERENCES system_instructions_log(system_instructions_prefilter_id)
    )
""")

# Copy AoA reference words from the source database (if available)
if os.path.exists(src_path):
    try:
        src = sqlite3.connect(src_path)
        rows = src.execute(
            "SELECT word, age_group, aoa_raw, nsyll FROM aoa_words"
        ).fetchall()
        src.close()

        dest.execute("""
            CREATE TABLE IF NOT EXISTS aoa_words (
                word       TEXT PRIMARY KEY,
                age_group  INTEGER NOT NULL DEFAULT 0,
                aoa_raw    REAL,
                nsyll      INTEGER NOT NULL DEFAULT 0
            )
        """)
        dest.executemany(
            "INSERT OR IGNORE INTO aoa_words (word, age_group, aoa_raw, nsyll) VALUES (?,?,?,?)",
            rows,
        )
        dest.execute(
            "CREATE INDEX IF NOT EXISTS idx_age_group ON aoa_words (age_group)"
        )
        print(f"   Copied {len(rows):,} AoA words into seed database.")
    except Exception as exc:
        print(f"   Warning: could not copy AoA words ({exc})")
        print("   Vocabulary evaluation will be limited without the AoA table.")
else:
    print("   Warning: source database not found; run scripts/load_aoa.py first")
    print("   to populate vocabulary data before building the app.")

dest.commit()
dest.close()
PYEOF

# ── 5. Run PyInstaller ───────────────────────────────────────────────────────
echo "→ Building StoryTailor.app (this takes a few minutes)..."
cd "$APP_SRC"

pyinstaller \
    --name "StoryTailor" \
    --windowed \
    --onedir \
    --clean \
    --noconfirm \
    --distpath "$DIST_DIR" \
    --workpath "$BUILD_DIR" \
    --specpath "$BUILD_DIR" \
    --add-data "$STAGE_DIR/app/templates:app/templates" \
    --add-data "$STAGE_DIR/app/static:app/static" \
    --add-data "$STAGE_DIR/database:database" \
    --collect-all "uvicorn" \
    --collect-all "fastapi" \
    --collect-all "starlette" \
    --collect-all "anyio" \
    --collect-all "h11" \
    --collect-all "google.genai" \
    --hidden-import "multipart" \
    --hidden-import "email.mime.text" \
    --hidden-import "email.mime.multipart" \
    --hidden-import "itsdangerous" \
    --hidden-import "itsdangerous.url_safe" \
    --hidden-import "keyring.backends" \
    --hidden-import "keyring.backends.macOS" \
    launcher.py

# ── 6. Clean up temp files ───────────────────────────────────────────────────
echo "→ Cleaning up..."
deactivate 2>/dev/null || true
rm -rf "$STAGE_DIR" "$VENV_DIR"

APP_PATH="$DIST_DIR/StoryTailor.app"
APP_SIZE=$(du -sh "$APP_PATH" 2>/dev/null | cut -f1 || echo "unknown")

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  Build complete!                                             ║"
echo "║                                                              ║"
printf  "║  App:  %-54s║\n" "dist/StoryTailor.app  ($APP_SIZE)"
echo "║                                                              ║"
echo "║  To install: drag dist/StoryTailor.app to /Applications      ║"
echo "║  To share:   zip dist/StoryTailor.app and send the .zip      ║"
echo "║                                                              ║"
echo "║  NOTE: Users must set their API keys before the app works:   ║"
echo "║    • Open the app → click Settings                           ║"
echo "║    • Or set env vars: OPENAI_API_KEY and GOOGLE_API_KEY       ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
