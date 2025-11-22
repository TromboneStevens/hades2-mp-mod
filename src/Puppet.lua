-- src/Puppet.lua
return function(game, modutil)
    local Puppet = {}
    Puppet.Id = nil
    
    local function DeepCopy(obj, seen)
        if type(obj) ~= 'table' then return obj end
        if seen and seen[obj] then return seen[obj] end
        local s = seen or {}
        local res = setmetatable({}, getmetatable(obj))
        s[obj] = res
        for k, v in pairs(obj) do res[DeepCopy(k, s)] = DeepCopy(v, s) end
        return res
    end

    -- [[ DYNAMIC PROBE: The Return of the Cat ]]
    -- We revert to scanning 'ActiveEnemies' because it successfully found the Cat (ID 1000001).
    -- GetIds() failed us, so we trust the global table.
    local function FindActiveCloneBase(heroId)
        print("[Puppet] Scanning ActiveEnemies table...")
        
        if _G.ActiveEnemies then
            for id, unit in pairs(_G.ActiveEnemies) do
                -- Skip the player and nil entries
                if unit and id ~= heroId and unit.Name then
                     -- Verify we have a definition for this unit
                     if _G.EnemyData and _G.EnemyData[unit.Name] then
                         print("[Puppet] Found Active Enemy: " .. unit.Name)
                         return _G.EnemyData[unit.Name]
                     elseif _G.NPCData and _G.NPCData[unit.Name] then
                         print("[Puppet] Found Active NPC/Pet: " .. unit.Name)
                         return _G.NPCData[unit.Name]
                     end
                end
            end
        end
        
        -- Fallback: Training Dummy (Common in training room)
        if _G.EnemyData and _G.EnemyData.TrainingDummy then
             return _G.EnemyData.TrainingDummy 
        end

        return nil
    end

    function Puppet.Create(hero)
        if Puppet.Id then return end
        
        local success, err = pcall(function()
            if not hero then return end
            local SpawnUnit = game.SpawnUnit or _G.SpawnUnit or rom.game.SpawnUnit
            if not SpawnUnit then return end

            -- 1. Find the Cat (or whatever is loaded)
            local baseDef = FindActiveCloneBase(hero.ObjectId)
            if not baseDef then
                print("[Puppet] ERROR: No loaded base unit found. Aborting.")
                return
            end

            -- 2. Register & Sanitize
            local puppetName = "HeroPuppet"
            if _G.EnemyData then
                if not _G.EnemyData[puppetName] then
                    print("[Puppet] Cloning & Sanitizing " .. (baseDef.Name or "?") .. "...")
                    local newDef = DeepCopy(baseDef)
                    newDef.Name = puppetName
                    
                    -- [[ SANITIZATION: The Anti-Crash Fix ]]
                    -- We remove ALL logic that might reference the original unit's systems.
                    newDef.AI = nil
                    newDef.AIData = nil
                    newDef.AIOptions = nil
                    newDef.WeaponOptions = nil
                    newDef.Traits = nil
                    newDef.OnDeathFunctionName = nil
                    newDef.OnKillFunctionName = nil
                    newDef.GameStateRequirements = nil
                    
                    -- CRITICAL: Remove Spawn Logic (This crashed the Cat clone)
                    newDef.OnSpawnFunctionName = nil 
                    
                    -- Safety Flags
                    newDef.SkipAISetup = true
                    newDef.IsController = false
                    newDef.Invulnerable = true
                    newDef.IgnoreGrid = true
                    newDef.CanBeHealingInteraction = false
                    
                    _G.EnemyData[puppetName] = newDef
                end
            end

            -- 3. Spawn
            print("[Puppet] Spawning...")
            local spawnData = {
                Name = puppetName,
                Group = "Standing",
                DestinationId = hero.ObjectId,
                OffsetX = 250, 
                OffsetY = 0
            }

            local unit = SpawnUnit(spawnData)
            
            if unit and unit.ObjectId then
                Puppet.Id = unit.ObjectId
                print("[Puppet] SUCCESS: Spawned ID " .. tostring(Puppet.Id))
                
                -- 4. Swap Visuals (The Costume Change)
                if game.SetUnitProperty then
                    local heroGraphic = hero.Graphic or "Melinoe"
                    print("[Puppet] Applying Skin: " .. heroGraphic)
                    
                    game.SetUnitProperty({ Id = Puppet.Id, Property = "Graphic", Value = heroGraphic })
                    
                    game.SetUnitProperty({ Id = Puppet.Id, Property = "ImmuneToStun", Value = true })
                    game.SetUnitProperty({ Id = Puppet.Id, Property = "CollideWithObstacles", Value = false })
                    game.SetUnitProperty({ Id = Puppet.Id, Property = "Invulnerable", Value = true })
                    game.SetUnitProperty({ Id = Puppet.Id, Property = "IgnoreGravity", Value = true })
                end
                
                -- 5. Initialize Weapons
                local FireWeapon = game.FireWeaponFromUnit or _G.FireWeaponFromUnit or rom.game.FireWeaponFromUnit
                if FireWeapon then
                    pcall(FireWeapon, { Id = Puppet.Id, Weapon = "WeaponStaffSwing", AutoEquip = true, FireOnly = false })
                end
            else
                print("[Puppet] Spawn Failed.")
            end
        end)

        if not success then
            print("[Puppet] CRITICAL EXCEPTION: " .. tostring(err))
        end
    end

    function Puppet.Mimic(actionName)
        if not Puppet.Id then return end
        local FireWeapon = game.FireWeaponFromUnit or _G.FireWeaponFromUnit or rom.game.FireWeaponFromUnit
        if not FireWeapon then return end

        pcall(FireWeapon, {
            Id = Puppet.Id,
            Weapon = actionName,
            AutoEquip = true 
        })
    end

    return Puppet
end