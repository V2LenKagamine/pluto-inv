SWEP.Base				= "weapon_tttbase"
SWEP.Category				= "TFA CS:O"
SWEP.Kind = WEAPON_HEAVY
SWEP.AllowDrop = true 
SWEP.Spawnable				= true --Can you, as a normal user, spawn this?
SWEP.AdminSpawnable			= true --Can an adminstrator spawn this?  Does not tie into your admin mod necessarily, unless its coded to allow for GMod's default ranks somewhere in its code.  Evolve and ULX should work, but try to use weapon restriction rather than these.
SWEP.DrawCrosshair			= true		-- Draw the crosshair?
SWEP.PrintName				= "Kriss Vector"		-- Weapon name (Shown on HUD)
SWEP.Slot				= 2				-- Slot in the weapon selection menu.  Subtract 1, as this starts at 0.
SWEP.SlotPos				= 73			-- Position in the slot
SWEP.DrawAmmo				= true		-- Should draw the default HL2 ammo counter if enabled in the GUI.
SWEP.DrawWeaponInfoBox			= false		-- Should draw the weapon info box
SWEP.BounceWeaponIcon   		= 	false	-- Should the weapon icon bounce?
SWEP.AutoSwitchTo			= true		-- Auto switch to if we pick it up
SWEP.AutoSwitchFrom			= true		-- Auto switch from if you pick up a better weapon
SWEP.Weight				= 30			-- This controls how "good" the weapon is for autopickup.

--[[WEAPON HANDLING]]--

--Firing related
SWEP.Primary.Sound 			= Sound("Kriss.Fire")				-- This is the sound of the weapon, when you shoot.
SWEP.Primary.Damage		= 10.5					-- Damage, in standard damage points.
SWEP.DamageType = DMG_BULLET --See DMG enum.  This might be DMG_SHOCK, DMG_BURN, DMG_BULLET, etc.
SWEP.HeadshotMultiplier = 1.3
SWEP.Primary.Automatic			= true					-- Automatic/Semi Auto
SWEP.Primary.Delay = 0.055
SWEP.FiresUnderwater = true

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 550,
	DamageDropoffRangeMax = 3200,
	DamageMinimumPercent = 0.1,
	Spread = Vector(0.0275, 0.0275)
}

SWEP.Ironsights = {
	Pos = Vector(-3.23, 1.66, 0.85),
	Angle = Vector(1.18, 0, -6),
	TimeTo = 0.23,
	TimeFrom = 0.22,
	SlowDown = 0.9,
	Zoom = 0.9,
}


local pow = 0.5
SWEP.RecoilInstructions = {
	Interval = 1,
	pow * Angle(-6, -2),
	pow * Angle(-4, -1),
	pow * Angle(-2, 3),
	pow * Angle(-1, 0),
	pow * Angle(-1, 0),
	pow * Angle(-3, 2),
	pow * Angle(-3, 1),
	pow * Angle(-2, 0),
	pow * Angle(-3, -3),
}

SWEP.Offset = { 
        Pos = {
        Up = -5.5,
        Right = 1.25,
        Forward = 8,
        },
        Ang = {
        Up = -90,
        Right = 0,
        Forward = 170
        },
		Scale = 1.18,
}

SWEP.Sounds = {draw = {{time = 0, sound = "Kriss.draw"}},

	reload = {
	    {time = .8, sound = "Kriss.ClipOut"},
    	{time = 2.2, sound = "Kriss.ClipIn"}
    },
}

SWEP.Ortho = {8,-1, angle = Angle(0, -90, 0), size = 0.75}


--Ammo Related

SWEP.Primary.ClipSize			= 30					
SWEP.Primary.DefaultClip			= 60				
SWEP.Primary.Ammo			= "pistol"					


--[[VIEWMODEL]]--

SWEP.ViewModel			= "models/weapons/pandora/v_tfa_vector.mdl" --Viewmodel path
SWEP.ViewModelFOV			= 82		-- This controls how big the viewmodel looks.  Less is more.
SWEP.ViewModelFlip			= false 
SWEP.UseHands = true --Use gmod c_arms system.

SWEP.WorldModel			= "models/weapons/pandora/w_tfa_vector.mdl" -- Worldmodel path

SWEP.HoldType 				= "smg"


if CLIENT then
	SWEP.WepSelectIconCSO = Material("vgui/killicons/tfa_cso_kriss_v")
	SWEP.DrawWeaponSelection = TFA_CSO_DrawWeaponSelection
end
