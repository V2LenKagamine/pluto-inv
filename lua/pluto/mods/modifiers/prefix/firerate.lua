--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
MOD.Type = "prefix"
MOD.Name = "RPM"
MOD.AffectedStats = {"Delay", "Damage"}
MOD.StatModifierValues = {"Delay", "Damage"}
MOD.Tags = {
	"rpm", "speed"
}

function MOD:IsNegative(idx,roll)
    if(idx == 1) then return false end
    if(idx == 2) then return true end
end

function MOD:FormatModifier(index, roll)
    local rtn = roll
    if(index == 1) then rtn = - rtn end
	return string.format("%.01f%%", rtn)
end

MOD.Description = "Firerate +%.01f%%; Damage -%.01f%%"

MOD.Tiers = {
	{ 10, 15, -1.5, -2.5 },
	{ 6, 10, -0.75, -1.5 },
	{ 1, 6, -0.25, -0.75 },
    { 0.5, 3, -0.1, -0.25 },
}

return MOD