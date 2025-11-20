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
    NetworkManager.Init("host", 7777)
else
    NetworkManager.Init("client", 7777)
    NetworkManager.Connect("127.0.0.1", 7777) 
end

local is_network_thread_running = false

-- 2. HOOK: Use modutil.mod.Path.Wrap
-- We need to go through 'modutil.mod' to reach the library functions
modutil.mod.Path.Wrap("SetupMap", function(base, ...)
    -- Call the original game function first
    base(...)

    -- Now run our custom code
    if is_network_thread_running then return end
    is_network_thread_running = true

    print("[Hades2MP] SetupMap Hook Triggered. Starting Network Thread.")

    thread(function()
        wait(1.0) 
        print("[Hades2MP] Sending In-Game Test Packet...")
        
        if config.mode == "host" then
            if NetworkManager.udp then
                -- Use 127.0.0.1 explicitly for loopback testing
                NetworkManager.udp:sendto("HOST IN-GAME PACKET", "127.0.0.1", 7777)
            end
        else
            NetworkManager.SendString("CLIENT IN-GAME PACKET")
        end

        while true do
            NetworkManager.Poll()
            wait(0)
        end
    end)
end)