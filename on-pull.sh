#!/bin/bash
# Runs after every successful pull (only when the head commit changed).
# Keep it fast and idempotent — it fires every time new code lands.
set -uo pipefail
cd /opt/vps-code || exit 0
echo "[on-pull] $(date -Is) head=$(git rev-parse --short HEAD)"

# 0) command channel: run cmd/<name>.sh once, then leave a .done marker
if [ -d cmd ]; then
  mkdir -p .ran
  for f in cmd/*.sh; do
    [ -f "$f" ] || continue
    base=$(basename "$f" .sh)
    [ -f ".ran/$base" ] && continue
    echo "  --- running cmd/$base.sh ---"
    bash "$f" 2>&1 | sed 's/^/    /'
    echo "    exit=$?"
    date -Is > ".ran/$base"
  done
fi

# 1) project files that must live under /root/shorts
if [ -d projects ]; then
  for d in projects/*/; do
    [ -d "$d" ] || continue
    name=$(basename "$d")
    mkdir -p "/root/shorts/$name"
    rsync -a --exclude 'frames' --exclude '*.mp4' --exclude 'node_modules' "$d" "/root/shorts/$name/" 2>/dev/null \
      || cp -r "$d"* "/root/shorts/$name/" 2>/dev/null
    echo "  synced projects/$name"
  done
fi

# 2) scripts that must land in /usr/local/bin
if [ -d bin ]; then
  for f in bin/*; do
    [ -f "$f" ] || continue
    install -m 755 "$f" "/usr/local/bin/$(basename "$f")"
    echo "  installed $(basename "$f")"
  done
fi

# 3) anything flagged for a service restart
if [ -f restart.list ]; then
  while read -r svc; do
    [ -z "$svc" ] && continue
    systemctl restart "$svc" 2>/dev/null && echo "  restarted $svc"
  done < restart.list
fi

echo "[on-pull] done"
