SWEP.Base = "weapon_ttt_basegrenade"
SWEP.AutoSpawnable = false
SWEP.PlutoSpawnable = true

SWEP.PrintName = "Thermite Grenade"

SWEP.UseHands = true

SWEP.ViewModel = "models/weapons/thermite/c_apex_nade_thermite.mdl"
SWEP.WorldModel = "models/weapons/thermite/w_apex_nade_thermite.mdl"

SWEP.Primary.Delay = 2

SWEP.GrenadeEntity = "pluto_thermite_nade"

SWEP.ViewModelFOV = 70

SWEP.Attachments = {
}

SWEP.Animations = {
    ["ready"] = {
        Source = "draw",
        SoundTable = {
            {s = "weapons/grenades/thermite/Wpn_ThermiteGrenade_Draw_2ch_v2_01.ogg", t = 0 / 30},
        },
    },
    ["draw"] = {
        Source = "draw",
        SoundTable = {
            {s = "weapons/grenades/thermite/Wpn_ThermiteGrenade_Draw_2ch_v2_01.ogg", t = 0 / 30},
        },
    },
    ["holster"] = {
        Source = "holster",
        SoundTable = {
            {s = "weapons/grenades/thermite/Wpn_ThermiteGrenade_Holster_2ch_v1_01.ogg", t = 1 / 30}
        },
    },
    ["pre_throw"] = {
        Source = "pullpin",
        SoundTable = {
            {s = "weapons/grenades/wpn_fraggrenade_1p_throw_2ch_v1_02.wav", t = 0 / 30},
        },
        MinProgress = 0.5,
    },
}