-- src/Hooks.lua
return function(game, modutil, NetworkManager, Outputter, Puppet)
    
    local function SendEvent(eventType, data)
        if NetworkManager then
            local packet = string.format("%s:%s", eventType, data)
            -- print("[Hades2MP] >>> SENDING: " .. packet)
            NetworkManager.SendString(packet) 
        end
    end

    -- [[ THE GOLDEN HOOK: CheckPlayerOnFirePowers ]]
    if game.CheckPlayerOnFirePowers then
        modutil.mod.Path.Wrap("CheckPlayerOnFirePowers", function(base, dataTable, ...)
            
            if dataTable and type(dataTable) == "table" then
                
                local weaponName = dataTable.name or dataTable.Name or dataTable.WeaponName
                local projName = dataTable.ProjectileName
                local finalName = weaponName or projName

                if finalName then 
                    
                    -- [[ NETWORK SEND ]]
                    SendEvent("ATTACK", finalName)

                    -- [[ PUPPET MIRROR ]]
                    -- If a puppet exists, make it copy the action immediately
                    if Puppet then
                        Puppet.Mimic(finalName)
                    end

                    -- [[ LOGGING (Optional) ]]
                    if Outputter then 
                        Outputter.Log("Action", finalName) 
                    end
                end
            end

            return base(dataTable, ...)
        end)
    end
end