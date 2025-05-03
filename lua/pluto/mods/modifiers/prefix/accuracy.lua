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

function MOD:IsNegative(idx,roll)
    if(idx == 1) then return false end
    if(idx == 2) then return true end
    if(idx == 3) then return true end
end

function MOD:FormatModifier(index, roll)
    local rtn = roll
    if(index == 1) then rtn = - rtn end
	return string.format("%.01f%%", rtn)
end

MOD.Description = "Accuracy +%.01f%%; Firerate -%.01f%%; Clipsize -%.01f%%."

MOD.Tiers = {
	{ -25, -35, -1.875, -2.5, -6.75, -10},
	{ -15, -25, -1.25, -1.875, -2.5, -6.25},
	{ -7.5, -15, -0.75, -1.25, -1.25, -2.5},
	{ -1, -7.5, -0.125, -0.75, -0.75, -1.25},
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