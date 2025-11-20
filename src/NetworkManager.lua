---@meta _
-- NetworkManager.lua
-- NOW RETURNS: A constructor function that takes 'enet' as an argument.

return function(enet_lib)
    if not enet_lib then
        error("[NetworkManager] ENet library was nil!")
    end

    local NetworkManager = {}
    NetworkManager.host = nil
    NetworkManager.server_peer = nil 

    function NetworkManager.Init(mode, port)
        if mode == "host" then
            print("[Net] Starting HOST on port " .. port)
            NetworkManager.host = enet_lib.host_create("0.0.0.0:" .. port)
        else
            print("[Net] Starting CLIENT...")
            NetworkManager.host = enet_lib.host_create()
        end

        if not NetworkManager.host then
            print("[Net] FATAL: Failed to create ENet host!")
        end
    end

    function NetworkManager.Connect(ip, port)
        if not NetworkManager.host then return end
        local address = ip .. ":" .. port
        print("[Net] Connecting to " .. address)
        NetworkManager.server_peer = NetworkManager.host:connect(address)
    end

    function NetworkManager.Poll()
        if not NetworkManager.host then return end
        local event = NetworkManager.host:service(0)
        while event do
            if event.type == "connect" then
                print("[Net] Connection established: " .. tostring(event.peer))
            elseif event.type == "receive" then
                print("[Net] Received: " .. event.data)
            elseif event.type == "disconnect" then
                print("[Net] Disconnected.")
            end
            event = NetworkManager.host:service(0)
        end
    end

    function NetworkManager.SendString(str)
        if not NetworkManager.host then return end
        NetworkManager.host:broadcast(str)
    end

    return NetworkManager
end