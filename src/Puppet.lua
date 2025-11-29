return function(game, modutil)
    local Puppet = {}
    Puppet.Id = nil
    
    -- We refer to the name defined in DataInjector
    local puppetName = "NetPuppet"

    function Puppet.Create(hero)
        if Puppet.Id then return end
        
        -- [[ DIAGNOSTIC TEST: GHOST HERO ]]
        -- Instead of spawning a puppet, we will try to apply the "Ghost Mode"
        -- directly to the player character to see if the physics changes work.
        if hero and hero.ObjectId then
            print("[Puppet] Applying Ghost Mode to HERO (ID: " .. tostring(hero.ObjectId) .. ")...")
            
            local heroId = hero.ObjectId
            
            -- Launch a thread to maintain the ghost state on the player
            thread(function()
                while game.IsAlive({ Id = heroId }) do
                    -- Force Physics OFF for the player
                    if game.SetThingProperty then
                        -- StopsUnits = False means you can walk through enemies/walls
                        pcall(game.SetThingProperty, { Id = heroId, Property = "StopsUnits", Value = false })
                        pcall(game.SetThingProperty, { Id = heroId, Property = "StopsProjectiles", Value = false })
                        pcall(game.SetThingProperty, { Id = heroId, Property = "Grip", Value = 0 })
                        
                        -- Attempt to clear the collision mask if supported
                        -- (This property name is a guess based on common engine patterns, might do nothing)
                        pcall(game.SetThingProperty, { Id = heroId, Property = "CollisionMask", Value = 0 })
                    end
                    
                    if game.SetUnitProperty then
                        -- CollideWithUnits = False means you don't push others
                        pcall(game.SetUnitProperty, { Id = heroId, Property = "CollideWithUnits", Value = false })
                        pcall(game.SetUnitProperty, { Id = heroId, Property = "ImmuneToStun", Value = true })
                    end
                    
                    -- Debug print occasionally
                    -- print("[Puppet] Enforcing Ghost Hero...")
                    
                    wait(0.02) -- Check 50 times a second (very fast)
                end
            end)
            
            return -- Exit early, don't spawn the puppet
        end

        -- ... existing spawn logic (skipped for this test) ...
        
        local SpawnFn = _G.SpawnUnit or game.SpawnUnit or (rom and rom.game and rom.game.SpawnUnit)
        if not SpawnFn then return end

        print("[Puppet] Spawning clone of " .. puppetName .. "...")

        -- [[ 1. LOCATE DEFINITION ]]
        local sourceTable = nil
        if game.HeroData and game.HeroData[puppetName] then
            sourceTable = game.HeroData
        elseif game.EnemyData and game.EnemyData[puppetName] then
            sourceTable = game.EnemyData
        else
            if not game.EnemyData then game.EnemyData = {} end
            game.EnemyData[puppetName] = {}
            sourceTable = game.EnemyData
        end

        local unitDef = sourceTable[puppetName]

        -- [[ 2. BACKUP & HIJACK ]]
        local backupThing = unitDef.Thing
        local backupCollide = unitDef.CollideWithUnits
        local backupControl = unitDef.PlayerControlled

        local newThing = {}
        if backupThing then
            for k, v in pairs(backupThing) do newThing[k] = v end
        end

        -- [[ 3. NUKE THE HITBOX ]]
        newThing.Points = {} 
        newThing.StopsUnits = false
        newThing.StopsProjectiles = false
        newThing.Grip = 0

        -- Apply Hijack
        unitDef.Thing = newThing
        unitDef.CollideWithUnits = false
        unitDef.PlayerControlled = false

        -- [[ 4. SPAWN ]]
        local spawnArgs = {
            Name = puppetName,
            Group = "Standing",
            DestinationId = hero.ObjectId,
            OffsetX = -100, 
            OffsetY = 0
        }

        local status, result = pcall(SpawnFn, spawnArgs)

        -- [[ 5. DELAYED RESTORE (THE FIX) ]]
        -- We wait briefly before restoring so the engine consumes the "Ghost" data.
        thread(function()
            wait(0.2)
            unitDef.Thing = backupThing
            unitDef.CollideWithUnits = backupCollide
            unitDef.PlayerControlled = backupControl
            -- print("[Puppet] Definition Restored.") 
        end)

        if not status then
            print("[Puppet] Spawn Failed: " .. tostring(result))
            return
        end

        local pId = nil
        if type(result) == "number" then pId = result
        elseif type(result) == "table" and result.ObjectId then pId = result.ObjectId end

        if pId and pId > 0 then
            Puppet.Id = pId
            print("[Puppet] Spawn Successful. ID: " .. tostring(pId))
            
            -- [[ 6. RUNTIME ENFORCEMENT LOOP ]]
            thread(function()
                -- Wait a frame to ensure the unit is initialized
                wait(0.1)
                
                while Puppet.Id == pId and game.IsAlive({ Id = pId }) do
                     -- A. ANIMATION
                     if game.SetAnimation and Puppet.CurrentAnim then
                         pcall(game.SetAnimation, { Name = Puppet.CurrentAnim or "MelinoeIdle", DestinationId = pId })
                     end

                     -- B. PHYSICS (Force every frame)
                     -- Since _PlayerUnit defaults to solid, we must fight the engine.
                     if game.SetThingProperty then
                        pcall(game.SetThingProperty, { Id = pId, Property = "StopsUnits", Value = false })
                        pcall(game.SetThingProperty, { Id = pId, Property = "StopsProjectiles", Value = false })
                        pcall(game.SetThingProperty, { Id = pId, Property = "Grip", Value = 0 })
                     end
                     if game.SetUnitProperty then
                        pcall(game.SetUnitProperty, { Id = pId, Property = "CollideWithUnits", Value = false })
                        pcall(game.SetUnitProperty, { Id = pId, Property = "ImmuneToStun", Value = true })
                     end

                     wait(0.1) -- Check 10 times a second
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
             if not string.find(anim, "Melinoe") then anim = "Melinoe" .. actionName end
             pcall(game.SetAnimation, { Name = anim, DestinationId = Puppet.Id })
             Puppet.CurrentAnim = anim 
        end
    end

    return Puppet
end