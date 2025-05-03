SWEP.PrintName = "Anti-D.0.T. Syringe"
SWEP.Description = "A small injector that causes the user to be immune to most negative effects, but reduces damage by 5%. Lasts indefinitely.\n1 Use."

SWEP.ViewModelFOV = 85
SWEP.ViewModel = "models/weapons/sweps/eft/injector/v_meds_injector.mdl"
SWEP.WorldModel = "models/weapons/sweps/eft/injector/w_meds_injector.mdl"

SWEP.Base = "consumable_pluto_basemed"

SWEP.Ortho = {-2.5, 2, angle = Angle(0, 30, 45), size = 0.1}

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1

SWEP.HealAmnt = 0
SWEP.HealInst = 0
SWEP.HealTime = 0
SWEP.UseTime = 1.5
SWEP.HealPer = false 
SWEP.CleanseDebuffs = true
SWEP.CanOther = false  
SWEP.AddBuffs = {
    {"weaken",1},
    {"immune",1},
}
SWEP.SkinOverride = 13

