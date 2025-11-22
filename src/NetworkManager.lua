-- src/NetworkManager.lua
return function()
    local socket = require("socket") 
    if not socket then return nil end

    local NetworkManager = {}
    NetworkManager.udp = nil
    NetworkManager.mode = nil
    NetworkManager.last_client_ip = nil
    NetworkManager.last_client_port = nil
    NetworkManager.has_connection = false

    function NetworkManager.Init(mode, port)
        NetworkManager.mode = mode
        NetworkManager.udp = socket.udp()
        
        -- Force Non-Blocking
        NetworkManager.udp:settimeout(0)

        if mode == "host" then
            -- Bind to all interfaces so external IPs can connect
            local res, err = NetworkManager.udp:setsockname("0.0.0.0", port)
            if res then
                print("[Net] HOST Initialized on 0.0.0.0:" .. port)
                print("[Net] Waiting for client handshake...")
            else
                print("[Net] HOST Bind Failed: " .. tostring(err))
            end
        else
            print("[Net] CLIENT Initialized")
            -- Clients know their target immediately via config, so they are "connected"
            NetworkManager.has_connection = true 
        end
    end

    function NetworkManager.Connect(ip, port)
        if not NetworkManager.udp then return end
        NetworkManager.udp:setpeername(ip, port)
    end

    function NetworkManager.Poll()
        if not NetworkManager.udp then return end
        
        -- Force non-blocking
        NetworkManager.udp:settimeout(0)

        local data, msg_or_ip, port_or_nil

        if NetworkManager.mode == "client" then
            data, msg_or_ip = NetworkManager.udp:receive()
        else
            data, msg_or_ip, port_or_nil = NetworkManager.udp:receivefrom()
        end

        if data then
            -- print("[Net] RX: " .. tostring(data)) -- Debug log
            
            if NetworkManager.mode == "host" then
                -- If this is the first packet we've seen, register the client
                if not NetworkManager.has_connection then
                    print(string.format("[Net] Client Connected: %s:%s", msg_or_ip, port_or_nil))
                    NetworkManager.has_connection = true
                end
                
                -- Keep updating address in case the client IP/Port changes (NAT traversal)
                NetworkManager.last_client_ip = msg_or_ip
                NetworkManager.last_client_port = port_or_nil
            end
        elseif msg_or_ip ~= "timeout" then
            print("[Net] Receive Error: " .. tostring(msg_or_ip))
        end
    end

    function NetworkManager.SendString(str, target_ip, target_port)
        if not NetworkManager.udp then return end
        
        local success, err
        
        if NetworkManager.mode == "client" then
            success, err = NetworkManager.udp:send(str)
        else
            local ip = target_ip or NetworkManager.last_client_ip
            local port = target_port or NetworkManager.last_client_port
            
            if ip and port then
                success, err = NetworkManager.udp:sendto(str, ip, port)
            else
                -- [[ THE FIX ]]
                -- If Host has no target, simply return. Do not error.
                -- The Host must wait for the Client to send a packet first.
                return
            end
        end

        if not success then
            print("[Net] SEND FAILED: " .. tostring(err))
        end
    end

    return NetworkManager
end