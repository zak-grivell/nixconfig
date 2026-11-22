hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "auto",
})

hl.config({
    general = {
        layout = "monocle",
        gaps_in = 0,
        gaps_out = 0,
        border_size = 0,
    },
    decoration = {
        rounding = 0,
    },
    input = {
        kb_layout = "gb",
        kb_options = "caps:escape",
        follow_mouse = 0,
    },
})

local next_window = hl.dsp.layout("cyclenext")
local previous_window = hl.dsp.layout("cycleprev")
hl.bind("ALT + Tab", next_window)
hl.bind("ALT + SHIFT + Tab", previous_window)
hl.bind("ALT + O", next_window)
hl.bind("ALT + I", previous_window)
hl.bind("ALT + X", hl.dsp.window.close())

hl.bind("ALT + T", hl.dsp.exec_cmd("ghostty"))
hl.bind("ALT + B", hl.dsp.exec_cmd("zen-beta"))
hl.bind("ALT + D", hl.dsp.exec_cmd("thunar"))
hl.bind("ALT + E", hl.dsp.exec_cmd("zeditor"))
hl.bind("SUPER + Space", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind("SUPER + SHIFT + Q", hl.dsp.exit())

for workspace = 1, 9 do
    hl.bind("ALT + " .. workspace, hl.dsp.focus({ workspace = workspace }))
    hl.bind("ALT + SHIFT + " .. workspace, hl.dsp.window.move({ workspace = workspace }))
end
