-- src/Puppet.lua
local Animations = require("Animations")

return function(game, modutil)
    local Puppet = {}
    Puppet.Id = nil
    
    -- State Tracking
    Puppet.IsMoving = false
    Puppet.StopTimer = 0
    Puppet.CurrentFacing = 0
    Puppet.LastPivotTime = 0
    Puppet.CurrentGait = "Idle" -- "Idle", "Walk", "Run", "Sprint"
    Puppet.CurrentWeapon = "NoWeapon" 
    Puppet.LastSyncedAnim = ""

    function Puppet.Create(hero)
        if Puppet.Id then 
            print("[Puppet] Puppet.Id already exists: " .. tostring(Puppet.Id))
            return 
        end

        local SpawnObstacle = game.SpawnObstacle or _G.SpawnObstacle
        local SetThingProperty = game.SetThingProperty or _G.SetThingProperty
        local SetScale = game.SetScale or _G.SetScale
        local SetAnimation = game.SetAnimation or _G.SetAnimation

        if not SpawnObstacle then 
            print("[Puppet] Error: SpawnObstacle not found.")
            return 
        end

        local anchorId = hero and hero.ObjectId
        if not anchorId or anchorId == 0 then
            -- Fallback to ActiveUnitId if passed hero object is invalid
            anchorId = game.GetActiveUnitId and game.GetActiveUnitId()
        end

        if not anchorId or anchorId == 0 then
            print("[Puppet] Error: No valid anchor ID found for spawn.")
            return
        end

        -- Debug Check for Animations
        if not Animations or not Animations.Data or not Animations.Data.NoWeapon then
            print("[Puppet] Error: Animations data invalid or missing.")
            return
        end

        print("[Puppet] Attempting to spawn puppet near ID: " .. tostring(anchorId))

        -- 1. Spawn the Container
        local newId = SpawnObstacle({
            Name = "BlankObstacle3D", 
            Group = "Standing",
            DestinationId = anchorId,
            OffsetX = 150,
            OffsetY = 0
        })

        if newId and newId > 0 then
            Puppet.Id = newId
            
            -- 2. Apply Visual Model
            SetThingProperty({ Property = "GrannyModel", Value = "Melinoe_Mesh", DestinationId = Puppet.Id })
            
            if SetScale then
                SetScale({ Id = Puppet.Id, Fraction = 1.0 })
            end
            
            -- Set Initial Idle
            local idleAnim = Animations.Data.NoWeapon.Idle
            local success, err = pcall(SetAnimation, { Name = idleAnim, DestinationId = Puppet.Id })
            
            if not success then
                print("[Puppet] Warning: Failed to set initial idle: " .. tostring(err))
            end

            print("[Puppet] Spawned Melinoe Puppet (ID: " .. tostring(Puppet.Id) .. ")")
        else
            print("[Puppet] Error: SpawnObstacle failed (ID invalid).")
        end
    end

    function Puppet.Sync(state)
        if not Puppet.Id then return end
        if not state or not state.Vel then return end

        local Move = game.Move or _G.Move
        local Stop = game.Stop or _G.Stop
        local SetAngle = game.SetAngle or _G.SetAngle
        local SetAnimation = game.SetAnimation or _G.SetAnimation
        local GetTime = _G.GetTime or os.clock

        -- 1. Infer Weapon from the animation playing on the remote player
        --    This keeps the puppet holding the correct weapon even if we don't have explicit equip events.
        local remoteAnim = state.Anim or ""
        local inferredWeapon = Animations.GuessWeapon(remoteAnim)
        if inferredWeapon ~= "NoWeapon" then
            Puppet.CurrentWeapon = inferredWeapon
        end

        local currentAnimSet = Animations.Data[Puppet.CurrentWeapon] or Animations.Data.NoWeapon

        -- 2. Check if the player is doing an Action (Attack, Cast, Hit React)
        --    If so, we bypass the velocity logic and just play the animation.
        if not Animations.IsLocomotion(remoteAnim) and remoteAnim ~= "" and remoteAnim ~= "Idle" then
            
            -- Only set if it changed, to avoid restarting the animation every frame
            if Puppet.LastSyncedAnim ~= remoteAnim then
                pcall(SetAnimation, { Name = remoteAnim, DestinationId = Puppet.Id })
                Puppet.LastSyncedAnim = remoteAnim
                
                -- We DO NOT set IsMoving = false here anymore.
                -- This allows us to resume running smoothly if we attacked while moving.
            end

            -- Still update Position/Angle for sliding attacks or dashes
            local angle = state.Angle or 0
            if SetAngle then SetAngle({ Id = Puppet.Id, Angle = angle }) end
            
            local vx, vy = state.Vel.X, state.Vel.Y
            local speed = math.sqrt(vx*vx + vy*vy)
            if Move and speed > 10 then
                 Move({ Id = Puppet.Id, Angle = angle, Speed = speed, Duration = 0.1 })
            end

            return -- Exit early, don't run locomotion logic
        end

        -- 3. Locomotion Logic (Smoothing)
        --    If we are here, the remote player is Idle, Running, Sprinting, or Walking.
        
        local vx, vy = state.Vel.X, state.Vel.Y
        local speed = math.sqrt(vx*vx + vy*vy)
        local angle = state.Angle or 0
        local currentTime = GetTime()

        -- Helper: Calculate difference between two angles (-180 to 180)
        local function GetAngleDiff(a1, a2)
            local diff = a1 - a2
            return (diff + 180) % 360 - 180
        end

        if speed > 20 then
            -- Determine Gait
            local targetGait = "Run"
            local animData = currentAnimSet.Run -- Default to Run

            if speed < 250 then 
                targetGait = "Walk"
                animData = Animations.Data.NoWeapon.Run 
            elseif speed > 600 then 
                targetGait = "Sprint"
                animData = currentAnimSet.Sprint or currentAnimSet.Run
            end

            local angleDiff = GetAngleDiff(angle, Puppet.CurrentFacing)
            
            -- Handling Gait Changes and Starts
            if not Puppet.IsMoving then
                -- START from stop
                -- If we are already moving fast (e.g. resumed from an attack), skip the Start anim
                if speed > 150 then
                    pcall(SetAnimation, { Name = animData.Loop, DestinationId = Puppet.Id })
                else
                    pcall(SetAnimation, { Name = animData.Start or animData.Loop, DestinationId = Puppet.Id })
                end
                
                Puppet.IsMoving = true
                Puppet.CurrentGait = targetGait
                Puppet.LastSyncedAnim = animData.Loop -- Approximate

            elseif Puppet.CurrentGait ~= targetGait then
                -- CHANGE GAIT
                pcall(SetAnimation, { Name = animData.Loop, DestinationId = Puppet.Id })
                Puppet.CurrentGait = targetGait
                Puppet.LastSyncedAnim = animData.Loop

            elseif Puppet.LastSyncedAnim ~= animData.Loop and Puppet.LastSyncedAnim ~= animData.Start and not string.find(Puppet.LastSyncedAnim or "", "Turn") then
                -- RESUME LOOP: We are moving, gait matches, but animation is wrong (e.g. finished attacking)
                pcall(SetAnimation, { Name = animData.Loop, DestinationId = Puppet.Id })
                Puppet.LastSyncedAnim = animData.Loop
                
            -- PIVOT LOGIC
            elseif targetGait == "Run" and math.abs(angleDiff) > 150 and (currentTime - Puppet.LastPivotTime > 0.5) and animData.Pivot180 then
                pcall(SetAnimation, { Name = animData.Pivot180, DestinationId = Puppet.Id })
                Puppet.LastSyncedAnim = animData.Pivot180
                Puppet.LastPivotTime = currentTime
                
            elseif targetGait == "Run" and math.abs(angleDiff) > 80 and (currentTime - Puppet.LastPivotTime > 0.5) then
                if angleDiff > 0 and animData.PivotRight then
                    pcall(SetAnimation, { Name = animData.PivotRight, DestinationId = Puppet.Id })
                    Puppet.LastSyncedAnim = animData.PivotRight
                elseif animData.PivotLeft then
                    pcall(SetAnimation, { Name = animData.PivotLeft, DestinationId = Puppet.Id })
                    Puppet.LastSyncedAnim = animData.PivotLeft
                end
                Puppet.LastPivotTime = currentTime
            end
            
            -- Physics Update
            Puppet.CurrentFacing = angle
            Puppet.StopTimer = 0

            if Move then
                Move({ Id = Puppet.Id, Angle = angle, Speed = speed, Duration = 0.1 })
            end
            
            if SetAngle then
                SetAngle({ Id = Puppet.Id, Angle = angle })
            end

        else
            -- STATE: STOPPED
            local stopAnim = currentAnimSet.Run.Stop 
            if Puppet.CurrentGait == "Sprint" and currentAnimSet.Sprint then
                stopAnim = currentAnimSet.Sprint.Stop or stopAnim
            end

            if Puppet.IsMoving then
                -- Just stopped moving
                pcall(SetAnimation, { Name = stopAnim, DestinationId = Puppet.Id })
                
                Puppet.IsMoving = false
                Puppet.CurrentGait = "Idle"
                Puppet.StopTimer = 0.3
                Puppet.LastSyncedAnim = stopAnim
            else
                -- ALREADY STOPPED: Check if we need to return to Idle (e.g. after Attack finished)
                local idleAnim = currentAnimSet.Idle
                if Puppet.StopTimer <= 0 and Puppet.LastSyncedAnim ~= idleAnim then
                     pcall(SetAnimation, { Name = idleAnim, DestinationId = Puppet.Id })
                     Puppet.LastSyncedAnim = idleAnim
                end
            end
            
            -- Return to Idle after stop anim finishes
            if Puppet.StopTimer > 0 then
                Puppet.StopTimer = Puppet.StopTimer - 0.03
                if Puppet.StopTimer <= 0 then
                    pcall(SetAnimation, { Name = currentAnimSet.Idle, DestinationId = Puppet.Id })
                    Puppet.LastSyncedAnim = currentAnimSet.Idle
                end
            end

            -- Kill velocity
            if Stop then Stop({ Id = Puppet.Id }) end
        end
    end

    -- Allow manual triggers from hooks if needed
    function Puppet.Mimic(animName)
        if Puppet.Id then
            pcall(game.SetAnimation, { Name = animName, DestinationId = Puppet.Id })
            Puppet.LastSyncedAnim = animName
        end
    end

    return Puppet
end