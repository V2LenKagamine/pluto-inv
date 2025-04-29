--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
MOD.Type = "prefix"
MOD.Name = "Recoil"
MOD.AffectedStats = {"DamageDropoffRange","ViewPunchAngles"}
MOD.StatModifier = "DamageDropoffRange" --Do not be fooled, this is a recoil stat trust me.
MOD.Tags = {
	"recoil"
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

MOD.Description = "Range -%.01f%%; Recoil -%.01f%%"

function MOD:ModifyWeapon(wep, roll) --And here is why.
    wep.Pluto.ViewPunchAngles = wep.Pluto.ViewPunchAngles - (roll[2]/100)
end

MOD.Tiers = {
	{ 15, 20, -17.5, -25 },
	{ 10, 15, -12.5, -17.5 },
	{ 5, 10, -7.5, -12.5 },
	{ 2.5, 5, 7.5, -7.5 },
}

return MOD