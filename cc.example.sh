#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNNER_SCRIPT="$SCRIPT_DIR/run-claude.sh"

if [[ ! -x "$RUNNER_SCRIPT" ]]; then
  chmod +x "$RUNNER_SCRIPT"
fi

# Local relay config (kept out of git by .gitignore).
export ANTHROPIC_BASE_URL="xxxx"
export ANTHROPIC_AUTH_TOKEN="xxxx"
export API_TIMEOUT_MS="3000000"
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC="1"

# Local proxy defaults for build/runtime network access (override if needed).
export CLASH_HTTP_PROXY="${CLASH_HTTP_PROXY:-http://host.docker.internal:7890}"
export CLASH_SOCKS_PROXY="${CLASH_SOCKS_PROXY:-socks5://host.docker.internal:7890}"
export HTTP_PROXY="${HTTP_PROXY:-$CLASH_HTTP_PROXY}"
export HTTPS_PROXY="${HTTPS_PROXY:-$CLASH_HTTP_PROXY}"
export ALL_PROXY="${ALL_PROXY:-$CLASH_SOCKS_PROXY}"
export NO_PROXY="${NO_PROXY:-localhost,127.0.0.1,::1,host.docker.internal}"

# Other packages to install
export RUN_CLAUDE_EXTRA_PACKAGES="${RUN_CLAUDE_EXTRA_PACKAGES:-xxxx}"

# Ensure workspace-local SSH directory exists for read-only mount.
if [[ ! -d "$SCRIPT_DIR/.ssh" ]]; then
  mkdir -p "$SCRIPT_DIR/.ssh"
  chmod 700 "$SCRIPT_DIR/.ssh"
fi

exec "$RUNNER_SCRIPT" \
  -w "$SCRIPT_DIR" \
  -E ANTHROPIC_BASE_URL \
  -E ANTHROPIC_AUTH_TOKEN \
  -E API_TIMEOUT_MS \
  -E CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC \
  -E HTTP_PROXY \
  -E HTTPS_PROXY \
  -E ALL_PROXY \
  -E NO_PROXY \
  -E RUN_CLAUDE_EXTRA_PACKAGES \
  "$@"
