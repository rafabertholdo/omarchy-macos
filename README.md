# macOS Dock for Omarchy

A macOS-style dock for [Omarchy](https://omarchy.org) 4.5+, with optional
macOS-style titlebars.

- Shown on every workspace, not only floating ones, on a rounded,
  theme-coloured panel.
- Reserves its screen edge, so maximized and tiled windows stop above it
  instead of sliding under it.
- Pinned apps come first and are drawn in full; click one to launch it.
- Open apps that aren't pinned follow a separator, and running apps get a dot.
- Downloads and the Trash sit at the trailing end, after another separator.
  The Trash icon fills up when there is something in it, and a click opens it
  in Files.

Everything else works as in Omarchy's own dock: drag to reorder or pin,
right-click for app actions, and the apps button for every app. Its position
and auto-hide are set with `omarchy dock` or under _Appearance > Dock_.

## Requirements

- Omarchy 4.5 or newer. The dock first shipped in 4.5, and this plugin uses
  Omarchy's app library from `/usr/share/omarchy/shell/services`.
- `xdg-open` and `gio` (both part of Omarchy) to open Downloads and the Trash.

## Install

```bash
omarchy plugin add https://github.com/rafabertholdo/omarchy-macos --enable
omarchy plugin disable omarchy.dock
```

The second command turns off Omarchy's own dock, which would otherwise show
alongside this one. To update: `omarchy plugin update io.github.rafabertholdo.macos-dock`.

## Remove

```bash
omarchy plugin remove io.github.rafabertholdo.macos-dock
omarchy plugin enable omarchy.dock
```

## Optional: macOS-style titlebars

Floating workspaces get titlebars from Omarchy. `hypr/titlebars.lua` turns
them into macOS-style ones: red, yellow, and green buttons (close, minimize,
maximize) on the leading side, with icons on hover and a centred title. It is
Hyprland config rather than part of the plugin, so it is only installed when
you ask for it, from a checkout:

```bash
git clone https://github.com/rafabertholdo/omarchy-macos ~/Developer/omarchy-macos
~/Developer/omarchy-macos/install.sh --titlebars
```

`install.sh` symlinks the plugin from the checkout in place of
`omarchy plugin add`, replaces Omarchy's dock, and pins the apps listed in
`dock-pins.txt`. With `--titlebars` it also links `hypr/titlebars.lua` into
`~/.config/hypr/` and adds `require("hypr.titlebars")` to `hyprland.lua`.
Anything it replaces is backed up next to the original as a hidden
`.<name>.bak.<time>`. `./uninstall.sh` undoes it.

After editing a symlinked checkout, run `omarchy restart shell`: the shell
doesn't hot-reload a plugin through a symlink.

## How it works

The plugin started as `omarchy plugin clone omarchy.dock`. Third-party plugins
get a scoped shell without the shell config or the app library, so `Dock.qml`
reads `~/.config/omarchy/shell.json` itself and creates its own `AppLibrary`.
Changes to the look and behaviour are in `DockWindow.qml`.

`hypr/titlebars.lua` wraps `hl.config` and the titlebars plugin's
`add_button`, both called from Omarchy's `default/hypr/workspace-modes.lua`,
and adjusts the alignment, colours, and button order on the way through.

Both lean on Omarchy internals, so an Omarchy update can break them. If the
dock disappears after one, compare it with
`/usr/share/omarchy/shell/plugins/dock/`.

## License

MIT. The dock is a modified copy of Omarchy's dock plugin, also MIT; see
[LICENSE](LICENSE).
