AddCSLuaFile()

ENT.PrintName = "Cherry Bomb"
ENT.Base = "ttt_basegrenade"
ENT.Model = "models/weapons/w_eq_fraggrenade_thrown.mdl"
DEFINE_BASECLASS("ttt_basegrenade")

function ENT:Explode()

	if (CLIENT) then return end

    local pos = self:GetPos()
	local effect = EffectData()
	effect:SetStart(pos)
	effect:SetOrigin(pos)
	effect:SetScale(100)
	effect:SetRadius(75 * self:GetRangeMultiplier())
	effect:SetMagnitude(1)
	util.Effect("Explosion", effect, true, true)
	util.BlastDamage(self.Entity, self.Owner, self.Entity:GetPos(), (125 * self:GetRangeMultiplier()), (50 * self:GetDamageMultiplier()))
	self:Remove()

end

function ENT:GrenadeBounce()
    self:Explode()
end