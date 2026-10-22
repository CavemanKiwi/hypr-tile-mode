-- Append to the end of ~/.config/hypr/bindings.lua.
-- Per-workspace tiling modes: T-1 default, T-2 2/3 | 1/3, T-3 1/3 | 1/3 | 1/3, T-4 1/5 | 3/5 | 1/5.
-- Replaces Omarchy's SUPER+ALT+1/2/3/4 "Switch to group window N". Also bound to SUPER+ALT+keypad 1-4.
local tile_mode_keypad = { 87, 88, 89, 83 }
for mode = 1, 4 do
  hl.unbind("SUPER + ALT + code:" .. tostring(mode + 9))
  o.bind("SUPER + ALT + " .. mode, "Tiling mode T-" .. mode, "tile-mode " .. mode)
  o.bind("SUPER + ALT + code:" .. tile_mode_keypad[mode], "Tiling mode T-" .. mode .. " (keypad)", "tile-mode " .. mode)
end
