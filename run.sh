#!/usr/bin/env bash
# Open Soccer Arena Clash in Godot editor

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GODOT="/Applications/Godot.app/Contents/MacOS/Godot"

if [ ! -f "$GODOT" ]; then
  echo "Godot niet gevonden op: $GODOT"
  echo "Pas het pad aan als Godot ergens anders staat."
  exit 1
fi

"$GODOT" --path "$PROJECT_DIR" 2>&1 &
