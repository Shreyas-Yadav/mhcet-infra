#!/usr/bin/env bash
# One Cloud Run Job task: fire COUNT concurrent-limited requests at API_URL.
# Env: COUNT (default 300), CONCURRENCY (default 25), API_URL (required).

set -euo pipefail

API_URL="${API_URL:?API_URL is required}"
COUNT="${COUNT:-300}"
CONCURRENCY="${CONCURRENCY:-25}"

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

task_index="${CLOUD_RUN_TASK_INDEX:-0}"
task_attempt="${CLOUD_RUN_TASK_ATTEMPT:-0}"

echo "task=${task_index} attempt=${task_attempt}"
echo "target=${API_URL}"
echo "count=${COUNT} concurrency=${CONCURRENCY}"
echo "started=$(date -u +%Y-%m-%dT%H:%M:%SZ)"

start_ms=$(date +%s)

i=0
while [ "$i" -lt "$COUNT" ]; do
  batch=0
  while [ "$batch" -lt "$CONCURRENCY" ] && [ "$i" -lt "$COUNT" ]; do
    curl -s -o /dev/null -w "%{http_code}\n" "$API_URL" >>"$tmp" &
    i=$((i + 1))
    batch=$((batch + 1))
  done
  wait
done

elapsed_s=$(( $(date +%s) - start_ms ))
echo "finished_in=${elapsed_s}s"
echo "status_codes:"
sort "$tmp" | uniq -c | sort -rn

ok=$(grep -c '^200$' "$tmp" || true)
limited=$(grep -c '^429$' "$tmp" || true)
unavailable=$(grep -c '^503$' "$tmp" || true)

echo "summary: ok=${ok} limited=${limited} unavailable=${unavailable}"
