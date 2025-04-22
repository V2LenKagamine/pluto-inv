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