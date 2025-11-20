-- src/ready.lua
local function get_script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end
local folder = get_script_path()
package.path = folder .. "?.lua;" .. folder .. "src/?.lua;" .. package.path

local NetworkManager = require("NetworkManager")()
local socket = require("socket") -- Need direct access to socket for the test

-- 1. Initialize Socket
if config and config.mode == "host" then
    NetworkManager.Init("host", 7777)
else
    NetworkManager.Init("client", 7777)
    NetworkManager.Connect("127.0.0.1", 7777) 
end

local is_network_thread_running = false

-- 2. HOOK: Wrap SetupMap
modutil.mod.Path.Wrap("SetupMap", function(base, ...)
    base(...) 

    if is_network_thread_running then return end
    is_network_thread_running = true

    print("[Hades2MP] SetupMap Hook Triggered.")

    thread(function()
        wait(1.0) 
        
        -- [[ IMPROVED TEST LOGIC ]]
        if config.mode == "host" then
            print("[Hades2MP] Host Mode: Creating temporary client for handshake test...")
            
            -- Create a temporary "Fake Client" just to send a packet
            local temp_client = socket.udp()
            temp_client:setpeername("127.0.0.1", 7777)
            local res, err = temp_client:send("HELLO FROM FAKE CLIENT")
            
            if res then
                print("[Hades2MP] Test packet sent successfully.")
            else
                print("[Hades2MP] Test packet FAILED to send: " .. tostring(err))
            end
            
            temp_client:close()
        else
            print("[Hades2MP] Client Mode: Sending packet to server...")
            NetworkManager.SendString("CLIENT IN-GAME PACKET")
        end

        -- Network Loop
        while true do
            NetworkManager.Poll()
            wait(0.1)
        end
    end)
end)