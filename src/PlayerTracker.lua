-- src/PlayerTracker.lua

-- We return a "Constructor" function that takes the 'game' object
return function(game)
    local PlayerTracker = {}

    -- Helper to find the Hero ID in any game state (Run or Hub)
    function PlayerTracker.GetHeroId()
        -- Method 1: Engine Direct (Most reliable)
        if game.GetActiveUnitId then 
            return game.GetActiveUnitId() 
        end
        
        -- Method 2: Active Run Data
        if game.CurrentRun and game.CurrentRun.Hero then 
            return game.CurrentRun.Hero.ObjectId 
        end
        
        -- Method 3: Hub/Crossroads Data
        if game.CurrentHubRoom and game.CurrentHubRoom.Hero then 
            return game.CurrentHubRoom.Hero.ObjectId 
        end
        
        return nil
    end

    -- The main function to get coordinates
    function PlayerTracker.GetPosition()
        local id = PlayerTracker.GetHeroId()
        
        if id and game.GetLocation then
            -- Use the "Named Argument Table" syntax we discovered
            local loc = game.GetLocation({ Id = id })
            
            if loc then
                return loc.X or loc.x, loc.Y or loc.y
            end
        end
        
        return nil, nil
    end

    return PlayerTracker
end