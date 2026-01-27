local function dump(o, n)
    if n == nil then n = 0 end

    local indent = string.rep("  ", n)
    if type(o) == 'table' then
        local s = '{\n'
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. indent .. '  [' .. k .. '] = ' .. dump(v, n + 1) .. ',\n'
        end
        return s .. indent .. '}'
    else
        return tostring(o)
    end
end

-- local lightColors = {
--     red = 0xFFFF3B30,
--     orange = 0xFFFF9500,
--     yellow = 0xFFFFCC00,
--     green = 0xFF28CD41,
--     mint = 0xFF00C7BE,
--     teal = 0xFF59ADC4,
--     cyan = 0xFF55BEF0,
--     blue = 0xFF007AFF,
--     indigo = 0xFF5856D6,
--     purple = 0xFFAF52DE,
--     pink = 0xFFFF2D55,
--     brown = 0xFFA2845E,
--     gray = 0xFF8E8E93
-- }

local function with_alpha(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then return color end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
end


local lightColors = {
    rosewater = 0xffdc8a78,
    flamingo = 0xffdd7878,
    pink = 0xffea76cb,
    mauve = 0xff8839ef,
    red = 0xffd20f39,
    maroon = 0xffe64553,
    peach = 0xfffe640b,
    yellow = 0xffdf8e1d,
    green = 0xff40a02b,
    teal = 0xff179299,
    sky = 0xff04a5e5,
    sapphire = 0xff209fb5,
    blue = 0xff1e66f5,
    lavender = 0xff7287fd,
    text = 0xffebf2f2,
    subtext1 = 0xff5c5f77,
    subtext0 = 0xff6c6f85,
    overlay2 = 0xff7c7f93,
    overlay1 = 0xff8c8fa1,
    overlay0 = 0xff9ca0b0,
    surface2 = 0xffacb0be,
    surface1 = 0xffbcc0cc,
    surface0 = 0xffccd0da,
    base = 0xffebf2f2,
    mantle = 0xffe6e9ef,
    crust = 0xffdce0e8,

    bar = {
        bg = 0x33000000,
        border = 0x00000000,
    },
    popup = {
        bg = 0xecffffff,
        border = 0xecffffff
    },
    background = 0xffeff1f5,
    background_unfocused = 0xffccd0da,
    foreground = 0xff4c4f69,
}



-- local darkColors = {
-- red = 0xFFFF453A,
-- orange = 0xFFFF9F0A,
-- yellow = 0xFFFFD60A,
-- green = 0xFF32D74B,
-- mint = 0xFF66D4CF,
-- teal = 0xFF6AC4DC,
-- cyan = 0xFF5AC8F5,
-- blue = 0xFF0A84FF,
-- indigo = 0xFF5E5CE6,
-- purple = 0xFFBF5AF2,
-- pink = 0xFFFF375F,
-- brown = 0xFFAC8E68,
-- gray = 0xFF98989D
-- }

local darkColors = {
    rosewater = 0xfff2d5cf,
    flamingo = 0xffeebebe,
    pink = 0xfff4b8e4,
    mauve = 0xffca9ee6,
    red = 0xffe78284,
    maroon = 0xffea999c,
    peach = 0xffef9f76,
    yellow = 0xffe5c890,
    green = 0xffa6d189,
    teal = 0xff81c8be,
    sky = 0xff99d1db,
    sapphire = 0xff85c1dc,
    blue = 0xff8caaee,
    lavender = 0xffbabbf1,
    text = 0xffebf2f2,
    subtext1 = 0xffb5bfe2,
    subtext0 = 0xffa5adce,
    overlay2 = 0xff949cbb,
    overlay1 = 0xff838ba7,
    overlay0 = 0xff737994,
    surface2 = 0xff626880,
    surface1 = 0xff51576d,
    surface0 = 0xff414559,
    base = 0xff303446,
    mantle = 0xff292c3c,
    crust = 0xff232634,

    bar = {
        bg = 0x33000000,
        border = 0x00000000,
    },
    popup = {
        bg = 0xec000000,
        border = 0x00000000
    },

    background = 0xff303446,
    background_unfocused = 0xff414559,
    foreground = 0xffc6d0f5,
}

local function is_dark_mode()
    local handle = io.popen([[/bin/bash -c 'osascript <<EOF
                                                           tell application "System Events"
                                                               tell appearance preferences
                                                                   set dark_mode to dark mode
                                                               end tell
                                                           end tell

                                                           if dark_mode then
                                                               return "Dark"
                                                           else
                                                               return "Light"
                                                           end if
                                                           EOF']])
    if handle == nil then
        print('Error opening pipe')
        return
    end

    local result = handle:read("*a")
    handle:close()

    print(result)

    if result ~= '' then
        return true
    elseif result == '' then
        return false
    else
        return nil
    end
end

local wasDarkMode = nil

-- Modifies just the alpha component of a 0xAARRGGBB color
local function set_opacity(color, new_opacity)
    -- Clamp the opacity between 0 and 255
    new_opacity = math.max(0, math.min(new_opacity, 255))
    -- Strip out the old alpha, keep the RGB
    local rgb = color & 0x00FFFFFF
    -- Add the new alpha in the high byte
    return (new_opacity << 24) | rgb
end

-- Recursively traverse a table and update AARRGGBB values with new opacity
function apply_opacity_recursive(tbl, new_opacity)
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            apply_opacity_recursive(v, new_opacity)
        else
            tbl[k] = set_opacity(v, new_opacity)
        end
    end
    return tbl
end

local opacity = 200;

local colors = apply_opacity_recursive(lightColors, opacity);

sbar.exec('sketchybar --add event theme_change AppleInterfaceThemeChangedNotification', function(d)
    local watcher = sbar.add('item', 'color_watcher', {
        drawing = true,
        icon = {
            drawing = false
        },
        label = {
            drawing = false
        },
        background = {
            drawing = false
        },
        padding_right = 0,
        padding_left = 0,
        width = 0
    })

    watcher:subscribe("system_woke", function(env)
        -- print('eeee', dump(env))
        -- sbar.exec('defaults read -g AppleInterfaceStyle 2>/dev/null && echo "Dark Mode" || echo "Light Mode"', function(output)
        --     if output == 'Dark Mode' then
        --         colors = darkColors
        --     else
        --         colors = lightColors
        --     end
        -- end)

        if is_dark_mode() ~= wasDarkMode then
            print('restating')

            sbar.exec('sketchybar --reload')
        end
        -- os.exec('sketchybar --update')
    end)

    watcher:subscribe('theme_change', function(env)
        -- print('eeee', dump(env))
        -- sbar.exec('defaults read -g AppleInterfaceStyle 2>/dev/null && echo "Dark Mode" || echo "Light Mode"', function(output)
        --     if output == 'Dark Mode' then
        --         colors = darkColors
        --     else
        --         colors = lightColors
        --     end
        -- end)
        print('restating')

        sbar.exec('sketchybar --reload')
        -- os.exec('sketchybar --update')
    end)
end)



if is_dark_mode() then
    colors = apply_opacity_recursive(darkColors, opacity)
    wasDarkMode = true
else
    colors = apply_opacity_recursive(lightColors, opacity)
    print(colors)
    wasDarkMode = false
end


return colors
