-- src/Puppet.lua
return function(game, modutil)
    local Puppet = {}
    Puppet.Id = nil

    function Puppet.Create(hero)
        if Puppet.Id then return end

        local SpawnObstacle = game.SpawnObstacle or _G.SpawnObstacle
        local SetThingProperty = game.SetThingProperty or _G.SetThingProperty
        local SetAnimation = game.SetAnimation or _G.SetAnimation

        if not SpawnObstacle then return end

        local anchorId = hero and hero.ObjectId or 0

		-- Using SpawnObstacle instead of SpawnUnit to ensure its as bare bones as possible
        local newId = SpawnObstacle({
            Name = "BlankObstacle3D", -- A standard empty container
            Group = "Standing",
            DestinationId = anchorId,
            OffsetX = 150,
            OffsetY = 0
        })

        if newId and newId > 0 then
            Puppet.Id = newId
            
            -- Swap mesh to Melinoe
            SetThingProperty({ Property = "GrannyModel", Value = "Melinoe_Mesh", DestinationId = Puppet.Id })

            -- Set scale/anim to make it look right
            SetThingProperty({ Property = "Scale", Value = 0.7, DestinationId = Puppet.Id })
            SetAnimation({ Name = "MelinoeIdle", DestinationId = Puppet.Id })

            print("[Puppet] Spawned Melinoe Puppet ID: " .. tostring(Puppet.Id))
        end
    end

    function Puppet.Mimic(animName)
        if not Puppet.Id then return end
        local SetAnimation = game.SetAnimation or _G.SetAnimation

        if animName then
            if not string.find(animName, "Melinoe") then
                animName = "Melinoe" .. animName
            end
            pcall(SetAnimation, { Name = animName, DestinationId = Puppet.Id })
        end
    end

    return Puppet
end