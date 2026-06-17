#!/usr/bin/env bash
# AI Studio Server — one-command bootstrap
# Usage (after repo is on GitHub):
#   curl -fsSL https://raw.githubusercontent.com/lobrzut/ai-studio-server/main/bootstrap.sh | sudo bash
#
# Dev / custom repo:
#   curl -fsSL .../bootstrap.sh | sudo bash -s -- --repo https://github.com/you/ai-studio-server.git
set -euo pipefail

REPO_URL="${AI_STUDIO_REPO:-https://github.com/lobrzut/ai-studio-server.git}"
INSTALL_DIR="${AI_STUDIO_DIR:-/opt/ai-studio-server}"
BRANCH="${AI_STUDIO_BRANCH:-main}"
DATA_DIR="${AI_STUDIO_DATA:-/var/lib/ai-studio}"

usage() {
  cat <<'EOF'
AI Studio Server bootstrap

  curl -fsSL https://raw.githubusercontent.com/lobrzut/ai-studio-server/main/bootstrap.sh | sudo bash

Options (pass after bash -s --):
  --repo URL       Git clone URL (default: lobrzut/ai-studio-server)
  --dir PATH       Install dir (default: /opt/ai-studio-server)
  --branch NAME    Git branch (default: main)
  --data PATH      Data/models dir (default: /var/lib/ai-studio)
  --profile NAME   Force: docker-nvidia | native-rocm | cpu
  --help

Env: AI_STUDIO_REPO, AI_STUDIO_DIR, AI_STUDIO_BRANCH, AI_STUDIO_DATA
EOF
}

PROFILE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)   REPO_URL="$2"; shift 2 ;;
    --dir)    INSTALL_DIR="$2"; shift 2 ;;
    --branch) BRANCH="$2"; shift 2 ;;
    --data)   DATA_DIR="$2"; shift 2 ;;
    --profile) PROFILE="$2"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  echo "ERROR: run as root — pipe to sudo bash:" >&2
  echo "  curl -fsSL .../bootstrap.sh | sudo bash" >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo "==> AI Studio Server bootstrap"
echo "    repo:   $REPO_URL"
echo "    dir:    $INSTALL_DIR"
echo "    branch: $BRANCH"
echo "    data:   $DATA_DIR"

apt-get update -qq
apt-get install -y -qq git curl ca-certificates

if [[ -d "$INSTALL_DIR/.git" ]]; then
  echo "==> Updating existing install..."
  git -C "$INSTALL_DIR" fetch --depth 1 origin "$BRANCH"
  git -C "$INSTALL_DIR" checkout -f "$BRANCH"
  git -C "$INSTALL_DIR" reset --hard "origin/$BRANCH"
else
  echo "==> Cloning repository..."
  mkdir -p "$(dirname "$INSTALL_DIR")"
  git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
fi

export AI_STUDIO_DIR="$INSTALL_DIR"
export AI_STUDIO_DATA="$DATA_DIR"
[[ -n "$PROFILE" ]] && export AI_STUDIO_PROFILE="$PROFILE"

exec bash "$INSTALL_DIR/install.sh"
