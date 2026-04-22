#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   bash scripts/remote/install_sglang.sh
#
# Optional env:
#   VENV_DIR=~/venvs/sglang-qwen3

VENV_DIR="${VENV_DIR:-$HOME/venvs/sglang-qwen3}"
PYTHON_BIN="${PYTHON_BIN:-python3}"

echo "[1/5] Checking Python..."
if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
  echo "ERROR: python3 not found. Please install Python 3.10+ on the remote Ubuntu host."
  exit 1
fi

echo "[2/5] Creating virtual environment: $VENV_DIR"
"$PYTHON_BIN" -m venv "$VENV_DIR"

echo "[3/5] Activating virtual environment"
# shellcheck source=/dev/null
source "$VENV_DIR/bin/activate"

echo "[4/5] Installing dependencies"
python -m pip install --upgrade pip setuptools wheel
python -m pip install "sglang[all]>=0.4.6.post1" "openai>=1.0.0"

echo "[5/5] Done"
echo
echo "Next:"
echo "  source \"$VENV_DIR/bin/activate\""
echo "  bash scripts/remote/start_sglang_qwen3.sh"
