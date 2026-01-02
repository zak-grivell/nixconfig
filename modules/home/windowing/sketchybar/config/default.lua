local settings = require("helpers.settings")
local colors = require("helpers.colors")

sbar.default({
    updates = "when_shown",
    icon = {
        font = {
            family = settings.font.text,
            style = settings.font.style_map["Bold"],
            size = 14.0
        },
        color = colors.text,
        padding_left = settings.paddings,
        padding_right = settings.paddings,
        background = { image = { corner_radius = 9 } },
    },
    label = {
        font = {
            family = settings.font.text,
            style = settings.font.style_map["Semibold"],
            size = 14.0
        },
        color = colors.text,
        padding_left = settings.paddings,
        padding_right = settings.paddings,
    },
    background = {
        height = 25,
        corner_radius = 15,
        border_width = 2,
        -- border_color = colors.bg2,
        image = {
            corner_radius = 9,
            border_color = colors.grey,
            border_width = 1
        }
    },
    popup = {
        background = {
            border_width = 2,
            corner_radius = 9,
            border_color = colors.popup.border,
            color = colors.popup.bg,
            shadow = { drawing = true },
        },
        blur_radius = 50,
    },
    padding_left = 10,
    padding_right = 10,
    scroll_texts = true,
})
