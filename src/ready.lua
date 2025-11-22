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

-- [[ DEBUG TOOLS (Disabled for Production) ]]
-- local SetupScanner = require("Scanner")
-- local Outputter = require("Outputter")() 

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
        wait(1.0)
        print("[Hades2MP] Session Started")

        local PlayerTracker = PlayerTrackerFactory(game)
        
        -- Initialize Hooks (Outputter is omitted, so it defaults to nil inside Hooks)
        SetupHooks(game, modutil, NetworkManager)
        
        -- Scanner is disabled
        -- SetupScanner(game, modutil, NetworkManager) 

        while true do
            NetworkManager.Poll()
            
            if game then
                local state = PlayerTracker.GetState()
                if state then
                    local packet = string.format(
                        "POS:%.2f:%.2f:%.2f:%s", 
                        state.Loc.X, 
                        state.Loc.Y, 
                        state.Angle, 
                        state.Anim
                    )
                    -- NetworkManager.SendString(packet)
                end
            end

            wait(0.1) 
        end
    end)
end)