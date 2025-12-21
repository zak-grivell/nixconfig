return {
    paddings = 5,
    group_paddings = 10,

    icons = "sf-symbols", -- alternatively available: NerdFont

    font = {
        text = "SF Pro",     -- Used for text
        numbers = "SF Mono", -- Used for numbers

        -- Unified font style map
        style_map = {
            ["Regular"] = "Regular",
            ["Semibold"] = "Semibold",
            ["Bold"] = "Bold",
            ["Heavy"] = "Heavy",
            ["Black"] = "Black",
        }
    }


    -- This is a font configuration for SF Pro and SF Mono (installed manually)
    -- font = 'JetBrainsMono Nerd Font:Medium'

    -- -- Alternatively, this is a font config for JetBrainsMono Nerd Font
    -- font = {
    --     text = "JetBrainsMono Nerd Font",    -- Used for text
    --     numbers = "JetBrainsMono Nerd Font", -- Used for numbers
    --     style_map = {
    --         ["Regular"] = "Regular",
    --         ["Semibold"] = "Medium",
    --         ["Bold"] = "SemiBold",
    --         ["Heavy"] = "Bold",
    --         ["Black"] = "ExtraBold",
    --     },
    --     size = 50.0
    -- },
}
