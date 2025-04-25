--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
MOD.Type = "prefix"
MOD.Name = "Damage"
MOD.StatModifierValues = { "Damage", "Delay" }
MOD.Tags = {
	"damage"
}

function MOD:IsNegative(roll)
	return roll < 0
end

function MOD:GetDamageMult(rolls)
	return rolls[1] / 100
end

function MOD:FormatModifier(index, roll)
	return string.format("%.01f%%", roll)
end

MOD.Description = "Damage +%.01f%%; Firerate -%.01f%%."

MOD.Tiers = {
	{ 10, 15, -7.5, -10 },
	{ 6, 10, -5, -7.5 },
	{ 3, 6, -3, -5 },
	{ 1, 3, -0.5, -3 },
}

return MOD