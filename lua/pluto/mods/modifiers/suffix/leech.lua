--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
MOD.Type = "suffix"
MOD.Name = "The Leech"
MOD.Color = Color(3, 211, 97)
MOD.Tags = {
	"damage", "heal"
}

function MOD:IsNegative(roll)
	return false
end

function MOD:FormatModifier(index, roll)
	return string.format("%.01f%%", roll)
end

MOD.Description = "Damage is lowered by %s. %s of damage is returned as health."

MOD.Tiers = {
	{ 8, 15, 15, 20 },
	{ 8, 15, 10, 15 },
	{ 4, 8, 8, 10 },
}

function MOD:PreDamage(wep, rolls, vic, dmginfo, state)
	if (ttt.GetCurrentRoundEvent() ~= "") then
		return
	end

	if (IsValid(vic) and (vic:IsPlayer() or vic:IsNextBot()) and dmginfo:GetDamage() > 0) then
		dmginfo:ScaleDamage(1 - rolls[1] / 100)
		local atk = wep:GetOwner()
		if (IsValid(atk)and (vic:IsPlayer() or vic:IsNextBot()) and atk:Alive()) then
			local heal = (dmginfo:GetDamage() * rolls[2] / 100)

            if(vic:IsNextBot()) then heal = heal/2 end

            local newhp = math.min(heal + atk:Health(),atk:GetMaxHealth())

			if (hook.Run("PlutoHealthGain", atk, atk:GetMaxHealth() - newhp)) then
				return
			end

			atk:SetHealth(newhp)
		end
	end
end

return MOD