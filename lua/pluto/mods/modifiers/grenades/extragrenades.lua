
MOD.Type = "suffix"
MOD.ItemType = "Grenade"
MOD.Name = "Spares"
MOD.AffectedStats = {"ClipSize"}
MOD.Tags = {}

function MOD:IsNegative(roll)
	return false
end

function MOD:FormatModifier(index, roll)
	return string.format("%s", roll)
end

function MOD:CanRollOn(wep)
	return wep.Base == "weapon_ttt_basegrenade"
end

MOD.Description = "Carry %s more of this grenade."

MOD.Tiers = {
	{ 1, 1 },
}

function MOD:ModifyWeapon(wep, rolls)
	wep.Primary.ClipSize = (wep.Primary.ClipSize or 1) + (rolls[1])
end

return MOD