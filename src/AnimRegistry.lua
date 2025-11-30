local AnimRegistry = {}

-- Load weapon modules
-- Ensure these files exist in src/Weapons/
AnimRegistry.Data = {
    NoWeapon = require("Weapons.NoWeapon"),
    Staff = require("Weapons.Staff"),
    Dagger = require("Weapons.Dagger"),
    Axe = require("Weapons.Axe"),
    Torch = require("Weapons.Torch"),
    Lob = require("Weapons.Lob"),
    Suit = require("Weapons.Suit"),
}

-- Locomotion lookup for filtering attacks
local LocomotionSet = {}
local function RegisterLocomotion(animName) 
    if animName then LocomotionSet[animName] = true end 
end

for _, weapon in pairs(AnimRegistry.Data) do
    if weapon.Idle then RegisterLocomotion(weapon.Idle) end
    if weapon.Run then
        for _, anim in pairs(weapon.Run) do RegisterLocomotion(anim) end
    end
    if weapon.Sprint then
        for _, anim in pairs(weapon.Sprint) do RegisterLocomotion(anim) end
    end
end
-- Generics
RegisterLocomotion("MelinoeWalk")
RegisterLocomotion("MelinoeWalkStart")
RegisterLocomotion("MelinoeWalkStop")

function AnimRegistry.IsLocomotion(animName)
    return LocomotionSet[animName] == true
end

function AnimRegistry.GuessWeapon(animName)
    if not animName then return "NoWeapon" end
    if string.find(animName, "_Staff_") then return "Staff" end
    if string.find(animName, "_Dagger_") then return "Dagger" end
    if string.find(animName, "_Axe_") then return "Axe" end
    if string.find(animName, "_Torch_") then return "Torch" end
    if string.find(animName, "_Lob_") then return "Lob" end
    if string.find(animName, "_Suit_") then return "Suit" end
    return "NoWeapon"
end

function AnimRegistry.GetSet(weaponName)
    return AnimRegistry.Data[weaponName] or AnimRegistry.Data.NoWeapon
end

return AnimRegistry