---@meta _
local mods = rom.mods
mods['LuaENVY-ENVY'].auto()

local folder = _PLUGIN.plugins_mod_folder_path
package.cpath = folder .. "/?.dll;" .. package.cpath
package.path = folder .. "/?.lua;" .. package.path

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

-- Shared Context
local mod_context = {
    config = config,
    rom = rom,
    game = game,
    _PLUGIN = _PLUGIN,
    modutil = modutil,
    sjson = sjson,
    chalk = chalk
}

local function run_script(filename)
    local chunk, err = loadfile(folder .. "/" .. filename)
    if not chunk then
        print("[Hades2MP] Error loading " .. filename .. ": " .. tostring(err))
        return
    end
    
    local env = setmetatable({}, {
        __index = function(t, k)
            return mod_context[k] or _G[k]
        end,
        __newindex = _G
    })
    
    if setfenv then setfenv(chunk, env) end
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

    return chunk()
end

local function on_ready()
    if config.enabled == false then return end
    
    mod = modutil.mod.Mod.Register(_PLUGIN.guid)
    
    -- [[ INJECTION POINT ]]
    -- We run the DataInjector immediately. 
    -- This ensures NetPuppet exists in the data tables before any game logic runs.
    local Injector = run_script("DataInjector.lua")
    if Injector then Injector(game) end
    
    run_script("ready.lua")
end

local function on_reload()
    if config.enabled == false then return end
    
    -- Re-inject on reload to ensure definitions persist
    local Injector = run_script("DataInjector.lua")
    if Injector then Injector(game) end

    run_script("reload.lua")
end

local loader = reload.auto_single()

modutil.once_loaded.game(function()
    loader.load(on_ready, on_reload)
end)