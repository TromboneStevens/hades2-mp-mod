-- src/ready.lua
local function get_script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end
local folder = get_script_path()
package.path = folder .. "?.lua;" .. folder .. "src/?.lua;" .. package.path

-- Import Modules
local NetworkManager = require("NetworkManager")()
local PlayerTrackerFactory = require("PlayerTracker") -- Loads the file

-- Setup Network
if config and config.mode == "host" then
    NetworkManager.Init("host", config.port or 7777)
else
    NetworkManager.Init("client", config.port or 7777)
    NetworkManager.Connect(config.target_ip or "127.0.0.1", config.port or 7777) 
end

-- Main Hook
modutil.mod.Path.Wrap("SetupMap", function(base, ...)
    base(...) 
    
    thread(function()
        wait(1.0)
        print("[Hades2MP] Game Loop Started")

        -- Initialize our Tracker with the specific 'game' instance for this context
        local PlayerTracker = PlayerTrackerFactory(game)

        while true do
            NetworkManager.Poll()

            if game then
                local x, y = PlayerTracker.GetPosition()
                
                if x and y then
                    print(string.format("[Hades2MP] Player Pos: %.2f, %.2f", x, y))
                    
                    -- Ready for networking!
                    -- NetworkManager.SendString(string.format("POS:%.2f:%.2f", x, y))
                end
            end

            wait(0.1)
        end
    end)
end)