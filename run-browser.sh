#!/usr/bin/env bash
# Export Soccer Arena Clash naar Web en open in browser
# Vereist: HTML5 export preset in Godot (Project → Export → Add → Web)

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GODOT="/Applications/Godot.app/Contents/MacOS/Godot"
WEB_DIR="$PROJECT_DIR/web"
PORT=8060

if [ ! -f "$GODOT" ]; then
  echo "Godot niet gevonden op: $GODOT"
  exit 1
fi

# Export naar web/
echo "Exporteren naar web/..."
"$GODOT" --headless --path "$PROJECT_DIR" --export-release "Web" "$WEB_DIR/index.html" 2>&1

if [ $? -ne 0 ]; then
  echo ""
  echo "Export mislukt. Voeg eerst de Web export preset toe:"
  echo "  1. Open Godot en dit project"
  echo "  2. Project → Export"
  echo "  3. Add → Web"
  echo "  4. Export Path: web/index.html"
  echo "  5. Sla op en run dit script opnieuw"
  exit 1
fi

if [ ! -f "$WEB_DIR/index.html" ]; then
  echo "index.html niet gevonden na export."
  exit 1
fi

# Serveer en open browser
URL="http://127.0.0.1:$PORT"
echo "Starten lokale server op $URL"
echo "Druk Ctrl+C om te stoppen."
echo ""

cd "$WEB_DIR"
if command -v python3 &> /dev/null; then
  (sleep 2 && open "$URL" 2>/dev/null) &
  python3 -m http.server $PORT
elif command -v python &> /dev/null; then
  (sleep 2 && open "$URL" 2>/dev/null) &
  python -m http.server $PORT
else
  echo "Python niet gevonden. Open handmatig: $WEB_DIR/index.html"
  exit 1
fi
