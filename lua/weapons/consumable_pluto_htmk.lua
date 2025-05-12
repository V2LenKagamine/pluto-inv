SWEP.PrintName = "Huge Tactical Aid Kit"
SWEP.Description = "A large med-kit that heals 5% health and 15% more over 15 seconds.\nCan be used on others.\n5 Uses."

SWEP.ViewModelFOV = 85
SWEP.ViewModel = "models/weapons/sweps/eft/grizzly/v_meds_grizzly.mdl"
SWEP.WorldModel = "models/weapons/sweps/eft/grizzly/w_meds_grizzly.mdl"

SWEP.Base = "consumable_pluto_basemed"

SWEP.Ortho = {-3, 2, angle = Angle(0, 30, 45), size = 0.4}

SWEP.Primary.ClipSize = 5
SWEP.Primary.DefaultClip = 5

SWEP.HealAmnt = 15
SWEP.HealInst = 5
SWEP.HealTime = 15
SWEP.UseTime = 0.75
SWEP.HealPer = true  
SWEP.CleanseDebuffs = false
SWEP.CanOther = true 
SWEP.AddBuffs = {} -- {name,stacks,duration}
SWEP.SkinOverride = 0
