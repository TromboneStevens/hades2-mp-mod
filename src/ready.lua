-- src/ready.lua
local function get_script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end
local folder = get_script_path()
-- Ensure src/ is in the path so we can require "Weapons.Staff" etc.
package.path = folder .. "?.lua;" .. folder .. "src/?.lua;" .. package.path

-- [[ DEPENDENCIES ]]
local NetworkManager = require("NetworkManager")()
local PlayerTrackerFactory = require("PlayerTracker")
local SetupHooks = require("Hooks")
local PuppetFactory = require("Puppet")

-- Pre-load the Animation Registry to catch syntax errors in Weapon files early
local AnimRegistry = require("AnimRegistry") 
print("[Hades2MP] Animation Registry Loaded with " .. (table.count and table.count(AnimRegistry.Data) or "multiple") .. " weapon definitions.")

-- [[ NETWORK INIT ]]
if config and config.mode == "host" then
    NetworkManager.Init("host", config.port or 7777)
else
    NetworkManager.Init("client", config.port or 7777)
    NetworkManager.Connect(config.target_ip or "127.0.0.1", config.port or 7777) 
    NetworkManager.SendString("HANDSHAKE:HELLO")
end

-- [[ MAP LOAD HOOK ]]
modutil.mod.Path.Wrap("SetupMap", function(base, ...)
    base(...) 
    
    thread(function()
        -- Wait for map assets to load
        wait(2.0)
        
        print("[Hades2MP] Map Loaded. Initializing Co-op Systems...")
        
        -- Initialize Systems
        local Puppet = PuppetFactory(game, modutil)
        local PlayerTracker = PlayerTrackerFactory(game)
        
        -- Hook game events (Attacks, etc.) to the Puppet
        if Puppet then
            SetupHooks(game, modutil, NetworkManager, nil, Puppet)
        end

        -- Spawn the puppet if we are in a valid state
        if game.CurrentRun and game.CurrentRun.Hero then
            Puppet.Create(game.CurrentRun.Hero)
            print("[Hades2MP] Puppet Connected and Ready.")
        else
            print("[Hades2MP] Hero not found, skipping Puppet spawn.")
        end

        -- [[ MAIN LOOP ]]
        while true do
            NetworkManager.Poll()
            
            -- Simple State Sync Loop
            if game and PlayerTracker then
                local state = PlayerTracker.GetState()
                if state then
                    -- Feed local player state to the puppet (Local Mirroring for testing)
                    Puppet.Sync(state)
                end
            end

            -- Update roughly 30 times a second
            wait(0.03) 
        end
    end)
end)