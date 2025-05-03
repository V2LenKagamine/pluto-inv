SWEP.PrintName = "Tactical Aid Kit"
SWEP.Description = "A medical kit that heals 10% health plus 25% over 15 seconds. Cleanses most negative effects.\nCan be used on others.\n2 Uses."

SWEP.ViewModelFOV = 85
SWEP.ViewModel = "models/weapons/sweps/eft/afak/v_meds_afak.mdl"
SWEP.WorldModel = "models/weapons/sweps/eft/afak/w_meds_afak.mdl"

SWEP.Ortho = {-2.5, 2, angle = Angle(0, 30, 45), size = 0.2}

SWEP.Base = "consumable_pluto_basemed"

SWEP.Primary.ClipSize = 2
SWEP.Primary.DefaultClip = 2

SWEP.HealAmnt = 25
SWEP.HealInst = 10
SWEP.HealTime = 15
SWEP.UseTime = 1
SWEP.HealPer = true  
SWEP.CleanseDebuffs = true  
SWEP.CanOther = true 
SWEP.AddBuffs = {} -- {name,stacks,duration}
