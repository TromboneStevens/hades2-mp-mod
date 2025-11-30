return {
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
    Dash = { 
        Start = "Melinoe_Dagger_Dash_Start", 
        Fire = "Melinoe_Dagger_Dash_Fire", 
        Stop = "Melinoe_Dagger_Dash_End2" 
    },
    -- Attack data preserved for future syncing logic
    Attacks = {
        Attack1 = { Start = "Melinoe_Dagger_AttackRight_Start", Fire = "Melinoe_Dagger_AttackRight_Fire", End = "Melinoe_Dagger_AttackRight_End" },
        Attack2 = { Start = "Melinoe_Dagger_AttackLeft_Start", Fire = "Melinoe_Dagger_AttackLeft_Fire", End = "Melinoe_Dagger_AttackLeft_End" },
        Spin = { Start = "Melinoe_Dagger_AttackSpin_Start", Fire = "Melinoe_Dagger_AttackSpin_Fire", End = "Melinoe_Dagger_AttackSpin_End" },
        MultiStab = { Start = "Melinoe_Dagger_AttackStabs_Start", Fire = "Melinoe_Dagger_AttackStabs_Fire", Loop = "Melinoe_Dagger_AttackStabs_FireLoop", End = "Melinoe_Dagger_AttackStabs_End" },
        Double = { Start = "Melinoe_Dagger_AttackDouble_Start", Fire = "Melinoe_Dagger_AttackDouble_Fire", End = "Melinoe_Dagger_AttackDouble_End" },
        Blink = { Start = "Melinoe_Dagger_AttackEx1_Start", Fire = "Melinoe_Dagger_AttackEx1_Fire", End = "Melinoe_Dagger_AttackEx1_End" },
        Special = { Start = "Melinoe_Dagger_Special_Start", Fire = "Melinoe_Dagger_Special_Fire", End = "Melinoe_Dagger_Special_End" },
        SpecialEx = { Fire = "Melinoe_Dagger_SpecialEx_Fire", End = "Melinoe_Dagger_SpecialEx_End" }
    }
}