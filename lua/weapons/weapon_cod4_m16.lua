SWEP.PrintName = "M16A4"

SWEP.ViewModelFOV = 70
SWEP.ViewModel = "models/cod4/weapons/v_m16.mdl"
SWEP.WorldModel = "models/cod4/weapons/w_m16.mdl"
SWEP.ViewModelFlip = false

SWEP.Slot = 2

SWEP.UseHands = false
SWEP.HoldType = "ar2"

SWEP.Base = "weapon_ttt_famas"

SWEP.Primary.Sound = "Weapon_CoD4_M4.Single"
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 90
SWEP.Primary.Automatic = true
SWEP.Primary.Damage = 13
SWEP.Primary.Delay = 0.4
SWEP.Primary.RecoilTiming  = 0.36 / 6

SWEP.HeadshotMultiplier = 24 / SWEP.Primary.Damage
SWEP.DeploySpeed = 0.9

SWEP.AutoSpawnable = true

SWEP.Primary.Ammo          = "Pistol"

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 650,
	DamageDropoffRangeMax = 3100,
	DamageMinimumPercent = 0.1,
	Spread = Vector(0.02, 0.02),
}

SWEP.Ironsights = {
	TimeTo = 0.1,
	TimeFrom = 0.15,
	SlowDown = 0.4,
	Zoom = 0.8,
}

SWEP.Ortho = {2.5, -3}

DEFINE_BASECLASS(SWEP.Base)

function SWEP:DoZoom(zoomed)
	BaseClass.DoZoom(self, zoomed)

	if (zoomed) then
		self:SendWeaponAnim(ACT_VM_DEPLOY)
	else
		self:SendWeaponAnim(ACT_VM_UNDEPLOY)
	end
end

function SWEP:GetPrimaryAttackAnimation()
	return self:GetIronsights() and ACT_VM_PRIMARYATTACK_DEPLOYED or ACT_VM_PRIMARYATTACK
end

function SWEP:GetAngleDown()
	if (self.Sights or self:GetClass():match "acog" or self:GetClass():match "reflex") then
		return angle_zero
	end

	return Angle(1, 0, 0)
end

function SWEP:GetIronsightsPos(is_ironsights, frac, pos, ang)
	return pos, ang + LerpAngle(is_ironsights and frac or 1 - frac, angle_zero, self:GetAngleDown())
end


local pow = 4
SWEP.RecoilInstructions = {
	Interval = 1,
	pow * Angle(-5, -0.2),
	pow * Angle(-3, -0.1),
	pow * Angle(-5, 0.2),
}
