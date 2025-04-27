--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
pluto.mods = pluto.mods or {}
pluto.mods.byname = pluto.mods.byname or {}

function pluto.mods.chance(crafted, amount)
	if (not crafted) then
		return 0
	end

	local chance = crafted.Chance
	chance = chance * (1 + ((amount - 1) / (crafted.ChanceDeminish or 5)))

	return math.min(chance,100)
end

pluto.mods.mt = pluto.mods.mt or {}

function pluto.mods.mt.__colorprint(self)
	return {self.Color or white_text, self.Name or "UNKNOWN"}
end
local MOD = pluto.mods.mt.__index or {}
pluto.mods.mt.__index = MOD

function MOD:GetPrintName()
	if (self.Type == "suffix") then
		return "of " .. self.Name
	end

	return self.Name
end

function MOD:GetTierName(tier)
	return self:GetPrintName() .. " " .. pluto.toroman(tier)
end

function MOD:GetMinMax(nudge)
	return self.Tiers[#self.Tiers][1 + (2*((nudge or 1)-1))], self.Tiers[1][2 + (2*((nudge or 1)-1))]
end

function MOD:GetDescription(rolls)
    return string.format(self.Description,math.abs(rolls[1] or 1),math.abs(rolls[2] or 1),math.abs(rolls[3] or 1))
end

function pluto.mods.getrolls(mod, tier, rolls)
	local retn = {}

	tier = mod.Tiers[tier] or mod.Tiers[#mod.Tiers]

	for idx = 2, #tier, 2 do
		local min, max = tier[idx - 1], tier[idx]
		retn[idx / 2] = (rolls[idx / 2] or 0) * (max - min) + min
	end

	return retn
end

function pluto.mods.getminmaxs(mod_data, item)
	local mod = pluto.mods.byname[mod_data.Mod]
	
	if (not mod) then
		return ""
	end

	local tier = mod.Tiers[mod_data.Tier] or mod.Tiers[#mod.Tiers]

	local formatted = {}

	for i = 1, #tier - 1, 2 do
		local index = (i + 1) / 2
		formatted[index] = {
			Mins = mod:FormatModifier(index, tier[i], item.ClassName),
			Maxs = mod:FormatModifier(index, tier[i + 1], item.ClassName),
		}
	end

	return formatted
end

function pluto.mods.format(mod_data, gun)
	local mod = pluto.mods.byname[mod_data.Mod]

	if (not mod) then
		return ""
	end

	local tier = mod.Tiers[mod_data.Tier]
	local rolls = pluto.mods.getrolls(mod, mod_data.Tier, mod_data.Roll)

	local formatted = {}

	for i = 1, #tier - 1, 2 do
		local index = (i + 1) / 2
		formatted[index] = mod:FormatModifier(index, rolls[index], gun.ClassName)
	end

	return formatted
end

function pluto.mods.getdescription(mod_data)
	local mod = pluto.mods.byname[mod_data.Mod]

	if (not mod) then
		return ""
	end

	if (mod.Description) then
		return mod.Description
	elseif (mod.GetDescription) then
		return mod:GetDescription(pluto.mods.getrolls(mod, mod_data.Tier, mod_data.Roll))
	end
end

function pluto.mods.formatdescription(mod_data, item, format)
	local desc = pluto.mods.getdescription(mod_data)
	if (not format) then
		format = pluto.mods.format(mod_data, item)
	end

	return string.formatsafe(desc, unpack(format))
end

function pluto.mods.getrawvalue(wep, name)
	local s, c = pcall(wep["Get" .. name], wep)
	if (s) then
		return c
	end

	if (wep.Primary and wep.Primary[name]) then
		return wep.Primary[name]
	end

	if (wep[name]) then
		return wep[name]
	end
end

local stattranslations={
    ["Throw"] = "TDIS",
    ["Delay"] = "RPM",
    ["DelayGren"] = "TTE",
    ["Damage"] = "DMG",
    ["Spread"] = "ACC",
    ["Bounce"] = "BNCE",
    ["DamageDropoffRange"] = "RNGE",
    ["Range"] = "RNGE",
    ["ViewPunchAngles"] = "KICK",
    ["ClipSize"] = "MAG",
    ["ReloadAnimationSpeed"] = "RLD",
    }

function pluto.mods.shortname(statname)    
    return stattranslations[statname] or "???"
end

function pluto.mods.humanreadablestat(statname, wep, value)
	if (statname == "Delay") then
		return math.Round(60 / value), "RPM"
	end

	if (statname == "Damage" and wep.Bullets and wep.Bullets.Num and wep.Bullets.Num > 1) then
		return math.Round(value, 1) .. "*" .. wep.Bullets.Num, "DMG"
	end

	if (type(value) == "Vector") then
		return math.Round(value:Length() * 100, 1), "??"
	end

	if (type(value) == "number") then
		return math.Round(value, 1)
	end

	return tostring(value), "?"
end

function pluto.mods.getstatvalue(wep, name)
	return pluto.mods.humanreadablestat(name, wep, pluto.mods.getrawvalue(wep, name))
end

function pluto.mods.getitemvalue(item, name)
	local wep = baseclass.Get(item.ClassName)

	local value = pluto.mods.getrawvalue(wep, name)
	if (not value) then
        pluto.error("Oh thats not good; [" .. wep .. "] had no raw value")
		return "IDK XD"
	end

	local override, modifier = pluto.stattranslate(name)
	if (item.Mods and item.Mods.prefix) then
		for _, mod in pairs(item.Mods.prefix) do
			local MOD = pluto.mods.byname[mod.Mod]
            for idx=1, (#(MOD.Tiers[mod.Tier]) / 2) do
			    local rolls = pluto.mods.getrolls(MOD, mod.Tier, mod.Roll)
                modifier = modifier + (rolls[idx] / 100)
            end
		end
	end
	
	return pluto.mods.humanreadablestat(name, wep, override(value, modifier))
end
