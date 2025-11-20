---@meta _
-- Use the enet library stored in the global 'public' table by main.lua
local enet = public.enet 
local NetworkManager = {}

-- Stores the host object (Server or Client)
NetworkManager.host = nil

-- Stores the peer object for the server (if we are a client)
NetworkManager.server_peer = nil 

-- Initialize ENet as either a Host (Server) or Client
function NetworkManager.Init(mode, port)
    if mode == "host" then
        print("[Net] Starting HOST on port " .. port)
        -- "0.0.0.0:port" binds to all local IPs so friends can connect
        NetworkManager.host = enet.host_create("0.0.0.0:" .. port)
    else
        print("[Net] Starting CLIENT...")
        -- Clients don't bind to a port, so we pass nothing (or nil) to let the OS pick one
        NetworkManager.host = enet.host_create()
    end

    if not NetworkManager.host then
        print("[Net] FATAL: Failed to create ENet host!")
    end
end

-- Connect to a specific IP and Port (Client only)
function NetworkManager.Connect(ip, port)
    if not NetworkManager.host then return end
    
    local address = ip .. ":" .. port
    print("[Net] Connecting to " .. address)
    
    -- connect() returns a 'peer' object representing the server connection
    NetworkManager.server_peer = NetworkManager.host:connect(address)
end

-- Poll for network events (Run this every frame!)
function NetworkManager.Poll()
    if not NetworkManager.host then return end

    -- Check for events. 0 means "don't wait", just check and return immediately.
    -- This prevents the game from freezing.
    local event = NetworkManager.host:service(0)
    
    while event do
        if event.type == "connect" then
            print("[Net] Connection established with: " .. tostring(event.peer))
            
        elseif event.type == "receive" then
            print("[Net] Received: " .. event.data)
            
            -- TODO: Add your packet handling logic here!
            -- Example: 
            -- if event.data == "Ping" then 
            --     NetworkManager.SendString("Pong") 
            -- end

        elseif event.type == "disconnect" then
            print("[Net] Disconnected.")
        end
        
        -- Get next event in the queue (if any)
        event = NetworkManager.host:service(0)
    end
end

-- Send a string message to everyone
function NetworkManager.SendString(str)
    if not NetworkManager.host then return end
    
    -- 'broadcast' sends to all connected peers.
    -- If you are a Client, you only have one peer (the server), so this sends to the server.
    -- If you are a Host, this sends to all connected Clients.
    NetworkManager.host:broadcast(str)
end

return NetworkManager