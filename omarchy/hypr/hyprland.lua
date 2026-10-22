-- Append to the end of ~/.config/hypr/hyprland.lua.
-- Loads the per-workspace rules saved by tile-mode. Keep it last, so they win over
-- earlier rules for the same workspace (such as the SUPER+L layout toggle).
local tile_mode_dir = (os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")) .. "/tile-mode"
local tile_mode_files = io.popen("find '" .. tile_mode_dir .. "' -maxdepth 1 -type f -name '*.lua' 2>/dev/null | sort")
if tile_mode_files then
  for file in tile_mode_files:lines() do
    dofile(file)
  end
  tile_mode_files:close()
end
