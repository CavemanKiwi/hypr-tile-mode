# hypr-tile-mode

One keypress combo per tiling layout, saved per Hyprland workspace.

| Key Combo | Mode | Layout |
|---|---|---|
| SUPER+ALT+1 | T-1 | Your default layout (e.g. dwindle) |
| SUPER+ALT+2 | T-2 | Main window 2/3 on the left, others stacked in the right 1/3 |
| SUPER+ALT+3 | T-3 | 1/3 · main window 1/3 in the centre · 1/3 |
| SUPER+ALT+4 | T-4 | 1/5 · main window 3/5 in the centre · 1/5 |

Each workspace keeps its own mode across reloads and restarts, so you can have a focus layout on one workspace and a normal layout on the next.

The exact splits for T-3 and T-4 need three windows. With two, the main window stays centred and one side is empty. With four or more, the extra windows stack in the side columns.

## How it works

It is mostly plain Hyprland: the `master` layout with `orientation:left` (T-2) or `orientation:center` (T-3/T-4), and `layoutmsg mfact exact` for the width (0.6667, 0.3333 or 0.6). The `tile-mode` script adds three things:

1. **Per-workspace state.** It saves each workspace's mode in `~/.local/state/tile-mode/` along with a workspace rule, then reloads Hyprland. Your config loads the saved rules last, so they win over earlier rules for the same workspace. T-1 removes the rule.
2. **Width.** After the reload it sets `mfact` on the focused workspace.
3. **Watcher.** `tile-mode watch` listens on Hyprland's event socket. When a window opens it sets the width again, because a new main window starts at the default width. On a workspace or monitor switch it sets it once per mode change, so manual resizes stick.

## Requirements

- Hyprland with the `master` layout
- `jq` and `socat`
- Optional: `notify-send` for a notification on each change

Tested on Hyprland 0.56.2 with Omarchy's Lua config. The classic `hyprland.conf` setup uses the same layout and dispatcher but has not been tested yet. Reports welcome.

## Install

Put the script on your `PATH`:

```bash
install -Dm755 tile-mode ~/.local/bin/tile-mode
```

The script detects your config format: `~/.config/hypr/hyprland.lua` means Lua, otherwise `hyprland.conf`. Set `TILE_MODE_SYNTAX=lua` or `TILE_MODE_SYNTAX=conf` to override.

### Classic hyprland.conf

```bash
mkdir -p ~/.local/state/tile-mode && touch ~/.local/state/tile-mode/rules.conf
```

Then add the lines from [`hyprland.conf.example`](hyprland.conf.example) to `~/.config/hypr/hyprland.conf`, with the `source` line last, and log out and back in (or run `hyprctl reload` and start `tile-mode watch &`).

### Omarchy (Lua config)

Append each file in [`omarchy/hypr/`](omarchy/hypr) to the file of the same name in `~/.config/hypr/`. On Omarchy, SUPER+ALT+1–4 switch group windows by default; `bindings.lua` replaces those bindings and also binds SUPER+ALT+keypad 1–4.

Optional bar label: copy the plugin and enable it. It shows `T-N` for each monitor's workspace, and clicking it cycles the mode.

```bash
cp -r omarchy/plugin/caveman.tile-mode ~/.config/omarchy/plugins/
omarchy plugin enable caveman.tile-mode
```

## Usage

```
tile-mode 1|2|3|4 [--workspace ID]  set the mode (focused workspace by default)
tile-mode next [--workspace ID]     cycle to the next mode
tile-mode status [--workspace ID]   print the mode as T-N
tile-mode watch                     keep split widths applied (run at startup)
```

### Waybar

```json
"custom/tile-mode": {
  "exec": "tile-mode status",
  "interval": 1,
  "on-click": "tile-mode next"
}
```

## Uninstall

Remove the lines you added to your Hyprland config, then:

```bash
pkill -f "tile-mode watch"
rm -rf ~/.local/bin/tile-mode ~/.local/state/tile-mode
hyprctl reload
```

On Omarchy, also run `omarchy plugin disable caveman.tile-mode` and remove `~/.config/omarchy/plugins/caveman.tile-mode`.

## License

MIT
