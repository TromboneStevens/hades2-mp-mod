-- src/ready.lua
-- Path detection
local function get_script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end
local folder = get_script_path()

-- Setup Paths
package.path = folder .. "?.lua;" .. folder .. "src/?.lua;" .. package.path

-- 'enet' and 'config' are now injected directly into this script's environment by main.lua
if not enet then
    print("[Hades2MP] ERROR: ENet library was not injected into ready.lua!")
    return
end

-- Load Network Manager
-- We pass the 'enet' variable that exists in our scope
local NetworkManager = require("NetworkManager")(enet)

-- Initialize
if config and config.is_host then
    NetworkManager.Init("host", 7777)
else
    NetworkManager.Init("client", 7777)
    NetworkManager.Connect("127.0.0.1", 7777) 
end

-- Game Loop
thread(function()
    while true do
        NetworkManager.Poll()
        wait(0)
    end
end)