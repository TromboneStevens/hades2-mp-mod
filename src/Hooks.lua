-- src/Hooks.lua
return function(game, modutil, NetworkManager, Outputter)
    
    local function SendEvent(eventType, data)
        if NetworkManager then
            local packet = string.format("%s:%s", eventType, data)
            
            -- [[ ENABLED PRINTING ]]
            -- Uncommented this so you can see packet flow in the console while playing.
            print("[Hades2MP] >>> SENDING: " .. packet)
            
            NetworkManager.SendString(packet) 
        end
    end

    -- [[ THE GOLDEN HOOK: CheckPlayerOnFirePowers ]]
    -- This function captures every action initiated by the player:
    -- Attacks, Specials, Casts, Dashes, Sprints, and Charging (Omegas).
    if game.CheckPlayerOnFirePowers then
        modutil.mod.Path.Wrap("CheckPlayerOnFirePowers", function(base, dataTable, ...)
            
            if dataTable and type(dataTable) == "table" then
                
                -- Extract the Name
                local weaponName = dataTable.name or dataTable.Name or dataTable.WeaponName
                local projName = dataTable.ProjectileName
                
                -- Priority: Weapon Name > Projectile Name
                local finalName = weaponName or projName

                if finalName then 
                    
                    -- [[ OPTIONAL FILTERING ]]
                    -- If "WeaponSprint" floods the network, uncomment lines below to ignore it.
                    -- if finalName == "WeaponSprint" then
                    --    return base(dataTable, ...)
                    -- end

                    -- [[ LOGGING ]]
                    -- Logs unique events to Hades2MP_Log.txt
                    if Outputter then 
                        Outputter.Log("Action", finalName) 
                    end
                    
                    -- [[ NETWORK SEND ]]
                    SendEvent("ATTACK", finalName)
                end
            end

            return base(dataTable, ...)
        end)
    end
end