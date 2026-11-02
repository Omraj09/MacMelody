#!/bin/bash
# Builds a distributable .dmg installer for MacMelody containing MacMelody.app and an Applications symlink.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
app="$root/build/MacMelody.app"
dmg="$root/build/MacMelody.dmg"
vol_name="MacMelody"
tmp_dmg="$root/build/pack.temp.dmg"

# Ensure the app is built
if [[ ! -d "$app" ]]; then
  echo "Building MacMelody.app first..."
  "$root/scripts/build-app.sh"
fi

echo "Preparing DMG staging directory..."
staging="$root/build/dmg-staging"
rm -rf "$staging" "$tmp_dmg" "$dmg"
mkdir -p "$staging"

cp -R "$app" "$staging/MacMelody.app"
ln -s /Applications "$staging/Applications"

# Volume icon
if [[ -f "$root/Packaging/AppIcon.icns" ]]; then
  cp "$root/Packaging/AppIcon.icns" "$staging/.VolumeIcon.icns"
  SetFile -a C "$staging" 2>/dev/null || true
fi

# Calculate required size in MB with safety margin
size_kb=$(du -sk "$staging" | awk '{print $1}')
dmg_size_mb=$(( (size_kb / 1024) + 20 ))

echo "Creating writable disk image (${dmg_size_mb} MB)..."
hdiutil create -srcfolder "$staging" -volname "$vol_name" -fs HFS+ \
      -fsargs "-c c=64,a=16,e=16" -format UDRW -size "${dmg_size_mb}m" "$tmp_dmg"

echo "Mounting disk image for folder styling..."
device=$(hdiutil attach -readwrite -noverify -noautoopen "$tmp_dmg" | grep -E '^/dev/' | sed 1q | awk '{print $1}')
mount_point="/Volumes/$vol_name"

# Wait for mount
for _ in {1..10}; do
  if [[ -d "$mount_point" ]]; then
    break
  fi
  sleep 1
done

if [[ -d "$mount_point" ]]; then
  if [[ -f "$root/Packaging/AppIcon.icns" ]]; then
    cp "$root/Packaging/AppIcon.icns" "$mount_point/.VolumeIcon.icns" 2>/dev/null || true
    SetFile -a C "$mount_point" 2>/dev/null || true
    SetFile -a V "$mount_point/.VolumeIcon.icns" 2>/dev/null || true
  fi

  # Attempt clean Finder layout (MacMelody.app on left, Applications on right)
  osascript -e "
    tell application \"Finder\"
      tell disk \"$vol_name\"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {400, 200, 940, 520}
        set viewOptions to the icon view options of container window
        set icon size of viewOptions to 96
        set arrangement of viewOptions to not arranged
        set position of item \"MacMelody.app\" of container window to {140, 160}
        set position of item \"Applications\" of container window to {400, 160}
        close
        open
        update without registering applications
        delay 1
        close
      end tell
    end tell
  " 2>/dev/null || true

  if [[ -f "$mount_point/.VolumeIcon.icns" ]]; then
    SetFile -a V "$mount_point/.VolumeIcon.icns" 2>&1 >/dev/null || true
  fi
  sync
fi

echo "Detaching disk image..."
hdiutil detach "$device" -force 2>/dev/null || hdiutil detach "$mount_point" -force 2>/dev/null || (sleep 2 && hdiutil detach "$device" -force)

echo "Compressing into final read-only DMG..."
hdiutil convert "$tmp_dmg" -format UDZO -imagekey zlib-level=9 -o "$dmg"
rm -f "$tmp_dmg"
rm -rf "$staging"

echo "Done! Created DMG at: $dmg"
ls -lh "$dmg"
