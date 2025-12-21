local colors = require("colors")


local function withHeight(callback)
    sbar.exec([[osascript -e 'tell application "Finder" to get bounds of window of desktop']], function(result)
        print(result)
        local _, _, x1, y1, x2, y2 = string.find(result, "(%d+), (%d+), (%d+), (%d+)")
        local height = tonumber(y2) - tonumber(y1)
        callback(height)
    end)
    -- local handle = io.popen([[osascript -e 'tell application "Finder" to get bounds of window of desktopy']])

    -- if handle == nil then
    -- return 0
    -- end

    -- local result = chandle:read("*a")
    -- handle:close()

    -- The result is something like: "0, 0, 1440, 900"
end

local modes = {
    main = {
        color = 'sky',
        name = 'I',
        items = nil,
    },
    normal = {
        color = 'lavender',
        name = 'N',
        items = {
            { bind = 'm', action = 'mode move' },
            { bind = 'w', action = 'mode workspace' },
            { bind = 'r', action = 'mode relocate' },
            { bind = 's', action = 'mode send' },
            { bind = 'c', action = 'mode config' },

            { bind = 'h', action = 'focus left' },
            { bind = 'j', action = 'focus down' },
            { bind = 'k', action = 'focus up' },
            { bind = 'l', action = 'focus right' },

            { bind = 'f', action = 'fullscreen' },

            { bind = 't', action = 'terminal' },
            { bind = 'b', action = 'browser' },
            { bind = 'n', action = 'notes' },
            { bind = 'd', action = 'finder' },
            { bind = 'e', action = 'editor' },

            { bind = '⏎', action = 'quick terminal' },

            { bind = 'u', action = 'undock' },
            { bind = '-', action = 'shrink' },
            { bind = '+', action = 'grow' },
        }
    },
    move = {
        color = 'lavender',
        name = 'M',
        items = {
            { bind = 'h', action = 'move left' },
            { bind = 'j', action = 'move down' },
            { bind = 'k', action = 'move up' },
            { bind = 'l', action = 'move right' },
        }
    },
    workspace = {
        color = 'rosewater',
        name = 'W',
        items = {
            { bind = 'j',    action = 'workspace previous' },
            { bind = 'k',    action = 'workspace next' },
            { bind = '1..9', action = 'workspace 1..9' },
        }
    },
    relocate = {
        color = "pink",
        name = 'R',
        items = {
            { bind = 'j',    action = 'relocate previous' },
            { bind = 'k',    action = 'relocate next' },
            { bind = '1..9', action = 'relocate 1..9' },
        }
    },
    send = {
        color = "peach",
        name = 'S',
        items = {
            { bind = 'j',    action = 'send to previous' },
            { bind = 'k',    action = 'send to  next' },
            { bind = '1..9', action = 'send to 1..9' },
        }
    },
    config = {
        color = 'yellow',
        name = 'C',
        items = {
            { bind = 'r', action = 'reload aerospace config' },
            { bind = 'a', action = 'accordian layout' },
            { bind = 't', action = 'tiles layout' },
            { bind = 's', action = 'reload sketchybar' },
        }
    }
}
local mode_idicator = sbar.add("item", 'mode_indicator', {
    icon = {
        drawing = false
    },
    label = {
        drawing = true,
        string = 'I',
        font = { style = 'bold' },
        color = colors.base,
        width = 35,
        align = 'center'
    },
    background = {
        drawing = true,
        border_width = 0,
        color = colors[modes.main.color],
    },
    popup = {
        height = 20,
        drawing = true,
        y_offset = 0,
        background = {
            color = colors.mantle,
            border_width = 0
        },
    }
})

local breadcrumbs = {}
local num_on_availible = 30
local function get_number_of_items(items)
    if not items then return 0 end
    return #items
end

local start = sbar.add('item', 'breadcrumbs.start', {
    position = 'popup.' .. mode_idicator.name,
    drawing = false,
})

for i = 0, num_on_availible + 1 do
    breadcrumbs[i] = sbar.add('item', 'breadcrumbs.' .. i, {
        position = "popup." .. mode_idicator.name,
        label = { string = "NOT SHOWN", padding_left = 20 },
        drawing = false,
        padding_left = 20,
        padding_right = 20
    })
end


local end_item = sbar.add('item', 'breadcrumbs.end', {
    position = 'popup.' .. mode_idicator.name,
    drawing = false,
})

withHeight(function(height)
    mode_idicator:subscribe('aerospace_mode_change', function(env)
        local mode = modes[env.MODE]

        mode_idicator:set({
            label = {
                string = mode.name,
            },
            background = {
                color = colors[mode.color]
            },
        })

        -- mode_idicator:set({
        --     popup = {
        --         drawing = mode.items ~= nil,
        --         -- y_offset = (getScreenHeight() - (get_number_of_items(mode.items) * 60) - (get_number_of_items(mode.items) - 1) * 10)
        --         y_offset = height - (20 * get_number_of_items(mode.items) + 80 + 40),
        --     },

        -- })

        -- if not mode.items then return end

        -- start:set({ drawing = true })
        -- end_item:set({ drawing = true })

        -- for k, obj in ipairs(mode.items) do
        --     breadcrumbs[k]:set({
        --         icon = obj.bind,
        --         -- label = obj.action,
        --         drawing = true,
        --         label = {
        --             string = obj.action,
        --         }
        --     }
        --     )
        -- end

        -- for j = #mode.items + 1, num_on_availible do
        --     breadcrumbs[j]:set({ drawing = false })
        -- end

        -- print(get_number_of_items(mode.items),
        --   (getScreenHeight() - (get_number_of_items(mode.items) * 20) - (get_number_of_items(mode.items) - 1) * 0))



        -- breadcrumbs:set({
        --   label = table_to_kv_string(mode.items)
        -- })
    end)


    print(mode_idicator.name)
    print(height)
end)
