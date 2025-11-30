local Registry = require("AnimRegistry")

return function(game)
    local Controller = {}
    Controller.__index = Controller

    function Controller.New()
        local self = setmetatable({}, Controller)
        
        -- Logic State
        self.CurrentGait = "Idle"
        self.CurrentFacing = 0
        self.LastPivotTime = 0
        self.StopTimer = 0
        self.IsMoving = false
        self.LastAnim = ""
        self.CurrentWeapon = "NoWeapon"
        
        return self
    end

    local function GetAngleDiff(a1, a2)
        local diff = a1 - a2
        return (diff + 180) % 360 - 180
    end

    -- [[ CHANGE: Changed '.' to ':' to implicitly pass 'self' ]]
    function Controller:Update(remoteState, currentTime)
        if not remoteState or not remoteState.Vel then return nil end

        -- 1. Detect Weapon
        local inferred = Registry.GuessWeapon(remoteState.Anim)
        if inferred ~= "NoWeapon" then self.CurrentWeapon = inferred end
        
        local animSet = Registry.GetSet(self.CurrentWeapon)
        local remoteAnim = remoteState.Anim or "Idle"

        -- 2. Direct Override (Attacks/HitReacts)
        if not Registry.IsLocomotion(remoteAnim) and remoteAnim ~= "Idle" then
            self.LastAnim = remoteAnim
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
        
        local command = { Angle = targetAngle, Speed = speed }

        if speed > 20 then
            -- MOVING
            local targetGait = "Run"
            local specificSet = animSet.Run

            if speed < 250 then 
                targetGait = "Walk"
                specificSet = Registry.Data.NoWeapon.Run 
            elseif speed > 600 then 
                targetGait = "Sprint"
                specificSet = animSet.Sprint or animSet.Run
            end

            local angleDiff = GetAngleDiff(targetAngle, self.CurrentFacing)
            local animToPlay = specificSet.Loop

            if not self.IsMoving then
                -- Start
                animToPlay = (speed > 150) and specificSet.Loop or (specificSet.Start or specificSet.Loop)
                self.IsMoving = true
                self.CurrentGait = targetGait
            elseif self.CurrentGait ~= targetGait then
                -- Gait Change
                animToPlay = specificSet.Loop
                self.CurrentGait = targetGait
            elseif math.abs(angleDiff) > 150 and (currentTime - self.LastPivotTime > 0.5) and specificSet.Pivot180 then
                -- 180 Turn
                animToPlay = specificSet.Pivot180
                self.LastPivotTime = currentTime
            elseif math.abs(angleDiff) > 80 and (currentTime - self.LastPivotTime > 0.5) then
                -- 90 Turn
                if angleDiff > 0 and specificSet.PivotRight then
                    animToPlay = specificSet.PivotRight
                elseif specificSet.PivotLeft then
                    animToPlay = specificSet.PivotLeft
                end
                self.LastPivotTime = currentTime
            end

            command.Anim = animToPlay
            self.CurrentFacing = targetAngle
            self.StopTimer = 0
        else
            -- STOPPED
            if self.IsMoving then
                local stopAnim = animSet.Run.Stop
                if self.CurrentGait == "Sprint" and animSet.Sprint then
                    stopAnim = animSet.Sprint.Stop or stopAnim
                end
                command.Anim = stopAnim
                self.IsMoving = false
                self.CurrentGait = "Idle"
                self.StopTimer = 0.3
            else
                if self.StopTimer <= 0 then
                    command.Anim = animSet.Idle
                else
                    self.StopTimer = self.StopTimer - 0.03
                end
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