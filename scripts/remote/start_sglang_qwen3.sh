#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   source ~/venvs/sglang-qwen3/bin/activate
#   bash scripts/remote/start_sglang_qwen3.sh
#
# Optional env:
#   MODEL_PATH=Qwen/Qwen3-4B
#   HOST=0.0.0.0
#   PORT=30000
#   TP_SIZE=1
#   MEM_FRACTION_STATIC=0.85
#   ENABLE_REASONING_PARSER=true

MODEL_PATH="${MODEL_PATH:-Qwen/Qwen3-4B}"
HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-30000}"
MEM_FRACTION_STATIC="${MEM_FRACTION_STATIC:-0.85}"
ENABLE_REASONING_PARSER="${ENABLE_REASONING_PARSER:-true}"

if [[ -z "${TP_SIZE:-}" ]]; then
  if command -v nvidia-smi >/dev/null 2>&1; then
    GPU_COUNT="$(nvidia-smi -L | wc -l | tr -d ' ')"
    if [[ "$GPU_COUNT" =~ ^[0-9]+$ ]] && [[ "$GPU_COUNT" -gt 0 ]]; then
      TP_SIZE="$GPU_COUNT"
    else
      TP_SIZE="1"
    fi
  else
    TP_SIZE="1"
  fi
fi

echo "Starting SGLang..."
echo "MODEL_PATH=$MODEL_PATH"
echo "HOST=$HOST"
echo "PORT=$PORT"
echo "TP_SIZE=$TP_SIZE"
echo "MEM_FRACTION_STATIC=$MEM_FRACTION_STATIC"

BASE_ARGS=(
  --model-path "$MODEL_PATH"
  --host "$HOST"
  --port "$PORT"
  --tensor-parallel-size "$TP_SIZE"
  --mem-fraction-static "$MEM_FRACTION_STATIC"
)

if [[ "$ENABLE_REASONING_PARSER" == "true" ]]; then
  BASE_ARGS+=(--reasoning-parser qwen3)
fi

if command -v sglang >/dev/null 2>&1; then
  exec sglang serve "${BASE_ARGS[@]}"
else
  exec python -m sglang.launch_server "${BASE_ARGS[@]}"
fi
