---@meta _
local lib = public.enet 
local NetworkManager = {}

NetworkManager.host = nil
NetworkManager.peers = {}

function NetworkManager.Init(mode, port)
    -- The C code now handles the complex setup!
    -- Usage: host_create(mode, port)
    if mode == "host" then
        print("[Net] Starting Server on port " .. port)
        NetworkManager.host = lib.host_create("server", port)
    else
        print("[Net] Starting Client...")
        NetworkManager.host = lib.host_create("client")
    end
    
    if NetworkManager.host == nil then
        print("[Net] FATAL: Host creation failed.")
    end
end

function NetworkManager.Connect(ip, port)
    if NetworkManager.host == nil then return end
    print("[Net] Connecting to " .. ip .. ":" .. port)
    
    -- The C code handles the address struct internally now
    local result = lib.connect(NetworkManager.host, ip, port)
    if not result then
        print("[Net] Failed to initiate connection.")
    end
end

function NetworkManager.Poll()
    if NetworkManager.host == nil then return end
    
    -- lib.host_service returns a table or nil, no pointers needed!
    local event = lib.host_service(NetworkManager.host, 0)
    
    if event then
        if event.type == "connect" then
            print("[Net] Connected!")
            
        elseif event.type == "receive" then
            print("[Net] Payload: " .. event.data)
            
        elseif event.type == "disconnect" then
            print("[Net] Disconnected.")
        end
    end
end

function NetworkManager.SendString(str)
    if NetworkManager.host == nil then return end
    lib.broadcast(NetworkManager.host, str)
end

return NetworkManager