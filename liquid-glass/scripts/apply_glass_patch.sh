# !/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
ROOT="${1:-}"
if [ -z "$ROOT" ] || [ ! -d "$ROOT/res" ]; then echo "Usage: $0 /path/to/apktool-decoded-launcher"; exit 1; fi
STAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP="$ROOT/.gg_glass_backup_$STAMP"
mkdir -p "$BACKUP" "$ROOT/res/drawable" "$ROOT/res/values" "$ROOT/res/values-night"
cp -f "$ROOT/AndroidManifest.xml" "$BACKUP/AndroidManifest.xml" 2>/dev/null || true
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
cp "$SCRIPT_DIR/../res/drawable/gg_glass_panel.xml" "$ROOT/res/drawable/"
cp "$SCRIPT_DIR/../res/drawable/gg_glass_panel_dark.xml" "$ROOT/res/drawable/"
cp "$SCRIPT_DIR/../res/drawable/gg_glass_strong.xml" "$ROOT/res/drawable/"
cp "$SCRIPT_DIR/../res/drawable/gg_glass_strong_dark.xml" "$ROOT/res/drawable/"
cp "$SCRIPT_DIR/../res/values/liquid_glass_colors.xml" "$ROOT/res/values/"
cp "$SCRIPT_DIR/../res/values/styles_liquid_glass.xml" "$ROOT/res/values/"
cp "$SCRIPT_DIR/../res/values-night/liquid_glass_colors.xml" "$ROOT/res/values-night/"
echo "Liquid Glass resources installed. Backup: $BACKUP"
"$SCRIPT_DIR/find_existing_blur.sh" "$ROOT" || true
