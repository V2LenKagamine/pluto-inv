--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
MOD.Type = "prefix"
MOD.Name = "Spread"
MOD.AffectedStats = { "Spread", "Delay", "ClipSize"}
MOD.StatModifierValues = { "Spread", "Delay"}
MOD.Tags = {
	"accuracy"
}

function MOD:IsNegative(roll)
	return roll > 0
end

function MOD:FormatModifier(index, roll)
	return string.format("%.01f%%", roll)
end

MOD.Description = "Accuracy +%.01f%%; Firerate -%.01f%%; Clipsize -%.01f%%."

MOD.Tiers = {
	{ -25, -35, 3.75, 5, 12.5, 20},
	{ -15, -25, 2.5, 3.75, 5, 12.5},
	{ -7.5, -15, 1.25, 2.5, 2.5, 5},
	{ -1, -7.5, 0.25, 1.25, 1.25, 2.5},
}

function MOD:ModifyWeapon(wep, roll)
	wep.Primary.ClipSize_Original = wep.Primary.ClipSize_Original or wep.Primary.ClipSize
	wep.Primary.DefaultClip_Original = wep.Primary.DefaultClip_Original or wep.Primary.DefaultClip

	wep.Pluto.ClipSize = (wep.Pluto.ClipSize or 1) - (roll[3] / 100)
	local round = wep.Pluto.ClipSize > 1 and math.ceil or math.floor
	wep.Primary.ClipSize = round(wep.Primary.ClipSize_Original * wep.Pluto.ClipSize)
	wep.Primary.DefaultClip = round(wep.Primary.DefaultClip_Original * wep.Pluto.ClipSize)
end

return MOD