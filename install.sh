#!/bin/bash

# Installs the macOS Dock from this checkout into an Omarchy 4.5+ desktop, and
# with --titlebars the macOS-style titlebars too. Everything is symlinked, so
# `git pull` updates it in place. Safe to run again.
#
# Usage: ./install.sh [--titlebars]

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ID="$(jq -r .id "$REPO/manifest.json")"
OLD_PLUGIN_IDS=(rafabertholdo.dock)
PLUGINS_DIR="$HOME/.config/omarchy/plugins"
HYPR_DIR="$HOME/.config/hypr"
STAMP="$(date +%Y%m%d%H%M%S)"

say() { echo -e "\e[32m==>\e[0m $*"; }
fail() { echo "install.sh: $*" >&2; exit 1; }

titlebars=0
for arg in "$@"; do
  case "$arg" in
  --titlebars) titlebars=1 ;;
  -h | --help) sed -n '3,7p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
  *) fail "unknown option: $arg" ;;
  esac
done

[[ -d ${OMARCHY_PATH:-/usr/share/omarchy}/shell/plugins/dock ]] ||
  fail "this Omarchy has no dock plugin; it needs Omarchy 4.5 or newer"

# Links $2 to $1, moving aside anything else already at $2. The backup is
# hidden, as omarchy plugin remove does, or the shell would load a backed-up
# plugin as a second copy.
link() {
  local source="$1" target="$2"
  if [[ -L $target && $(readlink -f "$target") == "$(readlink -f "$source")" ]]; then
    return
  fi
  if [[ -e $target || -L $target ]]; then
    local backup
    backup="$(dirname "$target")/.$(basename "$target").bak.$STAMP"
    mv "$target" "$backup"
    echo "    moved the existing $target to $backup"
  fi
  ln -s "$source" "$target"
}

# Earlier versions of this dock used another id; only links are removed.
for old in "${OLD_PLUGIN_IDS[@]}"; do
  if [[ -L $PLUGINS_DIR/$old ]]; then
    say "Removing the old $old link"
    omarchy plugin disable "$old" >/dev/null 2>&1 || true
    rm "$PLUGINS_DIR/$old"
  fi
done

say "Linking the dock plugin"
mkdir -p "$PLUGINS_DIR"
link "$REPO" "$PLUGINS_DIR/$PLUGIN_ID"
omarchy-shell shell rescanPlugins >/dev/null

say "Replacing Omarchy's dock with it"
omarchy plugin disable omarchy.dock >/dev/null || true
omarchy plugin enable "$PLUGIN_ID" >/dev/null

if [[ -s $REPO/dock-pins.txt ]]; then
  say "Pinning apps from dock-pins.txt"
  mapfile -t pins < <(grep -v '^\s*\(#\|$\)' "$REPO/dock-pins.txt")
  (( ${#pins[@]} > 0 )) && omarchy dock pinned "${pins[@]}" >/dev/null
fi

if (( titlebars )); then
  say "Linking the titlebar override"
  link "$REPO/hypr/titlebars.lua" "$HYPR_DIR/titlebars.lua"

  # The override wraps calls Omarchy makes from default.hypr.toggles, so it has
  # to be required before that line.
  config="$HYPR_DIR/hyprland.lua"
  if ! grep -q '^require("hypr.titlebars")' "$config"; then
    grep -q '^require("default.hypr.toggles")' "$config" ||
      fail "can't find require(\"default.hypr.toggles\") in $config; add require(\"hypr.titlebars\") before it by hand"
    cp "$config" "$HYPR_DIR/.hyprland.lua.bak.$STAMP"
    sed -i 's/^require("default.hypr.toggles")/require("hypr.titlebars")\n\n&/' "$config"
  fi
fi

say "Reloading"
(( titlebars )) && hyprctl reload >/dev/null
omarchy restart shell >/dev/null 2>&1 || true

if (( titlebars )); then
  errors="$(hyprctl configerrors)"
  [[ -z ${errors//[[:space:]]/} ]] || fail "Hyprland reported config errors:\n$errors"
fi

say "Done."
