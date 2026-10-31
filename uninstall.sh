#!/bin/bash

# Puts Omarchy's own dock and titlebars back. Leaves this checkout and the dock
# pins in shell.json alone.

set -euo pipefail

PLUGIN_ID="rafabertholdo.dock"
PLUGINS_DIR="$HOME/.config/omarchy/plugins"
HYPR_DIR="$HOME/.config/hypr"

say() { echo -e "\e[32m==>\e[0m $*"; }

say "Restoring Omarchy's dock"
omarchy plugin disable "$PLUGIN_ID" >/dev/null 2>&1 || true
[[ -L $PLUGINS_DIR/$PLUGIN_ID ]] && rm "$PLUGINS_DIR/$PLUGIN_ID"
omarchy-shell shell rescanPlugins >/dev/null
omarchy plugin enable omarchy.dock >/dev/null

say "Removing the titlebar override"
sed -i '/^require("hypr.titlebars")$/d' "$HYPR_DIR/hyprland.lua"
[[ -L $HYPR_DIR/titlebars.lua ]] && rm "$HYPR_DIR/titlebars.lua"

say "Reloading"
hyprctl reload >/dev/null
omarchy restart shell >/dev/null 2>&1 || true

say "Done."
