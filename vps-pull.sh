#!/bin/bash
# Installs a 5-minute GitHub pull on this box, so code changes never need the
# Hugging Face relay again.
#
#   bash vps-pull.sh            # install / update
#   bash vps-pull.sh --once     # pull once now
#
# The repo is private; a fine-grained token with read access lives in
# /etc/vps-code.env (chmod 600). Rotate it in GitHub -> Settings -> Developer settings.
set -euo pipefail

REPO="deepuyrf-blip/vps-code"
DIR="/opt/vps-code"
ENVF="/etc/vps-code.env"

if [ "${1:-}" = "--once" ]; then
  if [ -d "$DIR/.git" ]; then
    cd "$DIR" && git pull --ff-only
  else
    mkdir -p "$DIR"
    cd "$DIR"
    git clone "https://${GITHUB_TOKEN:?}@github.com/${REPO}.git" .
  fi
  exit 0
fi

if [ ! -f "$ENVF" ]; then
  echo "ERROR: $ENVF is missing. Create it with: GITHUB_TOKEN=github_pat_xxx"
  exit 1
fi
chmod 600 "$ENVF"
. "$ENVF"
export GITHUB_TOKEN

if [ ! -d "$DIR/.git" ]; then
  rm -rf "$DIR"
  mkdir -p "$DIR"
  git clone "https://${GITHUB_TOKEN}@github.com/${REPO}.git" "$DIR"
else
  cd "$DIR" && git pull --ff-only || true
fi
cd "$DIR"
git config user.email "vps@local"
git config user.name "vps"

cat > /usr/local/bin/vps-pull <<'SH'
#!/bin/bash
set -uo pipefail
. /etc/vps-code.env
cd /opt/vps-code || exit 0
BEFORE=$(git rev-parse HEAD 2>/dev/null)
git pull --ff-only --quiet "https://${GITHUB_TOKEN}@github.com/deepuyrf-blip/vps-code.git" main >/dev/null 2>&1
AFTER=$(git rev-parse HEAD 2>/dev/null)
if [ "$BEFORE" != "$AFTER" ]; then
  echo "[vps-pull] $(date -Is) updated $BEFORE -> $AFTER"
  [ -x /opt/vps-code/on-pull.sh ] && bash /opt/vps-code/on-pull.sh
fi
SH
chmod +x /usr/local/bin/vps-pull

cat > /etc/systemd/system/vps-pull.service <<'UNIT'
[Unit]
Description=Pull the VPS code channel from GitHub
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/vps-pull
UNIT

cat > /etc/systemd/system/vps-pull.timer <<'UNIT'
[Unit]
Description=Pull the VPS code channel every 5 minutes

[Timer]
OnBootSec=60
OnUnitActiveSec=300
AccuracySec=15s
Unit=vps-pull.service

[Install]
WantedBy=timers.target
UNIT

systemctl daemon-reload
systemctl enable --now vps-pull.timer
sleep 2
echo "timer: $(systemctl is-active vps-pull.timer)"
systemctl list-timers vps-pull.timer --no-pager | head -3
echo "first pull:"
/usr/local/bin/vps-pull || true
echo "repo head: $(cd /opt/vps-code && git log -1 --oneline)"
