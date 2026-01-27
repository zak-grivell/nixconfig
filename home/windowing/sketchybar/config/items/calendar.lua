local settings = require("helpers.settings")
local colors = require("helpers.colors")

-- Padding item required because of bracket

local cal = sbar.add("item", "calendar", {
    icon = {
        padding_left = 0,
    },
    label = {
        padding_right = 20,
        align = "right",
    },
    position = "right",
    update_freq = 30,
    padding_left = 0,
    padding_right = 0,
})

cal:subscribe({ "forced", "routine", "system_woke" }, function(env)
    cal:set({ icon = os.date("%a %d %b"), label = os.date("%H:%M") })
end)
