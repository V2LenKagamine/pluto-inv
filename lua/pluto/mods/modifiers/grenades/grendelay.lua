--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
MOD.Type = "suffix"
MOD.Name = "Timing"
MOD.AffectedStats = {"DelayGren"}
MOD.Tags = {
	"speed"
}

function MOD:CanRollOn(wep)
	return wep.Base == "weapon_ttt_basegrenade"
end

function MOD:IsNegative(roll)
	return false 
end

function MOD:FormatModifier(index, roll)
	return string.format("%.01f%%", roll)
end

MOD.Description = "This grenade takes %s less time to explode"

MOD.Tiers = {
	{ 20, 25 },
	{ 15, 20 },
	{ 10, 15 },
	{ 5, 10 },
}

function MOD:ModifyWeapon(wep, rolls)
	wep.Primary.Delay = wep.Primary.Delay * (1 - rolls[1] / 100)
end

MOD.ItemType = "Grenade"

return MOD