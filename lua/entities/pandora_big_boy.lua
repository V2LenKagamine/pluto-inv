AddCSLuaFile()

ENT.PrintName = "Big Boy"
ENT.Base = "ttt_basegrenade"
ENT.Model = "models/combine_helicopter/helicopter_bomb01.mdl"
DEFINE_BASECLASS("ttt_basegrenade")

function ENT:Explode()

    local pos = self:GetPos()
	local effect = EffectData()
	effect:SetStart(pos)
	effect:SetOrigin(pos)
	effect:SetScale(100)
	effect:SetRadius(250 * self:GetRangeMultiplier())
	effect:SetMagnitude(1)
	util.Effect("Explosion", effect, true, true)
	util.BlastDamage(self.Entity, self.Owner, self.Entity:GetPos(), (500 * self:GetRangeMultiplier()), (250 * self:GetDamageMultiplier()))

end

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)
	self:NetVar("NextSound", "Float")
end

function ENT:Think()
	if (SERVER) then
		local left = self:GetDieTime() - CurTime()

		local interval = 0.5
		if (left < 1) then
			interval = 0.075
		elseif (left < 3) then
			interval = 0.2
		end

		if (self:GetNextSound() == -math.huge or self:GetNextSound() < CurTime()) then
			self:EmitSound "sticky_grenade"
			self:SetNextSound(CurTime() + interval)
		end
	end
	return BaseClass.Think(self)
end
