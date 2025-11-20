---@meta _
import 'NetworkManager.lua' -- Loads the manager

-- 1. Initialize based on config
NetworkManager.Init(config.mode, config.port)

if config.mode == "client" then
    NetworkManager.Connect(config.target_ip, config.port)
end

-- 2. Hook the Game Loop
-- "EngineUpdate" is a standard hook point in SGG engine games
modutil.mod.Path.Wrap("EngineUpdate", function(base,...)
    -- Run the original game update
    local result = base(...)
    
    -- Pump the network events
    NetworkManager.Poll()
    
    return result
end)

-- 3. Input Hook for Testing
-- Pressing 'Gift' (usually G) sends a packet
game.OnControlPressed({'Gift', function()
    print("[Net] Sending Test Packet...")
    NetworkManager.SendString("Hello from ".. (config.mode))
end})