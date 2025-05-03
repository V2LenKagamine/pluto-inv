SWEP.PrintName = "0mn153nc3 Injector"
SWEP.Description = "An injector containing... something. Lets you see opponents you're looking at within 30 meters for 15 seconds.\nCan be used on others.\n2 Uses"

SWEP.ViewModelFOV = 85
SWEP.ViewModel = "models/weapons/sweps/eft/injector/v_meds_injector.mdl"
SWEP.WorldModel = "models/weapons/sweps/eft/injector/w_meds_injector.mdl"

SWEP.Base = "consumable_pluto_basemed"

SWEP.Ortho = {-2.5, 2, angle = Angle(0, 30, 45), size = 0.1}

SWEP.Primary.ClipSize = 2
SWEP.Primary.DefaultClip = 2

SWEP.HealAmnt = 0
SWEP.HealInst = 0
SWEP.HealTime = 0
SWEP.UseTime = 1.5
SWEP.HealPer = false 
SWEP.CleanseDebuffs = false
SWEP.CanOther = true 
SWEP.AddBuffs = {{"xray",2,15}} -- {name,stacks,duration}
SWEP.SkinOverride = 4
