-- src/NetworkManager.lua
return function()
    local socket = require("socket") 
    if not socket then return nil end

    local NetworkManager = {}
    NetworkManager.udp = nil
    NetworkManager.mode = nil
    NetworkManager.last_client_ip = nil
    NetworkManager.last_client_port = nil

    function NetworkManager.Init(mode, port)
        NetworkManager.mode = mode
        NetworkManager.udp = socket.udp()
        
        -- Force Non-Blocking
        NetworkManager.udp:settimeout(0)

        if mode == "host" then
            -- [[ CHANGE: Use '0.0.0.0' to force IPv4 binding ]]
            local res, err = NetworkManager.udp:setsockname("0.0.0.0", port)
            if res then
                print("[Net] HOST Initialized on 0.0.0.0:" .. port)
            else
                print("[Net] HOST Bind Failed: " .. tostring(err))
            end
        else
            print("[Net] CLIENT Initialized")
        end
    end

    function NetworkManager.Connect(ip, port)
        if not NetworkManager.udp then return end
        NetworkManager.udp:setpeername(ip, port)
    end

    function NetworkManager.Poll()
        if not NetworkManager.udp then return end
        
        -- Force non-blocking just in case
        NetworkManager.udp:settimeout(0)

        local data, msg_or_ip, port_or_nil

        if NetworkManager.mode == "client" then
            data, msg_or_ip = NetworkManager.udp:receive()
        else
            data, msg_or_ip, port_or_nil = NetworkManager.udp:receivefrom()
        end

        if data then
            print("[Net] RX: " .. tostring(data))
            if NetworkManager.mode == "host" then
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
                print("[Net] Error: Host has no target to send to.")
                return
            end
        end

        -- [[ NEW: Log send failures ]]
        if not success then
            print("[Net] SEND FAILED: " .. tostring(err))
        end
    end

    return NetworkManager
end