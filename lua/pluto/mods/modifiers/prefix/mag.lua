--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
MOD.Type = "prefix"
MOD.Name = "Capacity"
MOD.AffectedStats = {"ClipSize","ReloadAnimationSpeed"}
MOD.StatModifierValues = {[2] = "ReloadAnimationSpeed"}
MOD.Tags = {
	"mag"
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

MOD.Description = "Mag +%.01f%%; Reload -%.01f%%"

function MOD:CanRollOn(class)
	return class.ClassName ~= "tfa_cso_batista"
end

MOD.Tiers = {
    { 30, 35, -20, -30 },
	{ 20, 30, -12.5 },
	{ 10, 20, -5, -12.5 },
	{ 5, 10, -5, -5 },
}

function MOD:ModifyWeapon(wep, roll)
	wep.Primary.ClipSize_Original = wep.Primary.ClipSize_Original or wep.Primary.ClipSize
	wep.Primary.DefaultClip_Original = wep.Primary.DefaultClip_Original or wep.Primary.DefaultClip

	wep.Pluto.ClipSize = (wep.Pluto.ClipSize or 1) + (roll[1] / 100)
	local round = wep.Pluto.ClipSize > 1 and math.ceil or math.floor
	wep.Primary.ClipSize = round(wep.Primary.ClipSize_Original * wep.Pluto.ClipSize)
	wep.Primary.DefaultClip = round(wep.Primary.DefaultClip_Original * wep.Pluto.ClipSize)
end

return MOD