#!/usr/bin/env bash
# Post-export: herstel favicon, icon.png en social meta tags na Godot web export.
# Run na elke export, of automatisch via run-browser.sh

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEB_DIR="$PROJECT_DIR/web"
INDEX="$WEB_DIR/index.html"

# 1. Kopieer icon.png en index.png naar web/
for f in icon.png index.png; do
  if [ -f "$PROJECT_DIR/$f" ]; then
    cp "$PROJECT_DIR/$f" "$WEB_DIR/$f"
    echo "✓ $f gekopieerd naar web/"
  else
    echo "! $f niet gevonden in project root"
  fi
done

# 2. Patch index.html met Python (betrouwbaar op macOS)
if [ ! -f "$INDEX" ]; then
  echo "! index.html niet gevonden. Run eerst Godot web export."
  exit 1
fi

INDEX_PATH="$INDEX" python3 << 'PYEOF'
import os, sys, re
path = os.environ.get("INDEX_PATH", "")
if not path:
    print("! Geen index pad")
    sys.exit(1)
with open(path, "r") as f:
    s = f.read()

# Favicon: flexibele match (tabs of spaties)
favicon_pat = r'<link[^>]*rel="icon"[^>]*>[\s\n]*<link[^>]*apple-touch-icon[^>]*>'
favicon_new = '''<link rel="icon" type="image/png" href="icon.png" />
		<link rel="apple-touch-icon" href="icon.png" />
		<meta property="og:image" content="icon.png" />
		<meta property="og:title" content="Soccer Arena Clash" />
		<meta property="og:description" content="Top-down soccer arena battle game. Select your hero and play!" />
		<meta property="og:type" content="website" />
		<meta name="twitter:card" content="summary_large_image" />
		<meta name="twitter:image" content="icon.png" />
		<meta name="twitter:title" content="Soccer Arena Clash" />
		<meta name="twitter:description" content="Top-down soccer arena battle game. Select your hero and play!" />'''
if re.search(favicon_pat, s):
    s = re.sub(favicon_pat, favicon_new, s, count=1)
    print("✓ index.html gepatcht: favicon + social meta tags")
else:
    print("- Favicon block niet gevonden (al gepatcht)")

# GODOT_THREADS_ENABLED
s = s.replace("GODOT_THREADS_ENABLED = true", "GODOT_THREADS_ENABLED = false")
print("✓ GODOT_THREADS_ENABLED geforceerd naar false")

# ensureCrossOriginIsolationHeaders in GODOT_CONFIG (belangrijk voor splash hang)
s = re.sub(r'"ensureCrossOriginIsolationHeaders"\s*:\s*true', '"ensureCrossOriginIsolationHeaders":false', s)
print("✓ ensureCrossOriginIsolationHeaders op false gezet")

with open(path, "w") as f:
    f.write(s)
PYEOF
