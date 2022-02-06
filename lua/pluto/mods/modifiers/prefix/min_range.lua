--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
MOD.Type = "prefix"
MOD.Name = "Range"
MOD.StatModifier = "DamageDropoffRange"
MOD.StatModifierValues = { "DamageDropoffRangeMax", "DamageDropoffRange" }
MOD.Tags = {
	"range"
}

function MOD:IsNegative(roll)
	return roll < 0
end

function MOD:FormatModifier(index, roll)
	return string.format("%.01f%%", roll)
end

MOD.Description = "Damage range is extended by %s"

MOD.Tiers = {
	{ 40, 50 },
	{ 30, 40 },
	{ 20, 30 },
	{ 10, 20 },
	{ 5, 10 },
}

return MOD