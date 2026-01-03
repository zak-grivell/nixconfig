local settings = require("helpers.settings")
local colors = require("helpers.colors")

-- Padding item required because of bracket

local cal = sbar.add("item", {
    icon = {
        padding_left = 15,
    },
    label = {
        padding_right = 20,
        align = "right",
    },
    position = "right",
    update_freq = 30,
    padding_left = 0,
    padding_right = 0,

    click_script =
    [[osascript -e 'tell application "System Events" to tell process "ControlCenter" to click menu bar item 1 of menu bar 1']]
})

sbar.add("item", { position = "right", width = settings.group_paddings })

cal:subscribe({ "forced", "routine", "system_woke" }, function(env)
    cal:set({ icon = os.date("%a %d %b"), label = os.date("%H:%M") })
end)

-- local time = sbar.add("item", {
--   icon = {
--     color = colors.foreground,
--     padding_left = 8,
--     font = {
--       style = settings.font.style_map["Black"],
--       size = 12.0,
--     },
--   },
--   label = {
--     color = colors.foreground,
--     padding_right = 8,
--     width = 49,
--     align = "right",
--     font = { family = settings.font.numbers },
--   },
--   position = "right",
--   update_freq = 30,
--   padding_left = 2,
--   padding_right = 2,
--   background = {
--     color = colors.background,
--     border_width = 1
--   },
--   click_script = "open -a 'Calendar'"
-- })

-- sbar.add("item", { position = "right", width = settings.group_paddings })
