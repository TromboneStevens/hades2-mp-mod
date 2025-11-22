-- src/Puppet.lua
return function(game, modutil)
    local Puppet = {}
    Puppet.Id = nil

    function Puppet.Create(hero)
        if Puppet.Id then return end
        
        local SpawnUnit = game.SpawnUnit or _G.SpawnUnit or rom.game.SpawnUnit
        if not SpawnUnit then return end

        -- 1. Spawn the CAT (Control Group - We know this works)
        print("[Puppet] TEST 1: Spawning CatFamiliar...")
        local catResult = SpawnUnit({
            Name = "CatFamiliar",
            Group = "Standing",
            DestinationId = hero.ObjectId,
            OffsetX = 150, OffsetY = 0
        })
        
        if catResult then
             -- Handle numeric return
            local catId = (type(catResult) == "number") and catResult or catResult.ObjectId
            print("[Puppet] SUCCESS: Cat Spawned ID: " .. tostring(catId))
            Puppet.Id = catId -- Keep track of at least one ID
        else
            print("[Puppet] FAIL: Cat returned nil.")
        end

        -- 2. Spawn HECATE (Experimental Group - Our only Humanoid option)
        -- We need to see EXACTLY what happens here.
        print("[Puppet] TEST 2: Spawning EnemyHecate...")
        
        -- Try multiple keys if the first one fails
        local hecateKeys = { "EnemyHecate", "BossHecate", "Headmistress" }
        local hecateSpawned = false

        for _, key in ipairs(hecateKeys) do
            if _G.EnemyData[key] then
                print("[Puppet] Attempting spawn with key: " .. key)
                
                local success, err = pcall(function()
                    local hResult = SpawnUnit({
                        Name = key,
                        Group = "Standing",
                        DestinationId = hero.ObjectId,
                        OffsetX = -150, -- Spawn on the other side
                        OffsetY = 0
                    })
                    
                    local hId = (type(hResult) == "number") and hResult or (hResult and hResult.ObjectId)

                    if hId and hId > 0 then
                        print("[Puppet] !!! VICTORY !!! Hecate Spawned ID: " .. tostring(hId))
                        hecateSpawned = true
                        
                        -- If she spawns, FREEZE her immediately so she doesn't start the boss fight logic
                        if game.SetUnitProperty then
                            game.SetUnitProperty({ Id = hId, Property = "Speed", Value = 0 })
                            game.SetUnitProperty({ Id = hId, Property = "IgnoreGravity", Value = true })
                            game.SetUnitProperty({ Id = hId, Property = "CollideWithUnits", Value = false })
                        end
                        
                        -- If we got Hecate, she is our new Puppet (Overrides Cat)
                        Puppet.Id = hId
                    else
                        print("[Puppet] Failed to spawn " .. key .. " (Result: " .. tostring(hResult) .. ")")
                    end
                end)

                if not success then
                    print("[Puppet] CRITICAL ERROR spawning " .. key .. ": " .. tostring(err))
                end

                if hecateSpawned then break end
            else
                print("[Puppet] Key not found in EnemyData: " .. key)
            end
        end
    end

    function Puppet.Mimic(actionName)
    end

    return Puppet
end