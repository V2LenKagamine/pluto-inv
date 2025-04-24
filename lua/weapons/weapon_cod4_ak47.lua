SWEP.PrintName = "TAK-47"

SWEP.ViewModelFOV = 70
SWEP.ViewModel = "models/cod4/weapons/v_ak47.mdl"
SWEP.WorldModel = "models/cod4/weapons/w_ak47.mdl"
SWEP.ViewModelFlip = false

SWEP.Slot = 2

SWEP.UseHands = false
SWEP.HoldType = "ar2"
SWEP.Base = "weapon_ttt_cod4_base"

SWEP.Primary.Sound = "Weapon_CoD4_AK47.Single"
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 60
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo          = "Pistol"
SWEP.Primary.Damage = 19.25
SWEP.Primary.Delay = 0.095

SWEP.HeadshotMultiplier = 1.4

sound.Add {
	name = "Weapon_CoD4_AK47.Single",
	channel = CHAN_WEAPON,
	level = 80,
	sound = "cod4/weapons/ak47/weap_ak47_slst_3.ogg"
}
sound.Add {
	name = "Weapon_CoD4_AK47.Chamber",
	channel = CHAN_ITEM,
	volume = 0.5,
	sound = "cod4/weapons/ak47/wpfoly_ak47_reload_chamber_v4.ogg"
}
sound.Add {
	name = "Weapon_CoD4_AK47.ClipIn",
	channel = CHAN_ITEM,
	volume = 0.5,
	sound = "cod4/weapons/ak47/wpfoly_ak47_reload_clipin_v4.ogg"
}
sound.Add {
	name = "Weapon_CoD4_AK47.ClipOut",
	channel = CHAN_ITEM,
	volume = 0.5,
	sound = "cod4/weapons/ak47/wpfoly_ak47_reload_clipout_v5.ogg"
}
sound.Add {
	name = "Weapon_CoD4_AK47.Lift",
	channel = CHAN_ITEM,
	volume = 0.5,
	sound = "cod4/weapons/ak47/wpfoly_ak47_reload_lift_v4.ogg"
}


SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 850,
	DamageDropoffRangeMax = 4000,
	DamageMinimumPercent = 0.3,
	Spread = Vector(0.0125, 0.0125),
}

SWEP.Ironsights = {
	TimeTo = 0.25,
	TimeFrom = 0.15,
	SlowDown = 0.55,
	Zoom = 0.8,
}

local pow = 3.9
SWEP.RecoilInstructions = {
	Interval = 1,
	pow * Angle(-5, -1),
	pow * Angle(-4, -1),
	pow * Angle(-2, 1),
	pow * Angle(-1, 1.5),
	pow * Angle(-3, 0),
	pow * Angle(-3, 1),
	pow * Angle(-3, -1.2),
}


SWEP.AutoSpawnable = true

SWEP.Ortho = {2.5, -4.5}

