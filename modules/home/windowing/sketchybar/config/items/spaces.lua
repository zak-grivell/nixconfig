-- items/workspaces.lua
local colors = require("colors")
local settings = require("settings")

local Aerospace = require("aerospace")
local aerospace = Aerospace.new() -- it finds socket on its own
while not aerospace:is_initialized() do
    os.execute("sleep 0.1")       -- wait for connection, not the best workaround, i am not a lua professional
end

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
---
---

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
        print('sketchybar --move ' .. app_item.name .. ' after ' .. spacer_item.name)
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

    print(app.name, app.workspace, app.id)

    moveApp(app_item, spacer_items[app.workspace])
end


local function removeApp(id, app)
    sbar.remove(app)
    app_items[id] = nil
end

local lastFocus = nil
local workspace_app_num = {}

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
        if app.workspace ~= 'temp' then
            if not app_workspaces[app.workspace] then
                app_workspaces[app.workspace] = {}
            end

            app_workspaces[app.workspace][#app_workspaces[app.workspace] + 1] = app.id
        end
    end

    return app_workspaces
end

local function create_divider(workspace_id)
    print(workspace_id)
    spacer_items[workspace_id] = sbar.add("item", "spacer." .. workspace_id, {
        drawing = false,
        icon = '|',
        -- icon = workspace_id,
        padding_left = 5,
        padding_right = 1,
    })

    -- local min_above = 10000;
    -- local ws_n = tonumber(workspace_id);

    -- for id, _ in pairs(spacer_items) do
    --     local n = tonumber(id)

    --     if n ~= nil and n > ws_n and n < min_above then
    --         min_above = n
    --     end
    -- end

    -- if min_above ~= 10000 then
    --     print("moving", spacer_items[workspace_id].name, "before", spacer_items[tostring(min_above)].name)
    --     sbar.exec('sketchybar --move ' ..
    --         spacer_items[workspace_id].name .. ' before ' .. spacer_items[tostring(min_above)].name)
    -- end
end

local function remove_divder(workspace_id)
    sbar.remove(spacer_items[workspace_id].name)
    spacer_items[workspace_id] = nil
end

local function checkWorkspace(workspace_id, apps)
    print("checking", workspace_id, apps,#apps, apps and #apps > 0)
    
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

        -- adds the new dividers
        for workspace, num in pairs(app_workspaces) do
            if not last_workspaces[workspace] then
                checkWorkspace(workspace, num)
            end
        end



        for _, app in pairs(apps) do
            if not previous_state[app.id] then
                print("appy", app.workspace_id)
                addApp(app)
                -- checkWorkspace(app.workspace, app_workspaces[app.workspace])
            elseif previous_state[app.id].workspace ~= app.workspace then
                moveApp(app_items[app.id], spacer_items[app.workspace])

                -- local prev = previous_state[app.id].workspace

                -- print("prev ", prev)

                -- checkWorkspace(app.workspace, app_workspaces[app.workspace])
                -- checkWorkspace(pUrev, app_workspaces[prev])
            end
        end

        for id, app in pairs(app_items) do
            if not apps[id] then
                -- checkWorkspace(app.workspace, app_workspaces[app.workspace])
                removeApp(id, app)
            end
        end

        previous_state = apps
        last_workspaces = app_workspaces
    end)
end

for i = 1, 20, 1 do
  create_divider(tostring(i))
end

create_divider("temp")

updateWorkspaces()

watcher:subscribe("aerospace_focus_change", function()
    updateWorkspaces()
    updateFocusedApp()
end)

watcher:subscribe("display_change", function()
    updateWorkspaces()
    updateFocusedApp()
end)
