-- src/ready.lua
-- Path detection
local function get_script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end
local folder = get_script_path()

-- Setup Paths
package.path = folder .. "?.lua;" .. folder .. "src/?.lua;" .. package.path

-- Load Network Manager
local NetworkManager = require("NetworkManager")() 

-- Initialize
if config and config.is_host then
    NetworkManager.Init("host", 7777)
else
    NetworkManager.Init("client", 7777)
    NetworkManager.Connect("127.0.0.1", 7777) 
end

-- Game Loop
thread(function()
    print("[Hades2MP] Starting Network Loop...")
    while true do
        -- print("[Hades2MP] Loop Tick") -- Uncomment if needed, but might spam log
        
        NetworkManager.Poll()
        
        -- Increase wait to 0.1 seconds (10 times a second) to prevent freezing
        -- If the game loads with this, we know wait(0) was spinning too fast.
        wait(0.1)
    end
end)