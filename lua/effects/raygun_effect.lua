TRACER_FLAG_USEATTACHMENT = 0x0002
SOUND_FROM_WORLD = 0
CHAN_STATIC = 6
EFFECT.Thickness = 16
EFFECT.Life = 0.25
EFFECT.RotVelocity = 30
EFFECT.InValid = false
local Mat_Impact = Material("effects/combinemuzzle2")
local Mat_Beam = Material("effects/tool_tracer")
local Mat_TracePart = Material("effects/select_ring")

function EFFECT:Init(data)
	self.StartPos = data:GetStart()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	self.Color = data:GetColor()
	local owent

	if IsValid(self.WeaponEnt) then
		owent = self.WeaponEnt:GetOwner()

		if not IsValid(owent) then
			owent = self.WeaponEnt:GetParent()
		end
	end

	if IsValid(owent) and owent:IsPlayer() then
		if owent ~= LocalPlayer() or owent:ShouldDrawLocalPlayer() then
			self.WeaponEnt = owent:GetActiveWeapon()
			if not IsValid(self.WeaponEnt) then return end
		else
			self.WeaponEnt = owent:GetViewModel()
			local theirweapon = owent:GetActiveWeapon()

			if IsValid(theirweapon) and theirweapon.ViewModelFlip or theirweapon.ViewModelFlipped then
				self.Flipped = true
			end

			if not IsValid(self.WeaponEnt) then return end
		end
	end

	if IsValid(self.WeaponEntOG) and self.WeaponEntOG.MuzzleAttachment then
		self.Attachment = self.WeaponEnt:LookupAttachment(self.WeaponEntOG.MuzzleAttachment)

		if not self.Attachment or self.Attachment <= 0 then
			self.Attachment = 1
		end

		if self.WeaponEntOG.Akimbo then
			self.Attachment = 2 - self.WeaponEntOG.AnimCycle
		end
	end

	local angpos

	if IsValid(self.WeaponEnt) then
		angpos = self.WeaponEnt:GetAttachment(self.Attachment)
	end

	if not angpos or not angpos.Pos then
		angpos = {
			Pos = vector_origin,
			Ang = angle_zero
		}
	end


	if self.Flipped then
		local tmpang = (self.Dir or angpos.Ang:Forward()):Angle()
		local localang = self.WeaponEnt:WorldToLocalAngles(tmpang)
		localang.y = localang.y + 180
		localang = self.WeaponEnt:LocalToWorldAngles(localang)
		--localang:RotateAroundAxis(localang:Up(),180)
		--tmpang:RotateAroundAxis(tmpang:Up(),180)
		self.Dir = localang:Forward()
	end

	self.EndPos = data:GetOrigin()
	self.Entity:SetRenderBoundsWS(self.StartPos, self.EndPos)
	self.Normal = (self.EndPos - self.StartPos):GetNormalized()
	self.StartTime = 0
	self.LifeTime = self.Life
	self.data = data
	self.rot = 0
end

function EFFECT:Think()
	if self.InValid then return false end
	self.LifeTime = self.LifeTime - FrameTime()
	self.StartTime = self.StartTime + FrameTime()

	return self.LifeTime > 0
end

local beamcol = Color(0, 255, 32, 255)
local beamcol2 = Color(32, 255, 96, 255)

function EFFECT:Render()
	if self.InValid then return false end
	local startPos = self.StartPos
	local endPos = self.EndPos
	local tracerpos
	beamcol.a = self.LifeTime / self.Life * 2
	self.rot = self.rot + FrameTime() * self.RotVelocity
	render.SetMaterial(Mat_TracePart)
	if (self.Color == 1) then
		Mat_TracePart:SetVector("$color", Vector(1, 0.5, 1))
	else
		Mat_TracePart:SetVector("$color", Vector(1, 1, 1))
	end
	for i = -0.1, 0.05, 0.05 do
		render.DrawQuadEasy(Lerp(math.Clamp(self.LifeTime / self.Life + i, 0, 1), endPos, startPos), self.Normal, 12, 12, beamcol2, self.rot)
	end
end
