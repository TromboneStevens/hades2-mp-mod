-- ready.lua
local NetworkManager = import 'src/NetworkManager.lua'

-- 1. Initialize based on config (Edit config.lua to swap between host/client)
if public.config.is_host then
    NetworkManager.Init("host", 7777)
else
    NetworkManager.Init("client", 7777)
    -- Connect immediately for testing, or wait for a button press
    NetworkManager.Connect("127.0.0.1", 7777) 
end

-- 2. Start the Game Loop
-- 'thread' is a global SGG function that runs a function as a coroutine
thread(function()
    while true do
        -- Poll network events
        NetworkManager.Poll()
        
        -- Send a test ping every 60 frames (approx 1 sec)
        -- if CheckCooldown("NetPing", 1.0) then
        --     NetworkManager.SendString("Ping from " .. tostring(_PLUGIN.guid))
        -- end

        -- 'wait(0)' yields to the game engine for one frame
        wait(0)
    end
end)