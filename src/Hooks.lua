-- src/Hooks.lua
return function(game, modutil, NetworkManager)
    
    local function SendEvent(eventType, data)
        if NetworkManager then
            -- Simple format: "EVENT_TYPE:WeaponName"
            local packet = string.format("%s:%s", eventType, data)
            print("[Hades2MP] Sending: " .. packet)
            NetworkManager.SendString(packet) 
        end
    end

    local function GetHero()
        if game.CurrentRun then return game.CurrentRun.Hero end
        if game.CurrentHubRoom then return game.CurrentHubRoom.Hero end
        return nil
    end

    -- Robust check to see if a table is the Hero
    local function IsHero(t)
        local hero = GetHero()
        if not hero then return false end
        -- Check 1: Is it the hero table itself?
        if t == hero then return true end
        -- Check 2: Does it match IDs?
        if t.ObjectId and t.ObjectId == hero.ObjectId then return true end
        if t.OwnerId and t.OwnerId == hero.ObjectId then return true end
        return false
    end

    -- Debounce Memory
    -- We store the last time we sent an event for each weapon
    local last_weapon_time = {}
    local DEBOUNCE_TIME = 0.2 -- 200ms cooldown between sending the same action

    -- [[ THE UNIVERSAL HOOK ]]
    modutil.mod.Path.Wrap("GetWeaponData", function(base, unit, weaponName, ...)
        local result = base(unit, weaponName, ...)
        
        -- 1. Is the Hero asking for this data?
        if IsHero(unit) and type(weaponName) == "string" then
            
            -- 2. Debounce check (GetWeaponData fires 3-4 times per click)
            local now = os.clock()
            local last = last_weapon_time[weaponName] or 0

            if now - last > DEBOUNCE_TIME then
                last_weapon_time[weaponName] = now
                
                -- 3. Classify Event
                if weaponName == "WeaponSprint" or weaponName == "WeaponBlink" then
                     -- We already track Dash position updates, but this is the "Event"
                     SendEvent("DASH", weaponName)
                elseif string.find(weaponName, "Cast") then
                     SendEvent("CAST", weaponName)
                else
                     SendEvent("ATTACK", weaponName)
                end
            end
        end
        
        return result
    end)

    print("[Hades2MP] Hooks Initialized (Universal Method)")
end