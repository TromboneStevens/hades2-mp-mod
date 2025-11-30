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
        
        -- New: Track the angle we were facing BEFORE the pivot started
        self.PivotStartAngle = 0
        
        return self
    end

    local function GetAngleDiff(a1, a2)
        local diff = a1 - a2
        return (diff + 180) % 360 - 180
    end

    function Controller:Update(remoteState, currentTime)
        if not remoteState or not remoteState.Vel then return nil end
        
        local dt = 0
        if self.LastTime > 0 then dt = currentTime - self.LastTime end
        self.LastTime = currentTime
        
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

        -- 2. Non-Locomotion Override
        if not Registry.IsLocomotion(remoteAnim) and remoteAnim ~= "Idle" then
            self.LastAnim = remoteAnim
            self.PivotTimer = 0 
            self.CurrentPivotAnim = nil
            return { 
                Anim = remoteAnim, 
                Angle = remoteState.Angle, 
                Speed = 0, 
                ForcePlay = (self.LastAnim ~= remoteAnim)
            }
        end

        -- 3. Locomotion Logic
        local vx, vy = remoteState.Vel.X, remoteState.Vel.Y
        local speed = math.sqrt(vx*vx + vy*vy)
        local targetAngle = remoteState.Angle or 0
        
        -- [[ PIVOT LOCK ]]
        -- If locked, we MUST return the OLD angle (PivotStartAngle).
        -- If we send 'targetAngle' (the new direction), the model snaps instantly,
        -- defeating the purpose of the turn animation.
        if self.PivotTimer > 0 and self.CurrentPivotAnim then
            return {
                Anim = self.CurrentPivotAnim,
                Angle = self.PivotStartAngle, -- Keep facing the OLD way while turning
                Speed = 0 -- Usually pivots happen in place or with root motion
            }
        end

        local command = { Angle = targetAngle, Speed = speed }

        -- 4. Movement Logic (Simplified)
        if speed > 10 then 
            
            -- Default: Run Loop
            local animToPlay = animSet.Run.Loop

            -- Override if remote is sending a specific locomotion anim
            if Registry.IsLocomotion(remoteAnim) and remoteAnim ~= "Idle" then
                animToPlay = remoteAnim
            end

            -- [[ PIVOT DETECTION ]]
            local angleDiff = GetAngleDiff(targetAngle, self.CurrentFacing)
            
            -- 180 Turn
            if math.abs(angleDiff) > 150 and (currentTime - self.LastPivotTime > 0.5) then
                if animSet.Run.Pivot180 then
                    self.CurrentPivotAnim = animSet.Run.Pivot180
                    self.LastPivotTime = currentTime
                    self.PivotTimer = 0.35
                    self.PivotStartAngle = self.CurrentFacing -- Capture current angle
                    
                    -- Immediately return the pivot command to ensure it starts NOW
                    return {
                        Anim = self.CurrentPivotAnim,
                        Angle = self.PivotStartAngle,
                        Speed = 0
                    }
                end
                
            -- 90 Turn
            elseif math.abs(angleDiff) > 80 and (currentTime - self.LastPivotTime > 0.5) then
                local turnAnim = nil
                if angleDiff > 0 then
                    turnAnim = animSet.Run.PivotLeft
                else
                    turnAnim = animSet.Run.PivotRight
                end
                
                if turnAnim then
                    self.CurrentPivotAnim = turnAnim
                    self.LastPivotTime = currentTime
                    self.PivotTimer = 0.25
                    self.PivotStartAngle = self.CurrentFacing -- Capture current angle

                    return {
                        Anim = self.CurrentPivotAnim,
                        Angle = self.PivotStartAngle,
                        Speed = 0
                    }
                end
            end

            self.IsMoving = true
            command.Anim = animToPlay
            self.CurrentFacing = targetAngle

        else
            -- STOPPED
            if self.IsMoving then
                command.Anim = animSet.Run.Stop
                self.IsMoving = false
            else
                command.Anim = animSet.Idle
            end
            command.Speed = 0
        end

        if command.Anim == self.LastAnim and not command.ForcePlay then
            command.Anim = nil 
        else
            self.LastAnim = command.Anim
        end

        return command
    end

    return Controller
end