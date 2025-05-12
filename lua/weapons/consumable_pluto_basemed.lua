SWEP.PrintName = "Base Medical Kit"
SWEP.Author = "Craft_Pig"
SWEP.Editor = "Len Kagamine"
SWEP.Description = "Oh no thats not good.\nYou shouldn't see this!\nAAAAAAAAAAAAAAAAAAAAAAAA"


SWEP.Base = "weapon_tttbase"

SWEP.ViewModelFOV = 90
SWEP.ViewModel = "models/weapons/sweps/eft/afak/v_meds_afak.mdl"
SWEP.WorldModel = "models/weapons/sweps/eft/afak/w_meds_afak.mdl"

SWEP.HoldType = "slam"
SWEP.UseHands = true
SWEP.DrawCrosshair = false 

SWEP.SwayScale = 0.15
SWEP.BobScale = 0.75

SWEP.AllowDrop = true 
SWEP.HasScope = false
SWEP.AutoSpawnable = false
SWEP.PlutoSpawnable = true
SWEP.PlutoConsumable = true

SWEP.Slot = 3
--For easy duplication,copy from below....

SWEP.Primary.ClipSize = 1

SWEP.HealAmnt = 0
SWEP.HealInst = 0
SWEP.HealTime = 1
SWEP.HealPer = false 
SWEP.CleanseDebuffs = false
SWEP.TrueCleanse = false 
SWEP.UseTime = 3
SWEP.CanOther = true 
SWEP.AddBuffs = {} -- {name,stacks,duration}
SWEP.SkinOverride = 0

--...To right above here.
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic = false


SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false

SWEP.MaxRange = 300

DEFINE_BASECLASS("weapon_tttbase")

function SWEP:Deploy()

    pluto.statuses = pluto.statuses or {}
    pluto.statuses.byname = pluto.statuses.byname or {}

    local owner = self:GetOwner() 
	
	self.IniAnimBandage = 0
    self.IdleTimer = 0
    self.AniState = 0

	self:SendWeaponAnim(ACT_VM_IDLE)

	timer.Simple(0.025, function()
        if IsValid(self) and IsValid(self:GetOwner()) then
            local vm = self:GetOwner():GetViewModel()
            if IsValid(vm) and self.SkinOverride ~= 0 then
                vm:SetSkin(self.SkinOverride) 
            end
        end
    end)
	

	if (self:Clip1() <= 0) then
		hook.Run("DropCurrentWeapon", self:GetOwner())
		self:Remove()
    end
	return true
end

function SWEP:QuickHeal(target,amt)
    if (target:Health() >= target:GetMaxHealth() or hook.Run("PlutoHealthGain", target, amt)) then
		return
	end
	target:SetHealth(math.min(target:GetMaxHealth(), target:Health() + amt))
end

function SWEP:Heal(target)
	local missing = target:GetMaxHealth() - target:Health()
    if(target ~= self:GetOwner()) then
        if(target:GetPos():DistToSqr(self:GetOwner():GetPos()) > self.MaxRange^2) then return end
    end
	if IsValid(target) and SERVER then
        if(self.CleanseDebuffs) then
            for _,bad in pairs(target:GetChildren()) do
                if (bad:GetClass() ~= "pluto_status") then continue end
                if(bad.IsNegative and (not bad.NoCleanse or self.TrueCleanse)) then
                    bad:Remove()
                end
            end
        end
        if(self.HealAmnt > 0 or self.HealInst > 0) then
            if(self.HealPer) then
                if(self.HealAmnt > 0 and self.HealTime > 0) then
                    pluto.statuses.byname["heal"]:AddStatus(target,self:GetOwner(),self.HealAmnt,self.HealTime)
                end
                if(self.HealInst > 0) then
                    self:QuickHeal(target,(self.HealInst * target:GetMaxHealth())*(1/target:GetMaxHealth()))
                end
            else
                if(self.HealAmnt > 0 and self.HealTime > 0) then
                    pluto.statuses.byname["heal_flat"]:AddStatus(target,self:GetOwner(),self.HealAmnt,self.HealTime)
                end
                if(self.HealInst > 0) then
                    self:QuickHeal(target,self.HealInst)
                end
            end
        end
        for idx = 1, #self.AddBuffs do
            local effect = self.AddBuffs[idx]
            pluto.statuses.byname[effect[1]]:AddStatus(target,self:GetOwner(),effect[2],effect[3])
        end
		self:TakePrimaryAmmo(1)
		self:Deploy()
	end
end

function SWEP:PrimaryAttack()
    if(self.IdleTimer >= CurTime()) then return end
    local owner = self:GetOwner()
	
    if (self:Clip1() <= 0) then return end
	
	self:SendWeaponAnim(ACT_VM_RECOIL1)
	self.IdleTimer = CurTime() + self.UseTime
    self.IniAnimBandage = 1
end

function SWEP:SecondaryAttack()
    if(self.IdleTimer >= CurTime()) then return end
    if(not self.CanOther)then return end
	self:SendWeaponAnim(ACT_VM_RECOIL1)
    local tracer = util.GetPlayerTrace(self:GetOwner())
    local tr = util.TraceLine(tracer)
    if(tr.Hit) then
        if(tr.Entity and tr.Entity:IsPlayer()) then
            timer.Simple(self.UseTime * 0.8,function() self:Heal(tr.Entity) end)
        end
    end
end

function SWEP:Think()
	if SERVER then
		if (self.IdleTimer <= CurTime()and self.DoHeal) then -- Initialize Heal
			self:Heal(self:GetOwner())
            self.DoHeal = false 
            return 
		end
		
		if self.IniAnimBandage == 1 and self.AniState < 1 then -- Bandage Sequence
			if math.random() <= 0.5 then
				self:SendWeaponAnim(ACT_VM_RECOIL2)
			else
				self:SendWeaponAnim(ACT_VM_HITRIGHT)
			end
            self.AniState = 2
		elseif self.AniState >= 2 and self.IdleTimer <= CurTime() then
			self:SendWeaponAnim(ACT_VM_RECOIL3)
            self.AniState = 0 
            self.DoHeal = true
		end
	end
end

function SWEP:PostDrawViewModel( vm )
    local attachment = vm:GetAttachment(1)
    if attachment then
        self.vmcamera = vm:GetAngles() - attachment.Ang
    else
        self.vmcamera = Angle(0, 0, 0) 
    end
end

function SWEP:CalcView( ply, pos, ang, fov )
	self.vmcamera = self.vmcamera or Angle(0, 0, 0)  
    return pos, ang + self.vmcamera, fov
end

function SWEP:Holster(to)
    self.IniAnimBandage = 0
    self.IdleTimer = 0
    self.AniState = 0
    return BaseClass.Holster(self,to)
end



if CLIENT then -- Worldmodel offset
	local WorldModel = ClientsideModel(SWEP.WorldModel)

	WorldModel:SetSkin(0)
	WorldModel:SetNoDraw(true)

	function SWEP:DrawWorldModel()
		local owner = self:GetOwner()

		if (IsValid(owner)) then
			local offsetVec = Vector(3, -4, 3)
			local offsetAng = Angle(-0, -0, -180)
			
			local boneid = owner:LookupBone("ValveBiped.Bip01_R_Hand") -- Right Hand
			if !boneid then return end

			local matrix = owner:GetBoneMatrix(boneid)
			if !matrix then return end

			local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())

			WorldModel:SetPos(newPos)
			WorldModel:SetAngles(newAng)

            WorldModel:SetupBones()
		else
			WorldModel:SetPos(self:GetPos())
			WorldModel:SetAngles(self:GetAngles())
			self:DrawModel()
		end
		WorldModel:DrawModel()
	end
end