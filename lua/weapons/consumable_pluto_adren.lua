SWEP.PrintName = "Adrenaline Injector"
SWEP.Description = "A small injector that grants very light regeneration and increases damage by 5% for 15 seconds.\nCan be used on others.\n2 Uses."

SWEP.ViewModelFOV = 85
SWEP.ViewModel = "models/weapons/sweps/eft/injector/v_meds_injector.mdl"
SWEP.WorldModel = "models/weapons/sweps/eft/injector/w_meds_injector.mdl"

SWEP.Base = "consumable_pluto_basemed"

SWEP.Ortho = {-2.5, 2, angle = Angle(0, 30, 45), size = 0.1}

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 2

SWEP.HealAmnt = 10
SWEP.HealInst = 0
SWEP.HealTime = 15
SWEP.UseTime = 1.5
SWEP.HealPer = true 
SWEP.CleanseDebuffs = false
SWEP.CanOther = true 
SWEP.AddBuffs = {{"strengthen",1,15}} -- {name,stacks,duration}
SWEP.SkinOverride = 7
