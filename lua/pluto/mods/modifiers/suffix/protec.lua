--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
MOD.Type = "suffix"
MOD.Name = "Protection"
MOD.Color = Color(0, 162, 226)
MOD.Tags = {
	"healing",
}

function MOD:IsNegative(roll)
	return false
end

function MOD:FormatModifier(index, roll)
	return string.format("%i", math.Round(roll))
end

MOD.Description = "After a righteous kill, gain %s suit armor"

MOD.Tiers = {
	{ 10, 15 },
	{ 5, 10 },
	{ 2,  5 },
}

function MOD:OnKill(wep, rolls, atk, vic)
	if (atk:GetRoleTeam() ~= vic:GetRoleTeam()) then
		if (atk:Armor() > 30) then
			return
		end

		atk:SetArmor(math.min(30, atk:Armor() + math.Round(rolls[1])))
	end
end

return MOD
