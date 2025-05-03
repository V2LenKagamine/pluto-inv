--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
MOD.Type = "suffix"
MOD.Name = "Igniting"
MOD.Tags = {
	"damage", "fire", "dot"
}

MOD.Color = Color(211, 111, 3)

function MOD:IsNegative(roll)
	return false
end

function MOD:FormatModifier(index, roll)
	return string.format("%.01f%%", roll)
end

MOD.Description = "%s of Damage dealt is converted to Flame; Missed shots may ignite terrain; Flame does more damage and lasts longer the more stacks the target has."

MOD.Tiers = {
	{ 25, 35 },
	{ 15, 25 },
	{ 5, 15 },
}

function MOD:ModifyWeapon(wep, rolls)
	wep:ScaleRollType("damage", rolls[1], true)
end

function MOD:OnShoot(wep, rolls, trce, dmg, state)
    if(CLIENT) then return end
    if(trce.Entity) then
        if(trce.Entity:IsWorld()) then
            if(math.Rand(0,100) < wep:ScaleRollType("damage",rolls[1])) then
                CreateVFire(trce.Entity,trce.HitPos,vector_origin,dmg:GetDamage()*1.5,dmg:GetAttacker())
            end
        end
    end
end

function MOD:OnDamage(wep, rolls, target, dmg, state)
    if (not IsValid(target) or not isentity(target) or dmg:GetInflictor():GetClass() == "pluto_status") then return end
    if(target:IsPlayer() and dmg:GetDamage() > 0) then
		state.firestacks = (wep:ScaleRollType("damage", rolls[1])/100) * dmg:GetDamage()
	end
end

function MOD:PostDamage(wep, rolls, target, dmg, state)
    if(not state) then return end
	if (state.firestacks) then
		dmg:SetDamage(dmg:GetDamage() - state.firestacks)
		pluto.statuses.byname["fire"]:AddStatus(target,dmg:GetAttacker(),state.firestacks)
	end
end

return MOD