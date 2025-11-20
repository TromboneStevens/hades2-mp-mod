---@meta _
local mods = rom.mods
mods['LuaENVY-ENVY'].auto()

-- Point to our folder
local folder = _PLUGIN.plugins_mod_folder_path
package.cpath = folder .. "/?.dll;" .. package.cpath

-- Load ENet
local status, lib = pcall(require, "enet")

if not status then
    print("[Hades2MP] CRITICAL: " .. tostring(lib))
    return
end

public.enet = lib
public.enet.initialize()
print("[Hades2MP] ENet Loaded Successfully.")

-- 2. STANDARD MOD LOADER BOILERPLATE
rom = rom
_PLUGIN = _PLUGIN
game = rom.game
import_as_fallback(game)

sjson = mods['SGG_Modding-SJSON']
modutil = mods['SGG_Modding-ModUtil']
chalk = mods["SGG_Modding-Chalk"]
reload = mods['SGG_Modding-ReLoad']

config = chalk.auto 'config.lua'
public.config = config 

local function on_ready()
    if config.enabled == false then return end
    mod = modutil.mod.Mod.Register(_PLUGIN.guid)
    import 'ready.lua'
end

local function on_reload()
    if config.enabled == false then return end
    import 'reload.lua'
end

local loader = reload.auto_single()

modutil.once_loaded.game(function()
    loader.load(on_ready, on_reload)
end)