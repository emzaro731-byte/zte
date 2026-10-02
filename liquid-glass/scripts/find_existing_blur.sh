# !/data/data/com.termux/files/usr/bin/bash
set -u
ROOT="${1:-.}"
echo "== Existing blur support =="
grep -RInE 'BlurUtils|BlurEffect|RenderEffect|setBackgroundBlurRadius|setWallpaperBlur|setBackgroundBlur|BlurredWallpaper|CROSS_WINDOW_BLUR' "$ROOT/smali" "$ROOT/smali_classes2" "$ROOT/smali_classes3" 2>/dev/null | head -300 || true
echo
echo "== Glass-related strings =="
grep -RInE 'Glass|glass|transluc|frost|scrim|blur' "$ROOT/smali" "$ROOT/smali_classes2" "$ROOT/smali_classes3" 2>/dev/null | head -300 || true
