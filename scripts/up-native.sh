#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_DIR="${AI_STUDIO_DATA:-/var/lib/ai-studio}"

install_unit() {
  local name="$1"
  sed "s|@INSTALL_DIR@|${ROOT}|g; s|@DATA_DIR@|${DATA_DIR}|g" \
    "${ROOT}/systemd/${name}.service.in" >"/etc/systemd/system/${name}.service"
}

echo "==> Installing systemd units..."
install_unit aistudio-hub
install_unit aistudio-comfy
systemctl daemon-reload
systemctl enable aistudio-hub aistudio-comfy
systemctl restart aistudio-hub aistudio-comfy || true
