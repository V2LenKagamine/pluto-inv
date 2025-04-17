AddCSLuaFile()

ENT.PrintName = "Big Boy"
ENT.Base = "ttt_basegrenade"
ENT.Model = "models/weapons/w_models/w_grenade_grenadelauncher.mdl"
DEFINE_BASECLASS("ttt_basegrenade")

function ENT:Explode()

    local pos = self:GetPos()
	local effect = EffectData()
	effect:SetStart(pos)
	effect:SetOrigin(pos)
	effect:SetScale(100)
	effect:SetRadius(200 * self:GetRangeMultiplier())
	effect:SetMagnitude(1)
	util.Effect("Explosion", effect, true, true)
	util.BlastDamage(self.Entity, self.Owner, self.Entity:GetPos(), (200 * self:GetRangeMultiplier()), (150 * self:GetDamageMultiplier()))

end