--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
MOD.Type = "prefix"
MOD.ItemType = "Grenade"
MOD.StatModifier = "Velocity"
MOD.Name = "Throw Power"
MOD.AffectedStats = {"Throw"}
MOD.Tags = {
	"speed"
}

function MOD:CanRollOn(wep)
	return wep.Base == "weapon_ttt_basegrenade"
end

function MOD:IsNegative(roll)
	return false
end

function MOD:FormatModifier(index, roll)
	return string.format("%.01f%%", roll)
end

function MOD:ModifyWeapon(wep,rolls)
    wep.ThrowMultiplier = wep.ThrowMultiplier * (1 - rolls[1] / 100)
end

MOD.Description = "Throw velocity is increased by %s"

MOD.Tiers = {
	{ 20, 25 },
	{ 10, 15 },
	{ 5, 10 },
}

return MOD