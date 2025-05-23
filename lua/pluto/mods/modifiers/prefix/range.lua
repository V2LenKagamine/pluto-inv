--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
MOD.Type = "prefix"
MOD.Name = "Range"
MOD.StatModifier = "DamageDropoffRange"
--We cant use this because we need roll #1 for first two, but #2 for the third.
--MOD.StatModifierValues = { "DamageDropoffRangeMax", "DamageDropoffRange", "ViewPunchAngles" }
MOD.AffectedStats = { "DamageDropoffRange", "ViewPunchAngles" }
MOD.Tags = {
	"range"
}

function MOD:IsNegative(idx,roll)
    if(idx == 1) then return false end
    if(idx == 2) then return true end
end

function MOD:FormatModifier(index, roll)
    local rtn = roll
	return string.format("%.01f%%", rtn)
end

MOD.Description = "Range +%.01f%%; Recoil +%.01f%%"

function MOD:ModifyWeapon(wep, roll)
    wep.Pluto.ViewPunchAngles = wep.Pluto.ViewPunchAngles - (roll[2]/100)
end

MOD.Tiers = {
	{ 40, 50, -12.5, -16.25},
	{ 30, 40, -6.75, -12.5},
	{ 20, 30, -6.75, -8.75},
	{ 10, 20, -3.75, -6.75 },
	{ 5, 10, 3.75, -3.75 },
}

return MOD