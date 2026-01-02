-- items/workspaces.lua
local colors = require("helpers.colors")

local Aerospace = require("helpers.aerospace")
local aerospace = Aerospace.new() -- it finds socket on its own
while not aerospace:is_initialized() do
    os.execute("sleep 0.1")       -- wait for connection, not the best workaround, i am not a lua professional
end

-- Add padding to the left
local watcher = sbar.add("item", {
    icon = {
        drawing = false,
    },
    label = {
        drawing = false,
    },
    background = {
        drawing = false,
    },
    padding_left = 0,
    padding_right = 0,
})

local hide_apps = {}

---@alias app_id string
---@alias workspace_id string

---@class app
---@field name string
---@field icon string
---@field id app_id
---@field workspace workspace_id

---@alias apps { [app_id]: app }

---@param callback fun(workspaces: {[app_id]: app})
local function withApps(callback)
    aerospace:list_all_windows(function(workspace_and_windows)
        ---@type app[]
        local apps = {}
        for _, entry in ipairs(workspace_and_windows) do
            ---@type app
            local app = {
                name = entry["app-name"],
                icon = entry['app-bundle-id'],
                id = tostring(math.tointeger(entry
                    ['window-id'])),
                workspace = entry.workspace
            }

            if hide_apps[app.name] then return end

            apps[app.id] = app
        end
        callback(apps)
    end)
end

---@class item
---@field name string
---@field set fun(self: item, properties: table)
---@field push fun(self: item, properties: table)
---@field query fun(self: item, properties: table)
---@field subscribe fun(self: item, properties: table)


---@type { [app_id]: app}
local previous_state = {}

---@type { [string]: any }
local spacer_items = {}

---@type { [string]: item }
local app_items = {}

---@param app_item item
local function moveApp(app_item, spacer_item)
    if spacer_item ~= nil and app_item ~= nil then
        sbar.exec('sketchybar --move ' .. app_item.name .. ' after ' .. spacer_item.name)
    end
end

---@param app app
local function addApp(app)
    local app_item = sbar.add("item", 'app.' .. app.id, {
        display = "active",
        icon = { drawing = false },
        label = {
            string = app.name,
            drawing = false,
            padding_left = 40,
            padding_right = 5,
            color = colors.foreground,
            width = 0
        },
        background = {
            drawing = true,
            image = {
                scale = 1,
                border_width = 0,
                string = 'app.' .. app.icon,
                padding_left = 0,
                padding_right = 0,
            },
        },

        padding_left = 0,
        padding_right = 0,
        updates = true,
        click_script = 'aerospace focus --window-id ' .. app.id
    })

    app_items[app.id] = app_item

    moveApp(app_item, spacer_items[app.workspace])
end


local function removeApp(id, app)
    sbar.remove(app)
    app_items[id] = nil
end

local lastFocus = nil

local function updateFocusedApp()
    aerospace:focused_window(function(output)
        for _, value in ipairs(output) do
            local app_id = tostring(math.tointeger(value['window-id']))

            if app_id and app_items[app_id] then
                app_items[app_id]:set(
                    { label = { drawing = true } }
                )
            end

            sbar.animate('sin', 20, function()
                if app_id and app_items[app_id] then
                    app_items[app_id]:set(
                        { label = { width = 'dynamic' } }
                    )
                end

                if lastFocus and app_items[lastFocus] and lastFocus ~= app_id then
                    app_items[lastFocus]:set(
                        { label = { width = 0 } }
                    )
                end
                lastFocus = app_id
            end)

            if lastFocus and app_items[lastFocus] and lastFocus ~= app_id then
                app_items[lastFocus]:set(
                    { label = { drawing = false } }
                )
            end
        end
    end)
end

local function workspaceAppList(apps)
    local app_workspaces = {}

    for _, app in pairs(apps) do
        if not app_workspaces[app.workspace] then
            app_workspaces[app.workspace] = {}
        end

        app_workspaces[app.workspace][#app_workspaces[app.workspace] + 1] = app.id
    end

    return app_workspaces
end

local function create_divider(workspace_id, show_divider)
    spacer_items[workspace_id] = sbar.add("item", "spacer." .. workspace_id, {
        drawing = false,
        icon = show_divider and '|' or '',
        padding_left = 5,
        padding_right = 1,
    })
end

local function checkWorkspace(workspace_id, apps)
    spacer_items[workspace_id]:set(
        { drawing = apps and #apps > 0}
    )
end

local last_workspaces = {};

local function updateWorkspaces()
    withApps(function(apps)
        local app_workspaces = workspaceAppList(apps)

        for old_space, _ in pairs(last_workspaces) do
            if not app_workspaces[old_space] then
                checkWorkspace(old_space, {})
            end
        end

        for workspace, num in pairs(app_workspaces) do
            if not last_workspaces[workspace] then
                checkWorkspace(workspace, num)
            end
        end

        for _, app in pairs(apps) do
            if not previous_state[app.id] then
                addApp(app)
            elseif previous_state[app.id].workspace ~= app.workspace then
                moveApp(app_items[app.id], spacer_items[app.workspace])
            end
        end

        for id, app in pairs(app_items) do
            if not apps[id] then
                removeApp(id, app)
            end
        end

        previous_state = apps
        last_workspaces = app_workspaces
    end)
end

for i = 1, 20, 1 do
  create_divider(tostring(i), i~=1)
end

updateWorkspaces()

watcher:subscribe("aerospace_focus_change", function()
    updateWorkspaces()
    updateFocusedApp()
end)

watcher:subscribe("display_change", function()
    updateWorkspaces()
    updateFocusedApp()
end)
