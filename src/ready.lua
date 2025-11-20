-- src/ready.lua
local function get_script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end
local folder = get_script_path()
package.path = folder .. "?.lua;" .. folder .. "src/?.lua;" .. package.path

local NetworkManager = require("NetworkManager")()

-- 1. Initialize Socket
if config and config.mode == "host" then
    NetworkManager.Init("host", config.port or 7777)
else
    -- Use the IP from config.lua!
    NetworkManager.Init("client", config.port or 7777)
    NetworkManager.Connect(config.target_ip or "127.0.0.1", config.port or 7777) 
end

local is_network_thread_running = false

-- 2. HOOK: Wrap SetupMap
modutil.mod.Path.Wrap("SetupMap", function(base, ...)
    base(...) 

    if is_network_thread_running then return end
    is_network_thread_running = true

    print("[Hades2MP] Network Thread Started.")

    thread(function()
        -- Small delay to let the level settle
        wait(1.0) 

        -- Just send one "I'm here" packet
        if config.mode == "client" then
             NetworkManager.SendString("Player Connected!")
        end

        while true do
            NetworkManager.Poll()
            -- Keep the small wait to be safe on performance
            wait(0.1)
        end
    end)
end)