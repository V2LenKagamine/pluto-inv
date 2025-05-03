--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
MOD.Type = "suffix"
MOD.Name = "Frost"
MOD.Color = Color(0, 162, 255)
MOD.Tags = {
	"damage", "hinder", "dot",
}

function MOD:IsNegative(roll)
	return false
end


function MOD:FormatModifier(index, roll)
	return string.format("%.01f%%", roll)
end

MOD.Description = "%s of Damage dealt is converted to Frost."

MOD.Tiers = {
	{ 25, 35 },
	{ 15, 25 },
	{ 5, 15 },
}

function MOD:ModifyWeapon(wep, rolls)
	wep:ScaleRollType("damage", rolls[1], true)
end

function MOD:OnDamage(wep, rolls, target, dmg, state)
	if (not IsValid(target) or not isentity(target) or dmg:GetInflictor():GetClass() == "pluto_status") then return end
    if(target:IsPlayer() and dmg:GetDamage() > 0) then
		state.froststacks = (wep:ScaleRollType("damage", rolls[1])/100) * dmg:GetDamage()
	end
end

function MOD:PostDamage(wep, rolls, target, dmg, state)
    if(not state) then return end
	if (state.froststacks) then
		dmg:SetDamage(dmg:GetDamage() - state.froststacks)
		pluto.statuses.byname["frost"]:AddStatus(target,dmg:GetAttacker(),state.froststacks)
	end
end


return MOD