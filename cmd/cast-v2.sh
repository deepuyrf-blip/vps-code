#!/bin/bash
# Re-render the cast sheet with the ink outline restored.
set -uo pipefail
P=/root/shorts/straw-boats
rsync -a /opt/vps-code/projects/straw-boats/web/ "$P/web/" 2>/dev/null || cp -r /opt/vps-code/projects/straw-boats/web/* "$P/web/"
cd "$P"
node web/render_cast.mjs web out/cast_sheet.png 2>&1 | tail -6
ls -lh out/cast_sheet.png
cp -f out/cast_sheet.png /home/projects/straw-boats-cast.png
BOT=9117420177:AAF-crOEWRzSK09_tZ3SjUTiArs5mtgE2f8
curl -s -X POST "https://api.telegram.org/bot$BOT/sendPhoto" \
  -F "chat_id=8109723300" -F "photo=@/home/projects/straw-boats-cast.png" \
  -F "caption=🎭 Cast v2 — outline restored, soft shadows, 12 cells" | head -c 200
