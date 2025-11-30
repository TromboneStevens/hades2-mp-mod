local AnimControllerFactory = require("AnimController")

return function(game, modutil)
    local Puppet = {}
    Puppet.Id = nil
    Puppet.Controller = nil

    function Puppet.Create(hero)
        if Puppet.Id then return end

        local anchorId = hero and hero.ObjectId or game.GetActiveUnitId()
        if not anchorId then return end

        Puppet.Id = game.SpawnObstacle({
            Name = "BlankObstacle3D", 
            Group = "Standing",
            DestinationId = anchorId,
            OffsetX = 150,
            OffsetY = 0
        })

        if Puppet.Id and Puppet.Id > 0 then
            game.SetThingProperty({ Property = "GrannyModel", Value = "Melinoe_Mesh", DestinationId = Puppet.Id })
            game.SetScale({ Id = Puppet.Id, Fraction = 1.0 })
            
            Puppet.Controller = AnimControllerFactory(game).New()
            
            print("[Puppet] Spawned Melinoe Puppet (ID: " .. tostring(Puppet.Id) .. ")")
        end
    end

    function Puppet.Sync(state)
        if not Puppet.Id or not Puppet.Controller then return end
        
        -- Update the controller to calculate the desired animation and physics state
        local cmd = Puppet.Controller:Update(state, _G.GetTime())
        if not cmd then return end

        -- 1. Apply Animation
        if cmd.Anim then
            pcall(game.SetAnimation, { Name = cmd.Anim, DestinationId = Puppet.Id })
        end

        -- 2. Apply Movement & Rotation
        -- CRITICAL FIX: We must apply SetAngle even if Speed is 0.
        -- Pivot animations require the model to face the 'Old' direction while playing the 'Turn' animation.
        -- If we don't enforce this, the game engine might snap the rotation to the new input vector immediately,
        -- causing the turn animation to play in the wrong direction (jittering).
        
        game.SetAngle({ Id = Puppet.Id, Angle = cmd.Angle })

        if cmd.Speed > 0 then
            game.Move({ Id = Puppet.Id, Angle = cmd.Angle, Speed = cmd.Speed, Duration = 0.1 })
        else
            game.Stop({ Id = Puppet.Id })
        end
    end

    function Puppet.Mimic(animName)
        if Puppet.Id then
            pcall(game.SetAnimation, { Name = animName, DestinationId = Puppet.Id })
            if Puppet.Controller then
                Puppet.Controller.LastAnim = animName
            end
        end
    end

    return Puppet
end