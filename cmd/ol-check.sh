#!/bin/bash
# Diagnostic: what is the Pen outline default, and how does main.js use it?
P=/root/shorts/straw-boats/web
echo "=== Pen ol in toonbase.js ==="
grep -n "this.ol\|ol = " "$P/toonbase.js" | head -10
echo "=== ol usage in main.js ==="
grep -n "\.ol" "$P/main.js" | head -10
echo "=== relay alive? ==="
systemctl is-active hf-relay
tail -3 /var/log/hf-relay.log 2>/dev/null
