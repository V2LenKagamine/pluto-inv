-- Variables that are used on both client and server
-- SWEP.Gun = ("cyberian_hemlok") -- must be the name of your swep but NO CAPITALS!
SWEP.Base = "weapon_hemlok"
SWEP.PrintName = "Hemlok"
SWEP.Slot = 2
SWEP.Icon = "vgui/ttt/icon_cyberian.png"

SWEP.HasScope = false

SWEP.AutoSpawnable = true 
SWEP.PlutoSpawnable = true 

-- Model settings
SWEP.UseHands = true
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/c_apex_hemlok_n.mdl"
SWEP.WorldModel = "models/weapons/w_apex_hemlok_n.mdl"

SWEP.Ironsights = {
	Pos =  Vector(0, 1, 1.406),
	Angle = Vector(0, 0, 0),
	TimeTo = 0.075,
	TimeFrom = 0.15,
	SlowDown = 0.9,
	Zoom = 0.75,
}
local pow = 1.5
SWEP.RecoilInstructions = {
	pow * Angle(-2.5, -0.8),
}

SWEP.Offset = { --Procedural world model animation, defaulted for CS:S purposes.
	Pos = {
		Up = 0.8,
		Right = 0.964,
		Forward = 3.796
	},
	Ang = {
		Up = 3,
		Right = -5.844,
		Forward = 180
	},
		Scale = 1.0
}

SWEP.Sounds = {
    reload = {
        {time = 0.25,sound = "weapons/hemlok/wpn_hemlok_reload_removemag_fr15_2ch_v1_01.ogg"},
        {time = 1.30,sound = "weapons/hemlok/wpn_hemlok_reload_insertmag_fr36_2ch_v1_01.ogg"},
        {time = 2.55,sound = "weapons/hemlok/wpn_hemlok_reload_empty_chargeforward_fr76_2ch_v1_01.ogg"},
    },
}

SWEP.Ortho = {5, 4, angle = Angle(0, -85, 0), size = 0.7}