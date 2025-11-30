local Registry = require("AnimRegistry")

return function(game)
    local Controller = {}
    Controller.__index = Controller

    function Controller.New()
        local self = setmetatable({}, Controller)
        
        self.CurrentFacing = 0
        self.LastPivotTime = 0
        self.PivotTimer = 0 
        self.LastTime = 0
        self.CurrentPivotAnim = nil
        self.LastAnim = ""
        self.CurrentWeapon = "NoWeapon"
        self.IsMoving = false
        self.HasInitialized = false
        
        -- Track the angle we were facing BEFORE the pivot started
        self.PivotStartAngle = 0
        
        return self
    end

    local function GetAngleDiff(a1, a2)
        local diff = a1 - a2
        return (diff + 180) % 360 - 180
    end

    function Controller:Update(remoteState, currentTime)
        if not remoteState or not remoteState.Vel then return nil end
        
        -- [[ INIT ]]
        if not self.HasInitialized then
            self.CurrentFacing = remoteState.Angle or 0
            self.HasInitialized = true
        end

        -- Time delta calculation
        local dt = 0
        if self.LastTime > 0 then dt = currentTime - self.LastTime end
        self.LastTime = currentTime
        
        -- Decrement Pivot Timer
        if self.PivotTimer > 0 then
            self.PivotTimer = self.PivotTimer - dt
        else
            self.CurrentPivotAnim = nil
        end

        -- 1. Determine Weapon
        local inferred = Registry.GuessWeapon(remoteState.Anim)
        if inferred ~= "NoWeapon" then self.CurrentWeapon = inferred end
        local animSet = Registry.GetSet(self.CurrentWeapon)
        local remoteAnim = remoteState.Anim or "Idle"

        -- 2. Non-Locomotion Override (Attacks, Emotes, etc.)
        if not Registry.IsLocomotion(remoteAnim) and remoteAnim ~= "Idle" then
            self.LastAnim = remoteAnim
            self.PivotTimer = 0 
            self.CurrentPivotAnim = nil
            self.CurrentFacing = remoteState.Angle 
            return { 
                Anim = remoteAnim, 
                Angle = remoteState.Angle, 
                Speed = 0, 
                ForcePlay = (self.LastAnim ~= remoteAnim)
            }
        end

        -- 3. Calculate Target State
        local vx, vy = remoteState.Vel.X, remoteState.Vel.Y
        local speed = math.sqrt(vx*vx + vy*vy)
        local targetAngle = remoteState.Angle or 0

        -- Variables to determine next frame's output
        local nextAnim = nil
        local nextAngle = targetAngle
        local nextSpeed = speed

        -- [[ STATE MACHINE ]]
        
        if self.PivotTimer > 0 and self.CurrentPivotAnim then
            -- STATE: LOCKED PIVOT
            -- While turning, we must send the pivot anim and lock the angle
            nextAnim = self.CurrentPivotAnim
            nextAngle = self.PivotStartAngle
            nextSpeed = 0
            
            -- We consider ourselves "moving" during a pivot, so we don't trigger "Stop" immediately after
            self.IsMoving = true 
        else
            -- STATE: NORMAL LOCOMOTION
            if speed > 10 then 
                local animToPlay = animSet.Run.Loop

                -- Filter Remote Animations to prevent "Double Turns"
                if Registry.IsLocomotion(remoteAnim) and remoteAnim ~= "Idle" then
                    local isTurn = string.find(remoteAnim, "Turn") or string.find(remoteAnim, "Pivot") or string.find(remoteAnim, "DirectionChange")
                    if not isTurn then
                        animToPlay = remoteAnim
                    end
                end

                -- Detect NEW Pivot
                local angleDiff = GetAngleDiff(targetAngle, self.CurrentFacing)
                local pivotCooldown = 0.5
                local triggeredPivot = nil
                local pivotDuration = 0

                if (currentTime - self.LastPivotTime > pivotCooldown) then
                    -- [[ THRESHOLD ADJUSTMENT ]]
                    -- Previous: > 150. New: > 130.
                    -- This ensures 135-degree turns (Cardinal <-> Diagonal) are treated as 180s.
                    if math.abs(angleDiff) > 130 and animSet.Run.Pivot180 then
                        
                        triggeredPivot = animSet.Run.Pivot180
                        pivotDuration = 0.35
                        
                        -- For 180/135 turns, snap to TARGET to avoid "Reverse" look at the end
                        self.PivotStartAngle = targetAngle

                    elseif math.abs(angleDiff) > 60 then
                        -- [[ 90 TURN LOGIC ]]
                        -- Previous: > 80. New: > 60 to catch standard 90s reliably.
                        
                        if angleDiff > 0 then 
                            triggeredPivot = animSet.Run.PivotRight -- Positive = Left Turn -> W90
                        else 
                            triggeredPivot = animSet.Run.PivotLeft -- Negative = Right Turn -> E90
                        end
                        pivotDuration = 0.25
                        
                        -- For 90 turns, lock to START so we turn "into" the new direction
                        self.PivotStartAngle = self.CurrentFacing
                    end
                end

                if triggeredPivot then
                    -- Trigger Pivot Start
                    self.CurrentPivotAnim = triggeredPivot
                    self.LastPivotTime = currentTime
                    self.PivotTimer = pivotDuration
                    
                    nextAnim = triggeredPivot
                    nextAngle = self.PivotStartAngle
                    nextSpeed = 0
                else
                    -- Standard Run
                    self.IsMoving = true
                    nextAnim = animToPlay
                    self.CurrentFacing = targetAngle -- Update facing to match target
                end

            else
                -- STATE: STOPPED
                if self.IsMoving then
                    nextAnim = animSet.Run.Stop
                    self.IsMoving = false
                else
                    nextAnim = animSet.Idle
                end
                
                nextSpeed = 0
                self.CurrentFacing = targetAngle 
            end
        end

        -- 4. Finalize Command & Deduplicate
        local command = { Angle = nextAngle, Speed = nextSpeed }

        if nextAnim == self.LastAnim then
            command.Anim = nil -- Don't resend the same animation (Fixes Flicker)
        else
            command.Anim = nextAnim
            self.LastAnim = nextAnim
        end

        return command
    end

    return Controller
end