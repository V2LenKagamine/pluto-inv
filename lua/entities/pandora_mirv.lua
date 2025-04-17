AddCSLuaFile()

ENT.PrintName = "MIRV Grenade"
ENT.Base = "ttt_basegrenade"
ENT.Model = "models/weapons/w_eq_fraggrenade_thrown.mdl"
DEFINE_BASECLASS("ttt_basegrenade")

function ENT:Explode()
    if (CLIENT) then return end

    for i = 1,8,1 do
        local ent = ents.Create("pandora_cherry_bombs")
        if (not ent:IsValid()) then return end
        local thrower = self:GetOwner()
        local grenadepos = self:GetPos()
        ent:SetPos(grenadepos + Vector(0,0,5))
        ent:SetOwner(self:GetOwner())
        ent:Spawn()
        ent:SetAbsVelocity(Vector(math.Rand(-100,100),math.Rand(-100,100),math.Rand(150,250))*self:GetRangeMultiplier())
    end
   
    local pos = self:GetPos()
	local effect = EffectData()
	effect:SetStart(pos)
	effect:SetOrigin(pos)
	effect:SetScale(100)
	effect:SetRadius(150 * self:GetRangeMultiplier())
	effect:SetMagnitude(1)
	util.Effect("Explosion", effect, true, true)
	util.BlastDamage(self.Entity, self.Owner, self.Entity:GetPos(), (150 * self:GetRangeMultiplier()), (85 * self:GetDamageMultiplier()))

end