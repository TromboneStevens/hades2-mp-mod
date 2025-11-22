-- src/Puppet.lua
return function(game, modutil)
    local Puppet = {}
    Puppet.Id = nil

    function Puppet.Create(hero)
        if Puppet.Id then return end
        
        local SpawnUnit = game.SpawnUnit or _G.SpawnUnit or rom.game.SpawnUnit
        if not SpawnUnit then return end

        -- [[ STABLE STRATEGY: NEMESIS ]]
        local targetUnit = "NPC_Nemesis_01" 
        
        print("[Puppet] Spawning Host Unit: " .. targetUnit)
        
        local spawnResult = SpawnUnit({
            Name = targetUnit,
            Group = "Standing",
            DestinationId = hero.ObjectId,
            OffsetX = -100, 
            OffsetY = 0
        })
        
        local pId = (type(spawnResult) == "number") and spawnResult or (spawnResult and spawnResult.ObjectId)
        
        if pId and pId > 0 then
            print("[Puppet] SUCCESS: Host Spawned ID: " .. tostring(pId))
            Puppet.Id = pId
            
            -- Freeze & Lobotomize
            if game.SetUnitProperty then
                game.SetUnitProperty({ Id = pId, Property = "Speed", Value = 0 })
                game.SetUnitProperty({ Id = pId, Property = "CollideWithUnits", Value = false })
                game.SetUnitProperty({ Id = pId, Property = "ImmuneToStun", Value = true })
            end
            
            -- TINT REMOVED: She will appear in her standard colors.
        else
            print("[Puppet] FAIL: Nemesis failed to spawn.")
        end
    end

    function Puppet.Mimic(actionName)
        -- Future: Sync animations here
    end

    return Puppet
end