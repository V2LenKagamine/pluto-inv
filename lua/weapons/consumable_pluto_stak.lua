SWEP.PrintName = "Small Tactical Aid Kit"
SWEP.Description = "A Small medical kit that heals 20 health and 20 more over 15 seconds.\nCan be used on others.\n2 Uses."

SWEP.ViewModelFOV = 85
SWEP.ViewModel = "models/weapons/sweps/eft/salewa/v_meds_salewa.mdl"
SWEP.WorldModel = "models/weapons/sweps/eft/salewa/w_meds_salewa.mdl"

SWEP.Base = "consumable_pluto_basemed"

SWEP.Ortho = {0.25, 6, angle = Angle(35, 90, -52.5), size = 0.25}

SWEP.Primary.ClipSize = 2
SWEP.Primary.DefaultClip = 2

SWEP.HealAmnt = 25
SWEP.HealInst = 20
SWEP.HealTime = 15
SWEP.UseTime = 1.5
SWEP.HealPer = false 
SWEP.CleanseDebuffs = false
SWEP.CanOther = true 
SWEP.AddBuffs = {} -- {name,stacks,duration}
SWEP.SkinOverride = 0
