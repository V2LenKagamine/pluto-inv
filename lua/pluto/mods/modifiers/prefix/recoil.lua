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

function MOD:IsNegative(roll)
	return roll < 0
end

function MOD:FormatModifier(index, roll)
	return string.format("%.01f%%", roll)
end

MOD.Description = "Range -%.01f%%; Recoil -%.01f%%"

function MOD:ModifyWeapon(wep, roll) --And here is why.
    wep.Pluto.ViewPunchAngles = wep.Pluto.ViewPunchAngles - (roll[2]/100)
end

MOD.Tiers = {
	{ -15, -20, -35, -50 },
	{ -10, -15, -25, -35 },
	{ -5, -10, -15, -25 },
	{ -2.5, -5, 15, -15 },
}

return MOD