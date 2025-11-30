-- src/Animations.lua
-- Mimics the structure of Hero_Melinoe_Animation_Locomotion.sjson
-- Separates animation data from logic for cleaner organization.

local Animations = {
    -- Base State
    Idle = "MelinoeIdle",

    -- Movement / Locomotion
    Locomotion = {
        Walk = {
            Start = "MelinoeWalkStart",
            Loop = "MelinoeWalk",
            Stop = "MelinoeWalkStop"
        },
        Run = {
            Start = "MelinoeStart",
            Loop = "MelinoeRun",
            Stop = "MelinoeStop",
            
            -- Directional Changes (Pivots)
            Pivot = {
                Turn180 = "MelinoeRunDirectionChange180",
                TurnLeft90 = "MelinoeRunDirectionChangeE90",  -- "E" is usually Right in global coords, but context dependent
                TurnRight90 = "MelinoeRunDirectionChangeW90" -- "W" is usually Left
            }
        },
        Sprint = {
            Start = "MelinoeSprint", -- Sprint often chains directly or lacks a unique start in some contexts
            Loop = "MelinoeSprint",
            Stop = "MelinoeSprintStop" -- Assuming standard naming convention, fallback to RunStop if needed
        }
    }
}

return Animations