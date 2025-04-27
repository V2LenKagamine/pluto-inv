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

function MOD:IsNegative(roll)
	return roll < 0
end

function MOD:FormatModifier(index, roll)
	return string.format("%.01f%%", roll)
end

MOD.Description = "Firerate +%.01f%%; Damage -%.01f%%"

MOD.Tiers = {
	{ 15, 20, -5, -7.5 },
	{ 10, 15, -3, -5 },
	{ 6, 10, -1.5, -3 },
	{ 1, 6, -0.5, -1.5 },
}

return MOD