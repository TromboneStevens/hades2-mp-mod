-- src/ready.lua
local function get_script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end
local folder = get_script_path()
package.path = folder .. "?.lua;" .. folder .. "src/?.lua;" .. package.path

local NetworkManager = require("NetworkManager")()

-- 1. Initialize Socket Immediately (Safe to do anywhere)
if config and config.mode == "host" then
    NetworkManager.Init("host", 7777)
else
    NetworkManager.Init("client", 7777)
    NetworkManager.Connect("127.0.0.1", 7777) 
end

-- Track if the loop is already running so we don't start it twice
local is_network_thread_running = false

-- 2. Define the Hook: Runs every time a map/room loads
function prefix_SetupMap()
    if is_network_thread_running then return end
    is_network_thread_running = true

    print("[Hades2MP] Game Loaded. Starting Native Network Thread.")

    -- 3. Start the Native Game Thread
    -- This works perfectly now because 'SetupMap' implies the game world exists!
    thread(function()
        -- Send a test packet as soon as we enter the game
        wait(1.0) 
        print("[Hades2MP] Sending In-Game Test Packet...")
        if config.mode == "host" then
             -- Loopback to self for testing
            if NetworkManager.udp then
                NetworkManager.udp:sendto("HOST IN-GAME PACKET", "127.0.0.1", 7777)
            end
        else
            NetworkManager.SendString("CLIENT IN-GAME PACKET")
        end

        -- The Loop
        while true do
            NetworkManager.Poll()
            
            -- wait(0) yields for exactly one game frame (syncs with 60FPS)
            -- It is safe here because we are definitely In-Game.
            wait(0)
        end
    end)
end