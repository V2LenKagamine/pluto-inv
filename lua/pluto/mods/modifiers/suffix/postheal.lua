--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
MOD.Type = "suffix"
MOD.Name = "Rejuvenation"
MOD.Color = Color(3, 211, 201)
MOD.Tags = {
	"healing",
}

function MOD:IsNegative(roll)
	return false
end

function MOD:FormatModifier(index, roll)
	if (index == 1) then
		return string.format("%i", roll)
	else
		return string.format("%.01f", roll)
	end
end

MOD.Description = "After a righteous kill, heal %s of your health over %s seconds."

MOD.Synergies = {
    ["protec"] = "Also grants 25% of heal as armor.",
}

MOD.Tiers = {
	{ 13, 20, 3, 7.5 },
	{  8, 13, 3, 7.5 },
	{  5,  8, 3, 7.5 },
}

function MOD:OnKill(wep, rolls, atk, vic)
	if (ttt.GetCurrentRoundEvent() ~= "") then
		return
	end

	if (atk:GetRoleTeam() ~= vic:GetRoleTeam()) then
		pluto.statuses.byname["heal"]:AddStatus(atk,atk,rolls[1],rolls[2])
    elseif (vic:IsNextBot()) then
		pluto.statuses.byname["heal"]:AddStatus(atk,atk,(rolls[1]/4),rolls[2])
	end

    if(wep.Mods and wep.Mods.suffix) then
        for _,mod in ipairs(wep.Mods.suffix) do
            if(mod.Mod == "protec") then
                if (atk:Armor() > 30) then break end
                atk:SetArmor(math.min(30, atk:Armor() + math.Round(rolls[1]/4)))
                break
            end
        end
    end
end

return MOD