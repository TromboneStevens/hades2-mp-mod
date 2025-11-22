-- src/PlayerTracker.lua
return function(game)
    local PlayerTracker = {}

    function PlayerTracker.GetHeroId()
        if game.GetActiveUnitId then return game.GetActiveUnitId() end
        if game.CurrentRun and game.CurrentRun.Hero then return game.CurrentRun.Hero.ObjectId end
        if game.CurrentHubRoom and game.CurrentHubRoom.Hero then return game.CurrentHubRoom.Hero.ObjectId end
        return nil
    end

    function PlayerTracker.GetState()
        local id = PlayerTracker.GetHeroId()
        if not id then return nil end

        local loc = game.GetLocation({ Id = id }) or { X = 0, Y = 0 }
        
        -- [[ CHANGE: Removed Z-Axis logic ]]

        local vel = { X = 0, Y = 0 }
        if game.GetVelocity then
            local vx, vy = game.GetVelocity({ Id = id })
            if type(vx) == "number" then
                vel = { X = vx, Y = vy or 0 }
            elseif type(vx) == "table" then
                vel = vx
            end
        end

        local angle = 0
        if game.GetAngle then
            angle = game.GetAngle({ Id = id }) or 0
        end

        local anim = "Idle"
        if game.GetAnimationName then
            anim = game.GetAnimationName({ Id = id }) or "Idle"
        end

        return {
            Id = id,
            Loc = { X = loc.X, Y = loc.Y }, -- No Z
            Vel = { X = vel.X, Y = vel.Y },
            Angle = angle,
            Anim = anim
        }
    end

    return PlayerTracker
end