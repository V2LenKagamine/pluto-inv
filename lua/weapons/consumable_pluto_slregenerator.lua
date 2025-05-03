SWEP.PrintName = "Diluted-Hydra Injector"
SWEP.Description = "An injector containing a diluted regenerative chemical that heals 5% health and 20% over 30 seconds.\nCan be used on others.\n4 Uses."

SWEP.ViewModelFOV = 85
SWEP.ViewModel = "models/weapons/sweps/eft/injector/v_meds_injector.mdl"
SWEP.WorldModel = "models/weapons/sweps/eft/injector/w_meds_injector.mdl"

SWEP.Base = "consumable_pluto_basemed"

SWEP.Ortho = {-2.5, 2, angle = Angle(0, 30, 45), size = 0.1}

SWEP.Primary.ClipSize = 4
SWEP.Primary.DefaultClip = 4

SWEP.HealAmnt = 20
SWEP.HealInst = 5
SWEP.HealTime = 30
SWEP.UseTime = 1.5
SWEP.HealPer = true 
SWEP.CleanseDebuffs = false
SWEP.CanOther = true 
SWEP.AddBuffs = {} -- {name,stacks,duration}
SWEP.SkinOverride = 5
