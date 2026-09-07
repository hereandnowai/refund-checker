#!/usr/bin/env bash
# Refund Checker — one command to run it.
#
#   ./run.sh            start on http://127.0.0.1:8000 and open the browser
#   ./run.sh test       run the test suite instead
#   PORT=8001 ./run.sh  use a different port
#
# The backend (FastAPI) serves the frontend (static/index.html) itself,
# so this is one process, not two.

set -euo pipefail
cd "$(dirname "$0")"

PORT="${PORT:-8000}"

# Windows Git Bash puts the venv binaries under Scripts/, everything else under bin/
if [ -d .venv/Scripts ]; then VENV_BIN=.venv/Scripts; else VENV_BIN=.venv/bin; fi

# 1. Virtual environment — create it once, reuse it after that
if [ ! -x "$VENV_BIN/python" ]; then
  echo "Creating virtual environment..."
  python3 -m venv .venv
fi

# 2. Dependencies — only reinstall if requirements.txt changed
if [ ! -f .venv/.installed ] || [ requirements.txt -nt .venv/.installed ]; then
  echo "Installing dependencies..."
  "$VENV_BIN/python" -m pip install -q -r requirements.txt
  touch .venv/.installed
fi

# 3. Tests, if asked
if [ "${1:-}" = "test" ]; then
  exec "$VENV_BIN/python" -m pytest -q
fi

# 4. Refuse to start on a busy port rather than silently failing
if lsof -ti tcp:"$PORT" >/dev/null 2>&1; then
  echo "Port $PORT is already in use. Stop it with:  lsof -ti tcp:$PORT | xargs kill"
  echo "Or run on another port:                     PORT=8001 ./run.sh"
  exit 1
fi

# 5. Open the browser once the server answers, then hand the terminal to uvicorn
URL="http://127.0.0.1:$PORT"
(
  for _ in $(seq 1 40); do
    if curl -s -o /dev/null "$URL"; then
      case "$(uname -s)" in
        Darwin) open "$URL" ;;
        Linux)  xdg-open "$URL" >/dev/null 2>&1 || true ;;
        *)      start "$URL" >/dev/null 2>&1 || true ;;
      esac
      exit 0
    fi
    sleep 0.25
  done
) &

echo "Refund Checker  ->  $URL   (Ctrl+C to stop)"
# --reload matters: without it the browser keeps showing the OLD answer after you fix the code
exec "$VENV_BIN/uvicorn" app:app --reload --port "$PORT"
