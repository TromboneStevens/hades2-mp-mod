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

        -- [[ 1. TARGET ENGINE UNIT ]]
        -- We use "_PlayerUnit" because the C++ Engine knows exactly what assets (Mesh/Anim) this uses.
        -- We don't need to find a Lua definition (DefaultHero) to copy; we just need to override the existing one.
        local targetName = "_PlayerUnit"
        local targetTable = nil

        -- Search for existing Lua definition to hijack
        if game.HeroData and game.HeroData[targetName] then
            targetTable = game.HeroData
        elseif game.EnemyData and game.EnemyData[targetName] then
            targetTable = game.EnemyData
        else
            -- FALLBACK: If not found in Lua, create a blank entry in EnemyData.
            -- The engine will merge this table with the internal SJSON definition.
            print("[Puppet] Definition for " .. targetName .. " not found in Lua. Injecting blank override...")
            if not game.EnemyData then game.EnemyData = {} end
            
            -- We initialize it as an empty table. We DON'T need DefaultHero.
            -- The Engine supplies the defaults; we supply the overrides.
            if not game.EnemyData[targetName] then
                game.EnemyData[targetName] = {}
            end
            targetTable = game.EnemyData
        end

        local unitDef = targetTable[targetName]

        -- [[ 2. APPLY OVERRIDES (Hijack) ]]
        -- We back up values if they exist, to restore them later.
        local backupControlled = unitDef.PlayerControlled
        local backupCollide = unitDef.CollideWithUnits
        
        -- Ensure 'Thing' sub-table exists for physics overrides
        if not unitDef.Thing then unitDef.Thing = {} end
        local backupStopsUnits = unitDef.Thing.StopsUnits
        local backupStopsProjectiles = unitDef.Thing.StopsProjectiles
        local backupGrip = unitDef.Thing.Grip

        -- GHOST MODE: Disable Controller & Collision
        unitDef.PlayerControlled = false     -- Prevents Input Crash
        unitDef.CollideWithUnits = false     -- Disable Active Collision
        unitDef.Thing.StopsUnits = false     -- Let players walk through
        unitDef.Thing.StopsProjectiles = false -- Let attacks pass through
        unitDef.Thing.Grip = 0               -- Remove friction

        -- [[ 3. SPAWN ]]
        local spawnArgs = {
            Name = targetName,
            Group = "Standing",
            DestinationId = hero.ObjectId,
            OffsetX = -100, 
            OffsetY = 0
        }

        local status, result = pcall(SpawnUnit, spawnArgs)

        -- [[ 4. RESTORE DEFINITION ]]
        -- Restore the global table to its previous state immediately.
        unitDef.PlayerControlled = backupControlled
        unitDef.CollideWithUnits = backupCollide
        unitDef.Thing.StopsUnits = backupStopsUnits
        unitDef.Thing.StopsProjectiles = backupStopsProjectiles
        unitDef.Thing.Grip = backupGrip

        if not status then
            print("[Puppet] Spawn Failed: " .. tostring(result))
            return
        end

        local pId = (type(result) == "number") and result or (result and result.ObjectId)

        if pId and pId > 0 then
            Puppet.Id = pId
            print("[Puppet] Spawn Successful. ID: " .. tostring(pId))
            
            -- [[ 5. INITIALIZATION ]]
            -- Use Safe Setup. We intentionally ignore AI because this unit is a puppet.
            game.SetupUnit({ Name = targetName, ObjectId = pId }, game.CurrentRun, {
                IgnoreAI = true,
                PreLoadBinks = true,
                IgnoreAssert = true
            })
            
            -- [[ 6. RUNTIME SAFETY ]]
            -- Reinforce ghost properties at runtime just in case
            if game.SetUnitProperty then
                 game.SetUnitProperty({ Id = pId, Property = "Speed", Value = 0 })
                 game.SetUnitProperty({ Id = pId, Property = "CollideWithUnits", Value = false })
                 game.SetUnitProperty({ Id = pId, Property = "ImmuneToStun", Value = true })
                 game.SetUnitProperty({ Id = pId, Property = "IsInvulnerable", Value = true })
                 game.SetUnitProperty({ Id = pId, Property = "UseHitShield", Value = false })
            end

            if game.SetThingProperty then
                 game.SetThingProperty({ Id = pId, Property = "StopsUnits", Value = false })
                 game.SetThingProperty({ Id = pId, Property = "StopsProjectiles", Value = false })
                 game.SetThingProperty({ Id = pId, Property = "Material", Value = "Unlit" })
                 game.SetThingProperty({ Id = pId, Property = "Color", Value = {255, 255, 255, 255} })
            end
            
            -- [[ 7. ANIMATION LOOP ]]
            thread(function()
                if game.SetAnimation then
                    local anim = "MelinoeIdle"
                    game.StopAnimation({ DestinationId = pId })
                    game.SetAnimation({ Name = anim, DestinationId = pId })
                end

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
        
        -- NOTE: If your puppet is attacking when YOU attack, it is because 
        -- src/Hooks.lua is calling this function. That is expected behavior 
        -- for testing, but you can remove the hook later.
        
        if game.SetAnimation then
             local anim = actionName
             if not string.find(anim, "Melinoe") then
                anim = "Melinoe" .. actionName
             end
             Puppet.CurrentAnim = anim
             game.SetAnimation({ Name = anim, DestinationId = Puppet.Id })
        end
    end

    return Puppet
end