#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNNER_SCRIPT="$SCRIPT_DIR/run-claude.sh"
BASHRC_FILE="$HOME/.bashrc"

if [[ ! -x "$RUNNER_SCRIPT" ]]; then
  chmod +x "$RUNNER_SCRIPT"
fi

append_export_if_missing() {
  local export_line="$1"
  if [[ ! -f "$BASHRC_FILE" ]]; then
    touch "$BASHRC_FILE"
  fi
  if ! grep -Fqx "$export_line" "$BASHRC_FILE"; then
    echo "$export_line" >> "$BASHRC_FILE"
  fi
}

# Persist env vars to ~/.bashrc (explicitly)
append_export_if_missing 'export ANTHROPIC_BASE_URL="https://nexusacc.itssx.com/api/claude_code/mixedcc"'
append_export_if_missing 'export ANTHROPIC_AUTH_TOKEN="cr_xxxxxxxxxx"'
append_export_if_missing 'export API_TIMEOUT_MS="3000000"'
append_export_if_missing 'export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC="1"'

# Also export for this launch context
export ANTHROPIC_BASE_URL="https://nexusacc.itssx.com/api/claude_code/mixedcc"
export ANTHROPIC_AUTH_TOKEN="cr_xxxxxxxxxx"
export API_TIMEOUT_MS="3000000"
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC="1"

# Local proxy defaults for build/runtime network access (override if needed).
export CLASH_HTTP_PROXY="${CLASH_HTTP_PROXY:-http://host.docker.internal:7890}"
export CLASH_SOCKS_PROXY="${CLASH_SOCKS_PROXY:-socks5://host.docker.internal:7890}"
export HTTP_PROXY="${HTTP_PROXY:-$CLASH_HTTP_PROXY}"
export HTTPS_PROXY="${HTTPS_PROXY:-$CLASH_HTTP_PROXY}"
export ALL_PROXY="${ALL_PROXY:-$CLASH_SOCKS_PROXY}"
export NO_PROXY="${NO_PROXY:-localhost,127.0.0.1,::1,host.docker.internal}"

# Load bashrc as requested
# shellcheck disable=SC1090
source "$BASHRC_FILE"

# Ensure local isolated SSH mount source exists under workspace
if [[ ! -d "$SCRIPT_DIR/.ssh" ]]; then
  mkdir -p "$SCRIPT_DIR/.ssh"
  chmod 700 "$SCRIPT_DIR/.ssh"
fi

# Forward custom variables explicitly and use workspace-local .ssh mount
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
  "$@"
