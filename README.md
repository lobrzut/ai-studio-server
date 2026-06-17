# AI Studio Server

> **One command** on Debian/Ubuntu — clones this repo and installs the stack.

Based on [AI Studio Portable (Local)](https://github.com/lobrzut/ai-studio-portable) — same dashboard UX, Linux deployment.

## Install (one line)

After this repo is on GitHub:

```bash
curl -fsSL https://raw.githubusercontent.com/lobrzut/ai-studio-server/main/bootstrap.sh | sudo bash
```

### Options

```bash
# Force CPU-only (hub in Docker, no GPU services)
curl -fsSL https://raw.githubusercontent.com/lobrzut/ai-studio-server/main/bootstrap.sh | sudo bash -s -- --profile cpu

# AMD ROCm — native ComfyUI on host (no Docker GPU)
curl -fsSL https://raw.githubusercontent.com/lobrzut/ai-studio-server/main/bootstrap.sh | sudo bash -s -- --profile native-rocm

# Custom install path
curl -fsSL .../bootstrap.sh | sudo bash -s -- --dir /srv/ai-studio --data /mnt/ai-data
```

## What it does

1. `bootstrap.sh` — installs `git`/`curl`, clones repo to `/opt/ai-studio-server`, runs `install.sh`
2. `install.sh` — detects GPU profile, installs Docker or native ROCm stack, starts hub on **:7880**
3. Data (models, outputs) under `/var/lib/ai-studio` by default

| Profile | When | Stack |
|---------|------|--------|
| `docker-nvidia` | `nvidia-smi` works | Docker: hub + ComfyUI (CUDA image) |
| `native-rocm` | ROCm installed | systemd: hub venv + ComfyUI on host |
| `cpu` | fallback | Docker: hub only |

## Ports

| Port | Service |
|------|---------|
| 7880 | Dashboard hub |
| 7871 | ComfyUI |
| 7870 | ACE-Step (phase 2 — placeholder in Docker) |

## After install

```bash
cd /opt/ai-studio-server
./scripts/status.sh
./scripts/restart.sh
./scripts/stop.sh
```

Re-run the **same curl one-liner** to update from `main`.

## Manual dev install

```bash
git clone https://github.com/lobrzut/ai-studio-server.git
cd ai-studio-server
sudo ./install.sh
```

## Status (MVP)

- [x] One-command bootstrap
- [x] Hub API + dashboard UI (from Local)
- [x] Docker path (NVIDIA / CPU hub)
- [x] Native ROCm path (ComfyUI host install)
- [ ] ACE-Step Docker image
- [ ] Toolkit post-prod workers on server
- [ ] HTTPS / auth (Caddy)

## Related

- Local edition: https://github.com/lobrzut/ai-studio-portable
