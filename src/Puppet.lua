-- src/Puppet.lua
local Animations = require("Animations") -- Import our new animation database

return function(game, modutil)
    local Puppet = {}
    Puppet.Id = nil
    
    -- State Tracking
    Puppet.IsMoving = false
    Puppet.StopTimer = 0
    Puppet.CurrentFacing = 0
    Puppet.LastPivotTime = 0
    Puppet.CurrentGait = "Idle" -- "Idle", "Walk", "Run", "Sprint"

    function Puppet.Create(hero)
        if Puppet.Id then return end

        local SpawnObstacle = game.SpawnObstacle or _G.SpawnObstacle
        local SetThingProperty = game.SetThingProperty or _G.SetThingProperty
        local SetScale = game.SetScale or _G.SetScale
        local SetAnimation = game.SetAnimation or _G.SetAnimation

        if not SpawnObstacle then return end

        local anchorId = hero and hero.ObjectId or 0

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
                SetScale({ Id = Puppet.Id, Fraction = 0.7 })
            end
            
            -- Set Initial Idle
            pcall(SetAnimation, { Name = Animations.Idle, DestinationId = Puppet.Id })

            print("[Puppet] Spawned Melinoe Puppet (ID: " .. tostring(Puppet.Id) .. ")")
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

        local vx, vy = state.Vel.X, state.Vel.Y
        local speed = math.sqrt(vx*vx + vy*vy)
        local angle = state.Angle or 0
        
        -- Helper: Calculate difference between two angles (-180 to 180)
        local function GetAngleDiff(a1, a2)
            local diff = a1 - a2
            return (diff + 180) % 360 - 180
        end

        -- [[ STATE MACHINE ]]
        if speed > 20 then
            -- Determine Gait based on speed
            -- Native Speeds: Walk (~120), Run (540), Sprint (740)
            local targetGait = "Run"
            local animSet = Animations.Locomotion.Run -- Default

            if speed < 250 then 
                targetGait = "Walk"
                animSet = Animations.Locomotion.Walk
            elseif speed > 600 then 
                targetGait = "Sprint"
                animSet = Animations.Locomotion.Sprint
            end

            local angleDiff = GetAngleDiff(angle, Puppet.CurrentFacing)
            local currentTime = GetTime()
            
            -- Handling Gait Changes and Starts
            if not Puppet.IsMoving then
                -- EVENT: START (From Idle)
                pcall(SetAnimation, { Name = animSet.Start, DestinationId = Puppet.Id })
                Puppet.IsMoving = true
                Puppet.CurrentGait = targetGait

            elseif Puppet.CurrentGait ~= targetGait then
                -- EVENT: GAIT CHANGE (While Moving, e.g. Run -> Sprint)
                pcall(SetAnimation, { Name = animSet.Loop, DestinationId = Puppet.Id })
                Puppet.CurrentGait = targetGait
                
            -- PIVOT LOGIC (Mostly for Running)
            -- Only Run has pivot animations defined in our table currently
            elseif targetGait == "Run" and math.abs(angleDiff) > 150 and (currentTime - Puppet.LastPivotTime > 0.5) then
                -- EVENT: PIVOT 180
                pcall(SetAnimation, { Name = Animations.Locomotion.Run.Pivot.Turn180, DestinationId = Puppet.Id })
                Puppet.LastPivotTime = currentTime
                
            elseif targetGait == "Run" and math.abs(angleDiff) > 80 and (currentTime - Puppet.LastPivotTime > 0.5) then
                -- EVENT: PIVOT 90 (Left/Right)
                if angleDiff > 0 then
                    pcall(SetAnimation, { Name = Animations.Locomotion.Run.Pivot.TurnRight90, DestinationId = Puppet.Id })
                else
                    pcall(SetAnimation, { Name = Animations.Locomotion.Run.Pivot.TurnLeft90, DestinationId = Puppet.Id })
                end
                Puppet.LastPivotTime = currentTime
            end
            
            -- Always update facing and physics
            Puppet.CurrentFacing = angle
            Puppet.StopTimer = 0

            if Move then
                Move({ 
                    Id = Puppet.Id, 
                    Angle = angle, 
                    Speed = speed, 
                    EaseIn = 0, 
                    EaseOut = 0, 
                    Duration = 0.1 
                })
            end
            
            if SetAngle then
                SetAngle({ Id = Puppet.Id, Angle = angle })
            end

        else
            -- STATE: STOPPED
            
            if Puppet.IsMoving then
                -- EVENT: STOP
                local stopAnim = Animations.Locomotion.Run.Stop -- Default fallback
                
                if Puppet.CurrentGait == "Walk" then
                    stopAnim = Animations.Locomotion.Walk.Stop
                elseif Puppet.CurrentGait == "Sprint" then
                     -- Often falls back to Run stop if SprintStop doesn't exist, but we have it defined
                    stopAnim = Animations.Locomotion.Sprint.Stop or Animations.Locomotion.Run.Stop
                end

                pcall(SetAnimation, { Name = stopAnim, DestinationId = Puppet.Id })
                
                Puppet.IsMoving = false
                Puppet.CurrentGait = "Idle"
                Puppet.StopTimer = 0.3
            end
            
            -- Handle Return to Idle
            if Puppet.StopTimer > 0 then
                Puppet.StopTimer = Puppet.StopTimer - 0.03
                if Puppet.StopTimer <= 0 then
                    pcall(SetAnimation, { Name = Animations.Idle, DestinationId = Puppet.Id })
                end
            end

            -- Kill physics velocity
            if Stop then
                Stop({ Id = Puppet.Id })
            elseif Move then
                Move({ Id = Puppet.Id, Speed = 0, Angle = angle, Duration = 0.1 })
            end
        end
    end

    return Puppet
end