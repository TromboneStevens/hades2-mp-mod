-- src/NetworkManager.lua
return function()
    -- Load LuaSocket
    local socket = require("socket") 

    if not socket then
        print("[NetworkManager] CRITICAL: Failed to load 'socket' library")
        return nil
    end

    local NetworkManager = {}
    NetworkManager.udp = nil
    NetworkManager.mode = nil -- Track if we are "host" or "client"
    
    -- For Host: Keep track of the last person who talked to us so we can reply
    NetworkManager.last_client_ip = nil
    NetworkManager.last_client_port = nil

    function NetworkManager.Init(mode, port)
        NetworkManager.mode = mode
        NetworkManager.udp = socket.udp()
        
        -- Set timeout to 0 for non-blocking behavior
        NetworkManager.udp:settimeout(0)

        if mode == "host" then
            -- Host: Binds to port, stays UNCONNECTED to receive from anyone
            local res, err = NetworkManager.udp:setsockname("*", port)
            if res then
                print("[Net] HOST started. Listening on port " .. port)
            else
                print("[Net] HOST failed to bind: " .. tostring(err))
            end
        else
            -- Client: Will connect later
            print("[Net] CLIENT initialized.")
        end
    end

    function NetworkManager.Connect(ip, port)
        if not NetworkManager.udp then return end
        
        print("[Net] Connecting to " .. ip .. ":" .. port)
        
        -- Client: Connects to server. Socket becomes CONNECTED.
        local res, err = NetworkManager.udp:setpeername(ip, port)
        
        if not res then
            print("[Net] Connection failed: " .. tostring(err))
        end
    end

	function NetworkManager.Poll()
        if not NetworkManager.udp then return end
        
        -- Debug: Check if we get stuck here
        -- print("[Net] Polling...") 

        local data, msg_or_ip, port_or_nil

        if NetworkManager.mode == "client" then
            data, msg_or_ip = NetworkManager.udp:receive()
        else
            data, msg_or_ip, port_or_nil = NetworkManager.udp:receivefrom()
        end
        
        -- If we reach here, receive() is NOT blocking
        -- print("[Net] Poll Complete. Result: " .. tostring(data or msg_or_ip))

        if data then
            print("[Net] RX: " .. data)
            if NetworkManager.mode == "host" then
                NetworkManager.last_client_ip = msg_or_ip
                NetworkManager.last_client_port = port_or_nil
            end
        elseif msg_or_ip ~= "timeout" then
            -- Only print REAL errors, ignore timeout (which is normal)
            print("[Net] Receive error: " .. tostring(msg_or_ip))
        end
    end

    function NetworkManager.SendString(str, target_ip, target_port)
        if not NetworkManager.udp then return end
        
        if NetworkManager.mode == "client" then
            -- CLIENT: sends to the connected peer automatically
            NetworkManager.udp:send(str)
        else
            -- HOST: Must specify destination (sendto)
            -- If target is provided, use it. Otherwise, reply to last sender.
            local ip = target_ip or NetworkManager.last_client_ip
            local port = target_port or NetworkManager.last_client_port
            
            if ip and port then
                NetworkManager.udp:sendto(str, ip, port)
            else
                print("[Net] Error: Host tried to send data but has no target IP/Port!")
            end
        end
    end

    return NetworkManager
end