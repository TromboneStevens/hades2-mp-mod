---@meta _
local mods = rom.mods
mods['LuaENVY-ENVY'].auto()

local folder = _PLUGIN.plugins_mod_folder_path
package.cpath = folder .. "/?.dll;" .. package.cpath
package.path = folder .. "/?.lua;" .. package.path

-- Load ENet
local status, lib = pcall(require, "enet")
if not status then
    print("[Hades2MP] CRITICAL: " .. tostring(lib))
    return
end

print("[Hades2MP] ENet Loaded. Library type: " .. type(lib))

-- Standard Loader
rom = rom
_PLUGIN = _PLUGIN
game = rom.game
import_as_fallback(game)

sjson = mods['SGG_Modding-SJSON']
modutil = mods['SGG_Modding-ModUtil']
chalk = mods["SGG_Modding-Chalk"]
reload = mods['SGG_Modding-ReLoad']

-- Config Setup
config = chalk.auto 'config.lua'

-- Prepare a shared context table to pass data safely
-- We use this instead of _G to avoid sandbox issues
local mod_context = {
    enet = lib,
    config = config,
    rom = rom,
    game = game,
    _PLUGIN = _PLUGIN
}

local function run_script(filename)
    -- Load the file as a chunk
    local chunk, err = loadfile(folder .. "/" .. filename)
    if not chunk then
        print("[Hades2MP] Error loading " .. filename .. ": " .. tostring(err))
        return
    end
    
    -- Create a custom environment for the script that inherits from _G
    -- but also has our mod_context variables injected directly.
    local env = setmetatable({}, {
        __index = function(t, k)
            return mod_context[k] or _G[k]
        end,
        __newindex = _G -- Writes go to global
    })
    
    -- Apply environment and run
    if setfenv then setfenv(chunk, env) end -- Lua 5.1 style (just in case)
    -- Lua 5.2+ style: the first upvalue of a chunk is _ENV
    local i = 1
    while true do
        local name = debug.getupvalue(chunk, i)
        if name == "_ENV" then
            debug.setupvalue(chunk, i, env)
            break
        elseif not name then
            break
        end
        i = i + 1
    end

    chunk()
end

local function on_ready()
    if config.enabled == false then return end
    mod = modutil.mod.Mod.Register(_PLUGIN.guid)
    run_script("ready.lua")
end

local function on_reload()
    if config.enabled == false then return end
    run_script("reload.lua")
end

local loader = reload.auto_single()

modutil.once_loaded.game(function()
    loader.load(on_ready, on_reload)
end)