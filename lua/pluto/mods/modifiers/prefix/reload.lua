--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
MOD.Type = "prefix"
MOD.Name = "Reload Speed"
MOD.AffectedStats = {"ReloadAnimationSpeed","ClipSize"}
MOD.StatModifierValues = {"ReloadAnimationSpeed"}
MOD.Tags = {
	"reload", "speed"
}

function MOD:IsNegative(idx,roll)
    if(idx == 1) then return roll < 0 end
    if(idx == 2) then return true end
end

function MOD:FormatModifier(index, roll)
	return string.format("%.01f%%", roll)
end

MOD.Description = "Reload +%.01f%%; Mag -%.01f%%"

MOD.Tiers = {
	{ 40, 60, -7.5, -10 },
	{ 25, 40, -5, -7.5 },
	{ 10, 25, -2.5, -5 },
	{ -10, 10, -0.75, -2.5 },
}

function MOD:ModifyWeapon(wep, roll)
	wep.Primary.ClipSize_Original = wep.Primary.ClipSize_Original or wep.Primary.ClipSize
	wep.Primary.DefaultClip_Original = wep.Primary.DefaultClip_Original or wep.Primary.DefaultClip

	wep.Pluto.ClipSize = (wep.Pluto.ClipSize or 1) + (roll[2] / 100)
	local round = wep.Pluto.ClipSize > 1 and math.ceil or math.floor
	wep.Primary.ClipSize = round(wep.Primary.ClipSize_Original * wep.Pluto.ClipSize)
	wep.Primary.DefaultClip = round(wep.Primary.DefaultClip_Original * wep.Pluto.ClipSize)
end

return MOD