-- Append to the end of ~/.config/hypr/looknfeel.lua.
-- Keep the T-3/T-4 main window centred from two windows up (the default waits for three).
hl.config({
  master = {
    slave_count_for_center_master = 0,
  },
})
