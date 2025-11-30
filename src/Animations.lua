-- src/Animations.lua
-- Database of Animation Names per Weapon

local Animations = {}

Animations.Data = {
    -- [[ NO WEAPON / DEFAULT ]]
    NoWeapon = {
        Idle = "MelinoeIdle",
        Run = {
            Start = "MelinoeStart",
            Loop = "MelinoeRun",
            Stop = "MelinoeStop",
            Pivot180 = "MelinoeRunDirectionChange180",
            PivotLeft = "MelinoeRunDirectionChangeE90",
            PivotRight = "MelinoeRunDirectionChangeW90",
        },
        Sprint = {
            Start = "MelinoeSprint",
            Loop = "MelinoeSprint",
            Stop = "MelinoeStop",
        }
    },

    -- [[ STAFF ]]
    Staff = {
        Idle = "Melinoe_Staff_Idle",
        Run = {
            Start = "Melinoe_Staff_Run_Start",
            Loop = "Melinoe_Staff_Run_FireLoop",
            Stop = "Melinoe_Staff_Run_End",
            Pivot180 = "Melinoe_Staff_Turn_180",
            PivotLeft = "Melinoe_Staff_Turn_E90",
            PivotRight = "Melinoe_Staff_Turn_W90",
        },
        Sprint = {
            Start = "Melinoe_Staff_Sprint_FireLoop",
            Loop = "Melinoe_Staff_Sprint_FireLoop",
            Stop = "Melinoe_Staff_Run_End",
            Pivot180 = "Melinoe_Staff_SprintTurn_180",
            PivotLeft = "Melinoe_Staff_SprintTurn_E90",
            PivotRight = "Melinoe_Staff_SprintTurn_W90",
        },
        Dash = { Start = "Melinoe_Staff_Dash_Start", Fire = "Melinoe_Staff_Dash_Fire", Stop = "Melinoe_Staff_Dash_End2" }
    },

    -- [[ DAGGER ]]
    Dagger = {
        Idle = "Melinoe_Dagger_Idle",
        Run = {
            Start = "Melinoe_Dagger_Run_Start",
            Loop = "Melinoe_Dagger_Run_FireLoop",
            Stop = "Melinoe_Dagger_Run_End",
            Pivot180 = "Melinoe_Dagger_Turn_180",
            PivotLeft = "Melinoe_Dagger_Turn_E90",
            PivotRight = "Melinoe_Dagger_Turn_W90",
        },
        Sprint = {
            Start = "Melinoe_Dagger_Sprint_FireLoop",
            Loop = "Melinoe_Dagger_Sprint_FireLoop",
            Stop = "Melinoe_Dagger_Run_End",
            Pivot180 = "Melinoe_Dagger_SprintTurn_180",
            PivotLeft = "Melinoe_Dagger_SprintTurn_E90",
            PivotRight = "Melinoe_Dagger_SprintTurn_W90",
        },
        Dash = { Start = "Melinoe_Dagger_Dash_Start", Fire = "Melinoe_Dagger_Dash_Fire", Stop = "Melinoe_Dagger_Dash_End2" },
        
        -- Attacks from Hero_Melinoe_Dagger_Attacks_Animation.sjson
        Attacks = {
            Attack1 = { Start = "Melinoe_Dagger_AttackRight_Start", Fire = "Melinoe_Dagger_AttackRight_Fire", End = "Melinoe_Dagger_AttackRight_End" }, -- Melee1
            Attack2 = { Start = "Melinoe_Dagger_AttackLeft_Start", Fire = "Melinoe_Dagger_AttackLeft_Fire", End = "Melinoe_Dagger_AttackLeft_End" }, -- Melee2
            Spin = { Start = "Melinoe_Dagger_AttackSpin_Start", Fire = "Melinoe_Dagger_AttackSpin_Fire", End = "Melinoe_Dagger_AttackSpin_End" }, -- Melee4
            MultiStab = { Start = "Melinoe_Dagger_AttackStabs_Start", Fire = "Melinoe_Dagger_AttackStabs_Fire", Loop = "Melinoe_Dagger_AttackStabs_FireLoop", End = "Melinoe_Dagger_AttackStabs_End" }, -- Melee5
            Double = { Start = "Melinoe_Dagger_AttackDouble_Start", Fire = "Melinoe_Dagger_AttackDouble_Fire", End = "Melinoe_Dagger_AttackDouble_End" }, -- Melee6
            Blink = { Start = "Melinoe_Dagger_AttackEx1_Start", Fire = "Melinoe_Dagger_AttackEx1_Fire", End = "Melinoe_Dagger_AttackEx1_End" }, -- Ex1
            Special = { Start = "Melinoe_Dagger_Special_Start", Fire = "Melinoe_Dagger_Special_Fire", End = "Melinoe_Dagger_Special_End" },
            SpecialEx = { Fire = "Melinoe_Dagger_SpecialEx_Fire", End = "Melinoe_Dagger_SpecialEx_End" }
        }
    },

    -- [[ AXE ]]
    Axe = {
        Idle = "Melinoe_Axe_Idle",
        Run = {
            Start = "Melinoe_Axe_Run_Start",
            Loop = "Melinoe_Axe_Run_FireLoop",
            Stop = "Melinoe_Axe_Run_End",
            Pivot180 = "Melinoe_Axe_Turn_180",
            PivotLeft = "Melinoe_Axe_Turn_E90",
            PivotRight = "Melinoe_Axe_Turn_W90",
        },
        Sprint = {
            Start = "Melinoe_Axe_Sprint_FireLoop",
            Loop = "Melinoe_Axe_Sprint_FireLoop",
            Stop = "Melinoe_Axe_Run_End",
            Pivot180 = "Melinoe_Axe_SprintTurn_180",
            PivotLeft = "Melinoe_Axe_SprintTurn_E90",
            PivotRight = "Melinoe_Axe_SprintTurn_W90",
        },
        Dash = { Start = "Melinoe_Axe_Dash_Start", Fire = "Melinoe_Axe_Dash_Fire", Stop = "Melinoe_Axe_Dash_End2" }
    },

    -- [[ TORCH ]]
    Torch = {
        Idle = "Melinoe_Torch_Idle",
        Run = {
            Start = "Melinoe_Torch_Run_Start",
            Loop = "Melinoe_Torch_Run_FireLoop",
            Stop = "Melinoe_Torch_Run_End",
            Pivot180 = "Melinoe_Torch_Turn_180",
            PivotLeft = "Melinoe_Torch_Turn_E90",
            PivotRight = "Melinoe_Torch_Turn_W90",
        },
        Sprint = {
            Start = "Melinoe_Torch_Sprint_FireLoop",
            Loop = "Melinoe_Torch_Sprint_FireLoop",
            Stop = "Melinoe_Torch_Run_End",
            Pivot180 = "Melinoe_Torch_SprintTurn_180",
            PivotLeft = "Melinoe_Torch_SprintTurn_E90",
            PivotRight = "Melinoe_Torch_SprintTurn_W90",
        },
        Dash = { Start = "Melinoe_Torch_Dash_Start", Fire = "Melinoe_Torch_Dash_Fire", Stop = "Melinoe_Torch_Dash_End2" }
    },

    -- [[ LOB (SKULLS) ]]
    Lob = {
        Idle = "Melinoe_Lob_Idle",
        Run = {
            Start = "Melinoe_Lob_Run_Start",
            Loop = "Melinoe_Lob_Run_FireLoop",
            Stop = "Melinoe_Lob_Run_End",
            Pivot180 = "Melinoe_Lob_Turn_180",
            PivotLeft = "Melinoe_Lob_Turn_E90",
            PivotRight = "Melinoe_Lob_Turn_W90",
        },
        Sprint = {
            Start = "Melinoe_Lob_Sprint_FireLoop",
            Loop = "Melinoe_Lob_Sprint_FireLoop",
            Stop = "Melinoe_Lob_Run_End",
            Pivot180 = "Melinoe_Lob_SprintTurn_180",
            PivotLeft = "Melinoe_Lob_SprintTurn_E90",
            PivotRight = "Melinoe_Lob_SprintTurn_W90",
        },
        Dash = { Start = "Melinoe_Lob_Dash_Start", Fire = "Melinoe_Lob_Dash_Fire", Stop = "Melinoe_Lob_Dash_End2" }
    },

    -- [[ SUIT ]]
    Suit = {
        Idle = "Melinoe_Suit_Idle",
        Run = {
            Start = "Melinoe_Suit_Run_Start",
            Loop = "Melinoe_Suit_Run_FireLoop",
            Stop = "Melinoe_Suit_Run_End",
            Pivot180 = "Melinoe_Suit_Turn_180",
            PivotLeft = "Melinoe_Suit_Turn_E90",
            PivotRight = "Melinoe_Suit_Turn_W90",
        },
        Sprint = {
            Start = "Melinoe_Suit_Sprint_FireLoop",
            Loop = "Melinoe_Suit_Sprint_FireLoop",
            Stop = "Melinoe_Suit_Run_End",
            Pivot180 = "Melinoe_Suit_SprintTurn_180",
            PivotLeft = "Melinoe_Suit_SprintTurn_E90",
            PivotRight = "Melinoe_Suit_SprintTurn_W90",
        },
        Dash = { Start = "Melinoe_Suit_Dash_Start", Fire = "Melinoe_Suit_Dash_Fire", Stop = "Melinoe_Suit_Dash_End2" }
    }
}

-- Lookup set for fast checking if an animation is "locomotion"
-- We use this to decide if we should smooth the movement (velocity logic) or just play the raw animation (attacks)
local LocomotionSet = {}
for _, weapon in pairs(Animations.Data) do
    if weapon.Idle then LocomotionSet[weapon.Idle] = true end
    if weapon.Run then
        for _, anim in pairs(weapon.Run) do LocomotionSet[anim] = true end
    end
    if weapon.Sprint then
        for _, anim in pairs(weapon.Sprint) do LocomotionSet[anim] = true end
    end
    if weapon.Dash then
        for _, anim in pairs(weapon.Dash) do LocomotionSet[anim] = true end
    end
end

-- Add generic locomotion
LocomotionSet["MelinoeWalk"] = true
LocomotionSet["MelinoeWalkStart"] = true
LocomotionSet["MelinoeWalkStop"] = true

function Animations.IsLocomotion(animName)
    return LocomotionSet[animName] == true
end

function Animations.GuessWeapon(animName)
    if not animName then return "NoWeapon" end
    if string.find(animName, "_Staff_") then return "Staff" end
    if string.find(animName, "_Dagger_") then return "Dagger" end
    if string.find(animName, "_Axe_") then return "Axe" end
    if string.find(animName, "_Torch_") then return "Torch" end
    if string.find(animName, "_Lob_") then return "Lob" end
    if string.find(animName, "_Suit_") then return "Suit" end
    return "NoWeapon"
end

return Animations