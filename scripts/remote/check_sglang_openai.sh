#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   bash scripts/remote/check_sglang_openai.sh
#
# Optional env:
#   BASE_URL=http://127.0.0.1:30000/v1
#   MODEL=Qwen/Qwen3-4B

BASE_URL="${BASE_URL:-http://127.0.0.1:30000/v1}"
MODEL="${MODEL:-Qwen/Qwen3-4B}"

curl -sS "${BASE_URL}/chat/completions" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"${MODEL}\",
    \"messages\": [{\"role\": \"user\", \"content\": \"你是谁？用一句话回答\"}],
    \"temperature\": 0.2,
    \"max_tokens\": 64
  }" | python3 -m json.tool
