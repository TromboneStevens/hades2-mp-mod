---@meta _
local mods = rom.mods
mods.auto()
local ffi = require("ffi")

-- 1. Load Definitions
import 'enet_defs.lua'

-- 2. Resolve DLL Path
-- _PLUGIN.path ensures this works whether installed on Drive C, D, or via r2modman
local dll_path = _PLUGIN.path.. "/enet.dll" 

-- 3. Load the Library
-- We attach it to 'public' so other files (ready.lua) can access it
public.enet = ffi.load(dll_path)

-- 4. Initialize ENet (Must be done once per process)
if public.enet.enet_initialize() ~= 0 then
    print("FATAL: Failed to initialize ENet!")
else
    print("ENet Initialized Successfully.")
end

---@module 'LuaENVY-ENVY-auto'
mods['LuaENVY-ENVY'].auto()
-- ^ this gives us `public` and `import`, among others
--	and makes all globals we define private to this plugin.
---@diagnostic disable: lowercase-global

---@diagnostic disable-next-line: undefined-global
rom = rom
---@diagnostic disable-next-line: undefined-global
_PLUGIN = _PLUGIN

-- get definitions for the game's globals
---@module 'game'
game = rom.game
---@module 'game-import'
import_as_fallback(game)

---@module 'SGG_Modding-SJSON'
sjson = mods['SGG_Modding-SJSON']
---@module 'SGG_Modding-ModUtil'
modutil = mods['SGG_Modding-ModUtil']

---@module 'SGG_Modding-Chalk'
chalk = mods["SGG_Modding-Chalk"]
---@module 'SGG_Modding-ReLoad'
reload = mods['SGG_Modding-ReLoad']

---@module 'config'
config = chalk.auto 'config.lua'
-- ^ this updates our `.cfg` file in the config folder!
public.config = config -- so other mods can access our config

local function on_ready()
	-- what to do when we are ready, but not re-do on reload.
	if config.enabled == false then return end
	mod = modutil.mod.Mod.Register(_PLUGIN.guid)

	import 'ready.lua'
end

local function on_reload()
	-- what to do when we are ready, but also again on every reload.
	-- only do things that are safe to run over and over.
	if config.enabled == false then return end

	import 'reload.lua'
end

-- this allows us to limit certain functions to not be reloaded.
local loader = reload.auto_single()

-- this runs only when modutil and the game's lua is ready
modutil.once_loaded.game(function()
	loader.load(on_ready, on_reload)
end)
