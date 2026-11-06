#!/bin/bash
# Installs a 5-minute GitHub pull on this box, so code changes never need the
# Hugging Face relay again. The repo is public, so no token is required.
#
#   bash vps-pull.sh            # install / update
#   bash vps-pull.sh --once     # pull once now
set -euo pipefail

REPO="https://github.com/deepuyrf-blip/vps-code.git"
DIR="/opt/vps-code"

echo "==> clone / update $DIR"
if [ ! -d "$DIR/.git" ]; then
  rm -rf "$DIR"
  mkdir -p "$DIR"
  git clone --quiet "$REPO" "$DIR"
else
  cd "$DIR" && git pull --ff-only --quiet || true
fi
cd "$DIR"

cat > /usr/local/bin/vps-pull <<'SH'
#!/bin/bash
# Pull the public code channel. Silent unless the head commit moved.
set -uo pipefail
cd /opt/vps-code 2>/dev/null || exit 0
BEFORE=$(git rev-parse HEAD 2>/dev/null)
git pull --ff-only --quiet origin main >/dev/null 2>&1
AFTER=$(git rev-parse HEAD 2>/dev/null)
if [ "$BEFORE" != "$AFTER" ]; then
  echo "[vps-pull] $(date -Is) $BEFORE -> $AFTER"
  if [ -x /opt/vps-code/on-pull.sh ]; then bash /opt/vps-code/on-pull.sh; fi
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
OnBootSec=45
OnUnitActiveSec=300
AccuracySec=15s
Unit=vps-pull.service

[Install]
WantedBy=timers.target
UNIT

systemctl daemon-reload
systemctl enable --now vps-pull.timer
sleep 2
echo "timer:   $(systemctl is-active vps-pull.timer)"
echo "next:    $(systemctl show vps-pull.timer -p NextElapseUSecRealtime --value 2>/dev/null)"
/usr/local/bin/vps-pull || true
echo "head:    $(cd /opt/vps-code && git log -1 --oneline)"
