#!/usr/bin/env bash
# Post-export: herstel favicon, icon.png en social meta tags na Godot web export.
# Run na elke export, of automatisch via run-browser.sh

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEB_DIR="$PROJECT_DIR/web"
INDEX="$WEB_DIR/index.html"

# 1. Kopieer icon.png naar web/
if [ -f "$PROJECT_DIR/icon.png" ]; then
  cp "$PROJECT_DIR/icon.png" "$WEB_DIR/icon.png"
  echo "✓ icon.png gekopieerd naar web/"
else
  echo "! icon.png niet gevonden in project root"
fi

# 2. Patch index.html met Python (betrouwbaar op macOS)
if [ ! -f "$INDEX" ]; then
  echo "! index.html niet gevonden. Run eerst Godot web export."
  exit 1
fi

INDEX_PATH="$INDEX" python3 << 'PYEOF'
import os, sys
path = os.environ.get("INDEX_PATH", "")
if not path:
    print("! Geen index pad")
    sys.exit(1)
with open(path, "r") as f:
    s = f.read()

old = '\t\t<link id="-gd-engine-icon" rel="icon" type="image/png" href="index.icon.png" />\n<link rel="apple-touch-icon" href="index.apple-touch-icon.png"/>'

new = '''\t\t<link rel="icon" type="image/png" href="icon.png" />
\t\t<link rel="apple-touch-icon" href="icon.png" />
\t\t<meta property="og:image" content="icon.png" />
\t\t<meta property="og:title" content="Soccer Arena Clash" />
\t\t<meta property="og:description" content="Top-down soccer arena battle game. Select your hero and play!" />
\t\t<meta property="og:type" content="website" />
\t\t<meta name="twitter:card" content="summary_large_image" />
\t\t<meta name="twitter:image" content="icon.png" />
\t\t<meta name="twitter:title" content="Soccer Arena Clash" />
\t\t<meta name="twitter:description" content="Top-down soccer arena battle game. Select your hero and play!" />'''

if old in s:
    s = s.replace(old, new)
    with open(path, "w") as f:
        f.write(s)
    print("✓ index.html gepatcht: favicon + social meta tags")
else:
    print("! Geen standaard favicon-block gevonden (al gepatcht of ander template)")
PYEOF
