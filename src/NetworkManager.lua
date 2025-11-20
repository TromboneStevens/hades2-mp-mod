---@meta _
local ffi = require("ffi")
local lib = public.enet -- Access the loaded DLL from main.lua

local NetworkManager = {}

-- State Variables
NetworkManager.host = nil
NetworkManager.peers = {}
NetworkManager.is_server = false

-- Constants
local ENET_PACKET_FLAG_RELIABLE = 1

function NetworkManager.Init(mode, port)
    local address = ffi.new("ENetAddress")
    
    if mode == "host" or mode == "loopback" then
        address.host = 0 -- ENET_HOST_ANY (Bind all interfaces)
        address.port = port
        
        NetworkManager.host = lib.enet_host_create(address, 32, 2, 0, 0)
        NetworkManager.is_server = true
        print("[Net] Host created on port ".. port)
    else
        -- Client Mode
        NetworkManager.host = lib.enet_host_create(nil, 1, 2, 0, 0)
        NetworkManager.is_server = false
        print("[Net] Client host created.")
    end
    
    if NetworkManager.host == nil then
        print("[Net] FATAL: Could not create ENet host.")
    end
end

function NetworkManager.Connect(ip, port)
    if NetworkManager.is_server then return end
    
    local address = ffi.new("ENetAddress")
    lib.enet_address_set_host(address, ip)
    address.port = port
    
    -- Initiate connection
    local peer = lib.enet_host_connect(NetworkManager.host, address, 2, 0)
    if peer == nil then
        print("[Net] Connection failed: No peers available.")
    else
        print("[Net] Connecting to ".. ip.. ":".. port)
    end
end

function NetworkManager.Poll()
    if NetworkManager.host == nil then return end
    
    local event = ffi.new("ENetEvent")
    
    -- Service the host. 0 timeout means non-blocking (return immediately).
    -- CRITICAL: Do not set timeout > 0 or the game will freeze!
    while lib.enet_host_service(NetworkManager.host, event, 0) > 0 do
        
        if event.type == lib.ENET_EVENT_TYPE_CONNECT then
            print("[Net] Connection established: ".. tostring(event.peer))
            
        elseif event.type == lib.ENET_EVENT_TYPE_RECEIVE then
            -- Handle Data
            local len = event.packet.dataLength
            local data = ffi.string(event.packet.data, len)
            print("[Net] Packet Received: ".. data)
            
            -- Clean up packet memory
            lib.enet_packet_destroy(event.packet)
            
        elseif event.type == lib.ENET_EVENT_TYPE_DISCONNECT then
            print("[Net] Disconnect.")
        end
    end
end

function NetworkManager.SendString(str)
    if NetworkManager.host == nil then return end
    
    local packet = lib.enet_packet_create(str, #str, ENET_PACKET_FLAG_RELIABLE)
    
    -- Broadcast if server, send to server if client
    if NetworkManager.is_server then
        lib.enet_host_broadcast(NetworkManager.host, 0, packet)
    else
        -- Ideally we track the server peer, for now broadcast works for 1 peer
        lib.enet_host_broadcast(NetworkManager.host, 0, packet)
    end
end

return NetworkManager