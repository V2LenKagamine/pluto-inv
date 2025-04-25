--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
MOD.Type = "prefix"
MOD.Name = "Range"
MOD.StatModifier = "DamageDropoffRange"
--We cant use this because we need roll #1 for first two, but #2 for the third.
--MOD.StatModifierValues = { "DamageDropoffRangeMax", "DamageDropoffRange", "ViewPunchAngles" }
MOD.Tags = {
	"range"
}

function MOD:IsNegative(roll)
	return roll < 0
end

function MOD:FormatModifier(index, roll)
	return string.format("%.01f%%", roll)
end

MOD.Description = "Range +%.01f%%; Recoil +%.01f%%"

function MOD:ModifyWeapon(wep, roll)
    wep.Pluto.ViewPunchAngles = wep.Pluto.ViewPunchAngles - (roll[2]/100)
end

MOD.Tiers = {
	{ 40, 50, -25, -32.5},
	{ 30, 40, -17.5, -25},
	{ 20, 30, -12.5, -17.5},
	{ 10, 20, -7.5, -12.5 },
	{ 5, 10, 7.5, -7.5 },
}

return MOD