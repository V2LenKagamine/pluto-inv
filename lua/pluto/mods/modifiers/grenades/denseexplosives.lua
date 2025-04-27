MOD.Type = "suffix"
MOD.Name = "Dense Explosions"
MOD.AffectedStats = { "Damage "}
MOD.Tags = {
    "damage"
}

function MOD:IsNegative(roll)
	return roll < 0
end

function MOD:FormatModifier(index, roll)
	return string.format("%.1f%%", roll)
end

function MOD:CanRollOn(wep)
	return wep.ClassName ~= "weapon_ttt_smoke_grenade" or "weapon_ttt_barrel_grenade" or "weapon_ttt_barrier_grenade" or "weapon_ttt_cage_grenade"
end

MOD.Description = "This grenade has %s more damage."

MOD.Tiers = {
	{ 4, 5 },
	{ 3, 4 },
	{ 2, 3 },
    { 1, 2 },
    { 0, 1 },
}

function MOD:ModifyWeapon(wep, rolls)
	wep.DamageMulti = (wep.DamageMulti or 0) * (1 + rolls[1] / 100)
end

MOD.ItemType = "Grenade"

return MOD