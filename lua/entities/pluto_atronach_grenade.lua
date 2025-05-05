--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
AddCSLuaFile()

ENT.PrintName = "Atronach Grenade"
ENT.Base = "ttt_basegrenade"
ENT.Model = "models/weapons/tfa_cso/w_pumpkin.mdl"

function ENT:GetGrenadeColor()
	return self.WeaponData.GrenadeColor
end

function ENT:Explode()
	if (ttt.GetRoundState() == ttt.ROUNDSTATE_ENDED) then
		return
	end

	local npcs = {}
    --[[
	for i = 1, 1 do 
		local npc = ents.Create "npc_atronach_flame"
		npc:SetPos(self:GetPos())
		npc:SetAngles(angle_zero)
		npc:SetDamageOwner(self:GetOwner())
        npc:SetMaxHealth(250)
        npc:AddEntityRelationship(self:GetOwner(),D_LI,101)
		npc:Spawn()
		npcs[i] = npc
	end
    ]]
	local pos = self:GetPos()
	local effect = EffectData()
	effect:SetStart(pos)
	effect:SetOrigin(pos)
	effect:SetScale(100)
	effect:SetRadius(255)
	effect:SetMagnitude(1)

	util.Effect("Explosion", effect, true, true)
	util.BlastDamage(self, self:GetOwner(), pos, 255, 50)
	self:StartFires(pos, 10, 20, false, self:GetOwner())
    --[[
	timer.Simple(90, function()
		for _, npc in pairs(npcs) do
			if (IsValid(npc)) then
				npc:TakeDamage(math.huge)
			end
		end
	end)]]
end