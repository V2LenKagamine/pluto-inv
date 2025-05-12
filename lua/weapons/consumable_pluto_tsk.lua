SWEP.PrintName = "Tactical Surgical Kit"
SWEP.Description = "A field surgery and detox kit that heals 30% health plus 60% over 30 seconds. Clears all negative effects.\nCan be used on others.\n1 Use."

SWEP.ViewModelFOV = 85
SWEP.ViewModel = "models/weapons/sweps/eft/surgicalkit/v_meds_surgicalkit.mdl"
SWEP.WorldModel = "models/weapons/sweps/eft/surgicalkit/w_meds_surgicalkit.mdl"

SWEP.Base = "consumable_pluto_basemed"

SWEP.Ortho = {-2.5, -1.5, angle = Angle(0, 60, -270), size = 0.25}

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1

SWEP.HealAmnt = 60
SWEP.HealInst = 30
SWEP.HealTime = 30
SWEP.UseTime = 3.5
SWEP.HealPer = true 
SWEP.CleanseDebuffs = true 
SWEP.TrueCleanse = true
SWEP.CanOther = true
SWEP.AddBuffs = {} -- {name,stacks,duration}

SWEP.MaxRange = 50