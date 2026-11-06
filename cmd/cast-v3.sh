#!/bin/bash
# Swap in cast v3 and re-render the sheet.
set -uo pipefail
P=/root/shorts/straw-boats
W=$P/web

rsync -a /opt/vps-code/projects/straw-boats/web/cast_v3.js "$W/cast_v3.js" 2>/dev/null \
  || cp /opt/vps-code/projects/straw-boats/web/cast_v3.js "$W/cast_v3.js"

python3 - <<'PY'
import re
W = '/root/shorts/straw-boats/web'
s = open(f'{W}/roman.js').read()
marker = '// ---------------------------------------------------------------- straw-boats cast'
i = s.find(marker)
if i > 0:
    s = s[:i].rstrip() + '\n'
v3 = open(f'{W}/cast_v3.js').read()
open(f'{W}/roman.js', 'w').write(s + '\n' + v3)
print('roman.js rebuilt:', len(s) + len(v3), 'bytes')
PY

cd "$W" && cat toonbase.js roman.js > toon.js && wc -c toon.js

cd "$P"
node web/render_cast.mjs web out/cast_sheet.png 2>&1 | tail -6
ls -lh out/cast_sheet.png
cp -f out/cast_sheet.png /home/projects/straw-boats-cast.png

BOT=9117420177:AAF-crOEWRzSK09_tZ3SjUTiArs5mtgE2f8
curl -s -X POST "https://api.telegram.org/bot$BOT/sendPhoto" \
  -F "chat_id=8109723300" -F "photo=@/home/projects/straw-boats-cast.png" \
  -F "caption=🎭 Cast v3 — white faces, no beards, big heads, thick ink" | head -c 200
