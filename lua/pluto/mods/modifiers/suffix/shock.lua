--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
MOD.Type = "suffix"
MOD.Name = "Lightning"
MOD.Color = Color(0, 162, 255)
MOD.Tags = {
	"damage", "shock", "dot" ,
}

function MOD:IsNegative(roll)
	return roll < 0
end


function MOD:FormatModifier(index, roll)
	return string.format("%.01f%%", roll)
end

MOD.Description = "%s of Damage dealt is converted to Shock; Shock deals burst damage on expire, or bonus damage after reaching a Stack Treshhold"

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
		state.shockstacks = (wep:ScaleRollType("damage", rolls[1])/100) * dmg:GetDamage()
	end
end

function MOD:PostDamage(wep, rolls, target, dmg, state)
    if(not state) then return end
	if (state.shockstacks) then
		dmg:SetDamage(dmg:GetDamage() - state.shockstacks)
		pluto.statuses.byname["shock"]:AddStatus(target,dmg:GetAttacker(),state.shockstacks)
	end
end

return MOD