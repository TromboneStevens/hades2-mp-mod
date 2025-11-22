return function(game, modutil)
    local Puppet = {}
    Puppet.Id = nil
    Puppet.CurrentAnim = "MelinoeIdle" 

    function Puppet.Create(hero)
        if Puppet.Id then return end
        
        local SpawnUnit = game.SpawnUnit or _G.SpawnUnit or rom.game.SpawnUnit
        if not SpawnUnit then return end

        -- 1. REVERT TO NEMESIS (Stable Rig)
        local targetUnit = "NPC_Nemesis_01" 
        
        print("[Puppet] Spawning Base Unit: " .. targetUnit)
        
        local spawnResult = SpawnUnit({
            Name = targetUnit,
            Group = "Standing",
            DestinationId = hero.ObjectId,
            OffsetX = -100, 
            OffsetY = 0
        })
        
        local pId = (type(spawnResult) == "number") and spawnResult or (spawnResult and spawnResult.ObjectId)
        
        if pId and pId > 0 then
            print("[Puppet] SUCCESS: Puppet ID: " .. tostring(pId))
            Puppet.Id = pId
            
            -- 2. LOBOTOMY (Disable AI & Interactions)
            if game.SetUnitProperty then
                game.SetUnitProperty({ Id = pId, Property = "Speed", Value = 0 })
                game.SetUnitProperty({ Id = pId, Property = "CollideWithUnits", Value = false })
                game.SetUnitProperty({ Id = pId, Property = "ImmuneToStun", Value = true })
                game.SetUnitProperty({ Id = pId, Property = "IsInvulnerable", Value = true })
                game.SetUnitProperty({ Id = pId, Property = "UseHitShield", Value = false })
            end

            if game.UseableOff then
                game.UseableOff({ Id = pId })
            end
            
            -- 3. DYNAMIC VISUAL CLONING & DEBUGGING
            -- We log the hero's visual state to finding out what's missing.
            if game.SetThingProperty then
                 -- Reset basics
                 game.SetThingProperty({ Id = pId, Property = "Scale", Value = 1.0 }) 
                 game.SetThingProperty({ Id = pId, Property = "Color", Value = {255, 255, 255, 255} })
                 
                 -- DEBUG LOGGING
                 print("[Puppet] DEBUG: Scanning Hero Visuals...")
                 print("[Puppet] Hero.Graphic: " .. tostring(hero.Graphic))
                 print("[Puppet] Hero.Animation: " .. tostring(hero.Animation))
                 if game.GetAnimationName then
                    print("[Puppet] Hero.GetAnimationName: " .. tostring(game.GetAnimationName({ Id = hero.ObjectId })))
                 end

                 -- Try to copy specific visual properties
                 if hero.Graphic then
                    print("[Puppet] Applying Hero.Graphic: " .. tostring(hero.Graphic))
                    game.SetThingProperty({ Id = pId, Property = "Graphic", Value = hero.Graphic })
                 else
                    -- Fallback: Force the known good animation as the graphic state
                    print("[Puppet] Hero.Graphic is NIL. Defaulting to MelinoeIdle.")
                    game.SetThingProperty({ Id = pId, Property = "Graphic", Value = "MelinoeIdle" })
                 end

                 game.SetThingProperty({ Id = pId, Property = "AnimOffsetZ", Value = 0 })
            end
            
            -- 4. ANIMATION PERSISTENCE LOOP
            thread(function()
                if game.SetAnimation then
                    game.StopAnimation({ DestinationId = pId })
                    game.SetAnimation({ Name = "MelinoeIdle", DestinationId = pId })
                end

                while Puppet.Id == pId and game.IsAlive({ Id = pId }) do
                    local current = "Unknown"
                    if game.GetAnimationName then
                         current = game.GetAnimationName({ Id = pId })
                    end
                    
                    if current ~= Puppet.CurrentAnim then
                         if game.SetAnimation then
                            game.SetAnimation({ Name = Puppet.CurrentAnim, DestinationId = pId })
                         end
                         -- Re-assert Graphic
                         if game.SetThingProperty then
                            -- Use whatever value worked (hero.Graphic or fallback)
                            local targetGraphic = hero.Graphic or "MelinoeIdle"
                            game.SetThingProperty({ Id = pId, Property = "Graphic", Value = targetGraphic })
                         end
                    end
                    
                    wait(0.1) 
                end
            end)

        else
            print("[Puppet] FAIL: Puppet failed to spawn.")
        end
    end

    function Puppet.Mimic(actionName)
        if not Puppet.Id then return end
        
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