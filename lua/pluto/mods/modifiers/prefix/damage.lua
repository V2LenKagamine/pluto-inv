--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
MOD.Type = "prefix"
MOD.Name = "Damage"
MOD.AffectedStats =  { "Damage", "Delay" }
MOD.StatModifierValues = { "Damage", "Delay" }
MOD.Tags = {
	"damage"
}

function MOD:IsNegative(idx,roll)
    if(idx == 1) then return false end
    if(idx == 2) then return true end
end

function MOD:GetDamageMult(rolls)
	return rolls[1] / 100
end

function MOD:FormatModifier(index, roll)
    local rtn = roll
	return string.format("%.01f%%", rtn)
end

MOD.Description = "Damage +%.01f%%; Firerate -%.01f%%."

MOD.Tiers = {
	{ 10, 15, -3.75, -5 },
	{ 6, 10, -2.5, -3.75 },
	{ 3, 6, -1.5, -2.5 },
	{ 1, 3, -0.25, -1.5 },
}

return MOD