local colors = require("helpers.colors")

-- Equivalent to the --bar domain
sbar.bar({
    height = 40,
    -- color = colors.bar.bg,
    color = 0x00000000,
    padding_right = 5,
    padding_left = 5,
    margin = -2,
    font_smoothing=true,
    shadow = {
        drawing = true,
        angle = 0,
        distance = 200,
    }
})
