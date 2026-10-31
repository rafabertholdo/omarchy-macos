# omarchy-macos

A macOS-style dock and titlebars for [Omarchy](https://omarchy.org) 4.5+.

- **Dock**: shown on every workspace, not only floating ones, on a rounded,
  theme-coloured panel. It reserves its screen edge, so maximized and tiled
  windows stop above it. Pinned apps are drawn in full and launch on click, and
  running apps get a dot.
- **Titlebars**: red, yellow, and green buttons (close, minimize, maximize) on
  the leading side, with icons on hover and a centred title. Titlebars show on
  floating workspaces; `Super + L` cycles a workspace's layout.

## Install

```bash
git clone https://github.com/rafabertholdo/omarchy-macos.git ~/Developer/omarchy-macos
~/Developer/omarchy-macos/install.sh
```

The installer symlinks everything from the checkout, so to update:

```bash
git -C ~/Developer/omarchy-macos pull
```

It replaces Omarchy's `omarchy.dock` with this repo's `rafabertholdo.dock`,
links `hypr/titlebars.lua` into `~/.config/hypr/` and requires it from
`hyprland.lua`, and pins the apps listed in `dock-pins.txt`. Anything it
replaces is backed up next to the original as a hidden `.<name>.bak.<time>`.

To undo it: `./uninstall.sh`.

## How it works

`dock/` started as `omarchy plugin clone omarchy.dock`. A cloned plugin gets a
scoped shell without the shell config or the app library, so `Dock.qml` reads
`~/.config/omarchy/shell.json` itself and creates its own `AppLibrary` from
`/usr/share/omarchy/shell/services`. Changes to the look and behaviour are in
`DockWindow.qml`.

`hypr/titlebars.lua` wraps `hl.config` and the titlebars plugin's `add_button`,
both called from Omarchy's `default/hypr/workspace-modes.lua`, and adjusts the
alignment, colours, and button order on the way through.

Both lean on Omarchy internals, so an Omarchy update can break them. If the
dock disappears after one, compare `dock/` with
`/usr/share/omarchy/shell/plugins/dock/`.
