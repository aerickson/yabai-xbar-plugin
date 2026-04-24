#!/bin/bash

set -euo pipefail

PLUGIN="yabai_skhd.1s.sh"
XBAR_PLUGIN_DIR="$HOME/Library/Application Support/xbar/plugins"
SRC="$(cd "$(dirname "$0")" && pwd)/$PLUGIN"
DST="$XBAR_PLUGIN_DIR/$PLUGIN"

if [[ ! -d "$XBAR_PLUGIN_DIR" ]]; then
  echo "xbar plugins directory not found: $XBAR_PLUGIN_DIR"
  exit 1
fi

if [[ -e "$DST" && ! -L "$DST" ]]; then
  echo "A non-symlink file already exists at $DST"
  echo "Remove it manually and re-run to install."
  exit 1
fi

ln -sf "$SRC" "$DST"
chmod +x "$SRC"
echo "Installed: $DST -> $SRC"
