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

MOD.Description = "After a righteous kill, gain %s suit armor. Max 30."

MOD.Synergies = {
    ["frost"] = "Max Armor now 40.",
}

MOD.Tiers = {
	{ 10, 15 },
	{ 5, 10 },
	{ 2,  5 },
}

function MOD:OnKill(wep, rolls, atk, vic)
	if (atk:GetRoleTeam() ~= vic:GetRoleTeam() or vic:IsNextBot()) then
        local maxarmor = 30
        if(wep.Mods and wep.Mods.suffix) then
            for _,mod in ipairs(wep.Mods.suffix) do
                if(mod.Mod == "frost") then
                    maxarmor = 40
                end
            end
        end

        if (atk:Armor() > maxarmor) then
            return
        end

        atk:SetArmor(math.min (maxarmor, atk:Armor() + math.Round(vic:IsNextBot() and rolls[1]/2 or rolls[1])))
	end
end

return MOD
