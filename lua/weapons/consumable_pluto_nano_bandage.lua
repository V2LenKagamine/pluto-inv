SWEP.PrintName = "Nanoweave-Bandages"
SWEP.Description = "A stack of bandages that grant 5 health and 5 more over 5 seconds.\nCan be used on others.\n9 Uses."

SWEP.ViewModelFOV = 85
SWEP.ViewModel = "models/weapons/sweps/eft/cat/v_meds_cat.mdl"
SWEP.WorldModel = "models/weapons/sweps/eft/cat/w_meds_cat.mdl"

SWEP.Base = "consumable_pluto_basemed"

SWEP.Ortho = {-2.5, 2, angle = Angle(0, 30, 45), size = 0.3}

SWEP.Primary.ClipSize = 9
SWEP.Primary.DefaultClip = 9

SWEP.HealAmnt = 5
SWEP.HealInst = 5
SWEP.HealTime = 5
SWEP.UseTime = 2
SWEP.HealPer = false 
SWEP.CleanseDebuffs = false
SWEP.CanOther = true 
SWEP.AddBuffs = {} -- {name,stacks,duration}
SWEP.SkinOverride = 0
