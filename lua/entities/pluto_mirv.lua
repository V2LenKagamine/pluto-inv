AddCSLuaFile()

ENT.PrintName = "MIRV Grenade"
ENT.Base = "ttt_basegrenade"
ENT.Model = "models/weapons/w_eq_fraggrenade_thrown.mdl"
DEFINE_BASECLASS("ttt_basegrenade")

function ENT:Explode()
    if (CLIENT) then return end

    local cases = {
        [1] = Vector(100,0,200),
        [2] = Vector(0,100,200),
        [3] = Vector(-100,0,200),
        [4] = Vector(0,-100,200),
        [5] = Vector(75,75,200),
        [6] = Vector(75,-75,200),
        [7] = Vector(-75,75,200),
        [8] = Vector(-75,-75,200),
    }

    for i = 1,8,1 do
        local ent = ents.Create("pluto_cherry_bombs")
        if (not ent:IsValid()) then return end
        local thrower = self:GetOwner()
        local grenadepos = self:GetPos()
        ent:SetPos(grenadepos + Vector(0,0,5))
        ent:SetOwner(self:GetOwner())
        ent:Spawn()
        ent:SetAbsVelocity(cases[i])
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