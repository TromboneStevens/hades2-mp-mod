-- src/ready.lua
local function get_script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end
local folder = get_script_path()
package.path = folder .. "?.lua;" .. folder .. "src/?.lua;" .. package.path

local NetworkManager = require("NetworkManager")()
local PlayerTrackerFactory = require("PlayerTracker")
local SetupHooks = require("Hooks")
local PuppetFactory = require("Puppet")

if config and config.mode == "host" then
    NetworkManager.Init("host", config.port or 7777)
else
    NetworkManager.Init("client", config.port or 7777)
    NetworkManager.Connect(config.target_ip or "127.0.0.1", config.port or 7777) 
    NetworkManager.SendString("HANDSHAKE:HELLO")
end

modutil.mod.Path.Wrap("SetupMap", function(base, ...)
    base(...) 
    
    thread(function()
        -- Wait for map assets (Nemesis) to load
        wait(2.0)
        
        print("[Hades2MP] Map Loaded. Initializing...")
        
        local Puppet = PuppetFactory(game, modutil)
        local PlayerTracker = PlayerTrackerFactory(game)
        
        SetupHooks(game, modutil, NetworkManager, nil, Puppet)

        if game.CurrentRun and game.CurrentRun.Hero then
            Puppet.Create(game.CurrentRun.Hero)
        else
            print("[Hades2MP] Hero not found, skipping Puppet spawn.")
        end

        while true do
            NetworkManager.Poll()
            
            -- Simple State Sync Loop
            if game and PlayerTracker then
                local state = PlayerTracker.GetState()
                if state then
                    -- Send position packet (example)
                    local packet = string.format("POS:%.2f:%.2f", state.Loc.X, state.Loc.Y)
                    -- NetworkManager.SendString(packet)
                end
            end

            wait(0.1) 
        end
    end)
end)