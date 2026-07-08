#!/bin/bash

set -euo pipefail

PLUGIN="yabai_skhd.1s.sh"
SWIFTBAR_PLUGIN_DIR="$HOME/.swiftbar"
SRC="$(cd "$(dirname "$0")" && pwd)/$PLUGIN"
DST="$SWIFTBAR_PLUGIN_DIR/$PLUGIN"

mkdir -p "$SWIFTBAR_PLUGIN_DIR"

if [[ -e "$DST" && ! -L "$DST" ]]; then
  echo "A non-symlink file already exists at $DST"
  echo "Remove it manually and re-run to install."
  exit 1
fi

ln -sf "$SRC" "$DST"
chmod +x "$SRC"
echo "Installed: $DST -> $SRC"
open -g 'swiftbar://app.swiftbarapp.com/refreshPlugin?name=yabai.*?.sh' >/dev/null 2>&1 || true
