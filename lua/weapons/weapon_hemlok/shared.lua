-- Variables that are used on both client and server
-- SWEP.Gun = ("cyberian_hemlok") -- must be the name of your swep but NO CAPITALS!
SWEP.Base = "weapon_tttbase"
SWEP.PrintName = "Hemlok-Cyberian"
SWEP.Slot = 2
SWEP.Icon = "vgui/ttt/icon_cyberian.png"

-- Standard GMod values
SWEP.HoldType = "ar2"

SWEP.Primary.Ammo = "smg1"
SWEP.Primary.Delay = 0.385
SWEP.Primary.Recoil = 0
SWEP.Primary.Damage = 19.5
SWEP.HeadshotMultiplier = 1.4
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = 30	
SWEP.Primary.ClipMax = 90
SWEP.Primary.DefaultClip = 60
SWEP.Primary.Sound       = Sound("weapons/hemlok/fire_1.ogg")

SWEP.BurstAmount = 3

SWEP.Secondary.Sound = Sound("Default.Zoom")
SWEP.HasScope = true

SWEP.AutoSpawnable = false 
SWEP.PlutoSpawnable = true 

SWEP.Sounds = {
    reload = {
        {time = 0.25,sound = "weapons/hemlok/wpn_hemlok_reload_removemag_fr15_2ch_v1_01.ogg"},
        {time = 1.30,sound = "weapons/hemlok/wpn_hemlok_reload_insertmag_fr36_2ch_v1_01.ogg"},
        {time = 2.55,sound = "weapons/hemlok/wpn_hemlok_reload_empty_chargeforward_fr76_2ch_v1_01.ogg"},
    },
}

-- Model settings
SWEP.UseHands = true
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/c_apex_hemlok.mdl"
SWEP.WorldModel = "models/weapons/w_apex_hemlok.mdl"

SWEP.Ironsights = {
	Pos =  Vector(0, 0.201, 1.406),
	Angle = Vector(0, 0, 0),
	TimeTo = 0.075,
	TimeFrom = 0.15,
	SlowDown = 0.8,
	Zoom = 0.3,
}
local pow = 1.5
SWEP.RecoilInstructions = {
	pow * Angle(-2.5, -0.8),
}

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 850,
	DamageDropoffRangeMax = 4800,
	DamageMinimumPercent = 0.1,
	Spread = Vector(0.005, 0.005, 0)
}

SWEP.Offset = { --Procedural world model animation, defaulted for CS:S purposes.
	Pos = {
		Up = 0.8,
		Right = 0.964,
		Forward = 3.796
	},
	Ang = {
		Up = 3,
		Right = -5.844,
		Forward = 180
	},
		Scale = 1.0
}

SWEP.Ortho = {-6, 12, angle = Angle(35, 180, -52.5), size = 0.65}
--- TTT config values

-- Kind specifies the category this weapon is in. Players can only carry one of
-- each. Can be: WEAPON_... MELEE, PISTOL, HEAVY, NADE, CARRY, EQUIP1, EQUIP2 or ROLE.
-- Matching SWEP.Slot values: 0      1       2     3      4      6       7        8
SWEP.Kind = WEAPON_HEAVY

-- The AmmoEnt is the ammo entity that can be picked up when carrying this gun.
SWEP.AmmoEnt = "item_ammo_smg1_ttt"

-- If AllowDrop is false, players can't manually drop the gun with Q
SWEP.AllowDrop = true

-- If IsSilent is true, victims will not scream upon death.
SWEP.IsSilent = false

-- If NoSights is true, the weapon won't have ironsights
SWEP.NoSights = true

DEFINE_BASECLASS(SWEP.Base)

function SWEP:OnDrop()
    self:SetIronsights(false)
end

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)
	self:NetVar("CurrentBurstShot", "Int", 0)
end

function SWEP:StartShoot()
	BaseClass.StartShoot(self)
	self:SetCurrentBurstShot(1)
end

function SWEP:DefaultShoot()
	BaseClass.DefaultShoot(self)
	self.Weapon:EmitSound("weapons/hemlok/fire_" .. math.random(1, 6) .. ".ogg") -- Cursed.
end

function SWEP:Reload()
	if (self:GetCurrentBurstShot() ~= 0) then
		return
	end
	return BaseClass.Reload(self)
end

function SWEP:Deploy()
	self:SetCurrentBurstShot(0)

	return BaseClass.Deploy(self)
end

function SWEP:Think()
	local diff = CurTime() - self:GetRealLastShootTime()
	local interval = self:GetDelay() / 3

	if (diff < interval and self:GetCurrentBurstShot() ~= 0) then
		local nextinterval = interval / self.BurstAmount * self:GetCurrentBurstShot()

		if (diff >= nextinterval) then
			local this_shot = (self:GetCurrentBurstShot() + 1) % self.BurstAmount
			self:SetCurrentBurstShot(this_shot)
			self:DefaultShoot()
		end
	end

	return BaseClass.Think(self)
end