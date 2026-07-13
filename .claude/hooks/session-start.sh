#!/bin/bash
set -euo pipefail

# Only needed in Claude Code on the web's ephemeral containers.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

if ! command -v nix >/dev/null 2>&1 && [ ! -x /root/.nix-profile/bin/nix ]; then
  # Running as root with no `nixbld` build-users-group, so a multi-user
  # install isn't possible here; disable the group requirement up front
  # so the official installer's single-user fallback succeeds non-interactively.
  mkdir -p /etc/nix
  grep -qs '^build-users-group' /etc/nix/nix.conf 2>/dev/null || echo "build-users-group =" >> /etc/nix/nix.conf

  curl -sSL https://nixos.org/nix/install -o /tmp/nix-install.sh
  sh /tmp/nix-install.sh --no-daemon
fi

if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo 'export PATH="/root/.nix-profile/bin:$PATH"' >> "$CLAUDE_ENV_FILE"
fi
