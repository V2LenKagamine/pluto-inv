MOD.Type = "suffix"
MOD.Name = "Thunder"
MOD.Tags = {}

function MOD:CanRollOn(wep)
	return wep.Base == "weapon_ttt_basegrenade"
end

function MOD:IsNegative(roll)
	return false
end

function MOD:FormatModifier(index, roll)
	return string.format("%.1f%%", roll)
end

function MOD:CanRollOn(wep)
	return wep.ClassName == "weapon_ttt_rolling_thunder"
end

MOD.Description = "Bounces %s more time(s)."

MOD.Tiers = {
	{ 3, 3 },
	{ 2, 2 },
	{ 1, 1 }
}

function MOD:ModifyWeapon(wep, rolls)
	wep.ThunderStrikes = (wep.ThunderStrikes or 0) + (rolls[1])
end

MOD.ItemType = "Grenade"

return MOD