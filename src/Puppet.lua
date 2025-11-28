return function(game, modutil)
    local Puppet = {}
    Puppet.Id = nil
    Puppet.CurrentAnim = "MelinoeIdle" 

    function Puppet.Create(hero)
        if Puppet.Id then return end
        
        local SpawnUnit = game.SpawnUnit or _G.SpawnUnit or rom.game.SpawnUnit
        if not SpawnUnit then 
            print("[Puppet] Error: SpawnUnit function not found.")
            return 
        end
        
        print("[Puppet] Spawning Multiplayer Puppet...")

        -- [[ 1. LOCATE PLAYER DEFINITION ]]
        -- We spawn the actual PlayerUnit to get the correct Mesh/Graphic, 
        -- but we must find its definition in memory to modify it temporarily.
        local targetName = "_PlayerUnit"
        local targetTable = nil

        if game.HeroData and game.HeroData[targetName] then
            targetTable = game.HeroData
        elseif game.UnitData and game.UnitData[targetName] then
            targetTable = game.UnitData
        elseif game.EnemyData and game.EnemyData[targetName] then
            targetTable = game.EnemyData
        end

        if not targetTable then
            -- Fallback: Should not happen, but safe to handle
            print("[Puppet] Warning: Could not find _PlayerUnit. Injecting fallback...")
            game.EnemyData[targetName] = game.DeepCopyTable(game.HeroData.DefaultHero or {})
            targetTable = game.EnemyData
        end

        -- [[ 2. THE HIJACK (CRITICAL) ]]
        -- We temporarily disable 'PlayerControlled'. This prevents the engine from 
        -- attaching input/camera logic to this new unit, which causes the crash.
        local unitDef = targetTable[targetName]
        local backupControlled = unitDef.PlayerControlled
        
        unitDef.PlayerControlled = false
        
        -- [[ 3. SPAWN ]]
        local spawnArgs = {
            Name = targetName,
            Group = "Standing",
            DestinationId = hero.ObjectId,
            OffsetX = -100, 
            OffsetY = 0
        }

        -- Use pcall to ensure we ALWAYS restore the definition, even if Spawn fails
        local status, result = pcall(SpawnUnit, spawnArgs)
        
        -- [[ 4. RESTORE DEFINITION ]]
        unitDef.PlayerControlled = backupControlled
        
        if not status then
            print("[Puppet] Spawn Failed: " .. tostring(result))
            return
        end

        local pId = (type(result) == "number") and result or (result and result.ObjectId)

        if pId and pId > 0 then
            Puppet.Id = pId
            print("[Puppet] Spawn Successful. ID: " .. tostring(pId))
            
            -- [[ 5. INITIALIZATION ]]
            -- Initialize basic physics/logic, but ignore AI since it's a puppet
            game.SetupUnit({ Name = targetName, ObjectId = pId }, game.CurrentRun, {
                IgnoreAI = true,
                PreLoadBinks = true,
                IgnoreAssert = true
            })
            
            -- [[ 6. LOBOTOMY (Disable Physics) ]]
            -- Ensure the puppet is purely visual and doesn't collide or fall
            if game.SetUnitProperty then
                 game.SetUnitProperty({ Id = pId, Property = "Speed", Value = 0 })
                 game.SetUnitProperty({ Id = pId, Property = "CollideWithUnits", Value = false })
                 game.SetUnitProperty({ Id = pId, Property = "ImmuneToStun", Value = true })
                 game.SetUnitProperty({ Id = pId, Property = "IsInvulnerable", Value = true })
                 game.SetUnitProperty({ Id = pId, Property = "UseHitShield", Value = false })
            end

            -- Ensure it's visible (just in case)
            if game.SetThingProperty then
                 game.SetThingProperty({ Id = pId, Property = "Material", Value = "Unlit" })
                 game.SetThingProperty({ Id = pId, Property = "Scale", Value = 1.0 })
                 game.SetThingProperty({ Id = pId, Property = "Color", Value = {255, 255, 255, 255} })
            end
            
            -- [[ 7. ANIMATION LOOP ]]
            thread(function()
                -- Force initial state
                if game.SetAnimation then
                    local anim = "MelinoeIdle"
                    game.StopAnimation({ DestinationId = pId })
                    game.SetAnimation({ Name = anim, DestinationId = pId })
                end

                -- Keep the coroutine alive to manage the puppet
                while Puppet.Id == pId and game.IsAlive({ Id = pId }) do
                    wait(1.0) 
                end
            end)

        else
            print("[Puppet] Spawn returned invalid ID.")
        end
    end

    function Puppet.Mimic(actionName)
        if not Puppet.Id then return end
        if game.SetAnimation then
             local anim = actionName
             -- Ensure we map generic actions to Melinoe animations
             if not string.find(anim, "Melinoe") then
                anim = "Melinoe" .. actionName
             end
             Puppet.CurrentAnim = anim
             game.SetAnimation({ Name = anim, DestinationId = Puppet.Id })
        end
    end

    return Puppet
end