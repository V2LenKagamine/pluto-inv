--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
MOD.Type = "suffix"
MOD.Name = "Marksmanship"
MOD.Color = Color(211, 152, 3)
MOD.Tags = {
	"precise", "damage",
}

function MOD:IsNegative(roll)
	return false
end

function MOD:FormatModifier(index, roll)
	return string.format("%.01f%%", roll)
end

MOD.Description = "Consecutive hits do %s more damage."

MOD.Synergies = {
    ["recycle"] = "Chance to refund consecutive hits to mag.",
}

MOD.Tiers = {
	{ 7.5, 9 },
	{ 5, 7.5 },
	{ 4, 5 },
	{ 2, 4 },
	{ 1, 2  },
}

function MOD:PreDamage(wep, rolls, vic, dmginfo, state)
	if (wep.MarksmanshipFiring) then
		if (vic:IsPlayer()) then
			wep.CurMarksmanship = (wep.CurMarksmanship or 0) + 1
		end
		wep.MarksmanshipFiring = false
	end

	dmginfo:ScaleDamage(1 + (rolls[1] / 100 * (wep.CurMarksmanship or 0)))

    if(wep.Mods and wep.Mods.suffix) then
        for _,mod in ipairs(wep.Mods.suffix) do
            if(mod.Mod == "recycle" and math.random() <= rolls[1] * 4) then
                wep:SetClip1(math.min(wep:GetMaxClip1(), wep:Clip1() + 1))
                break
            end
        end
    end
end

function MOD:OnFire(wep)
	if (wep.MarksmanshipFiring) then
		wep.CurMarksmanship = 0
	end
	wep.MarksmanshipFiring = true
end

return MOD