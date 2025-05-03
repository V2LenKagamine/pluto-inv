SWEP.PrintName = "R.4.G.3. Injector"
SWEP.Description = "An injector of several combat drugs that heal 20 health and increase damage by 10% for 20 seconds; However, on wearing off, lose 5% indefinitely.\n1 Use."

SWEP.ViewModelFOV = 85
SWEP.ViewModel = "models/weapons/sweps/eft/injector/v_meds_injector.mdl"
SWEP.WorldModel = "models/weapons/sweps/eft/injector/w_meds_injector.mdl"

SWEP.Base = "consumable_pluto_basemed"

SWEP.Ortho = {-2.5, 2, angle = Angle(0, 30, 45), size = 0.1}

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1

SWEP.HealAmnt = 0
SWEP.HealInst = 20
SWEP.HealTime = 0
SWEP.UseTime = 1.5
SWEP.HealPer = false
SWEP.CleanseDebuffs = false
SWEP.CanOther = false 
SWEP.AddBuffs = {{"strengthen",2,20}} -- {name,stacks,duration}
SWEP.SkinOverride = 9
