--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]

pluto.tiers = pluto.tiers or {
	crafted = {},
	bytype = {},
	byname = {},
}

local TIER = {}
pluto.tier_mt = pluto.tier_mt or {}
pluto.tier_mt.__index = TIER

function TIER:GetSubDescription()
	local desc = self.SubDescription

	if (type(desc) == "table") then
		local r = {}

		for k, v in SortedPairs(desc) do
			r[#r + 1] = v
		end

		return table.concat(r, "\n")
	end

	return desc or ""
end

function pluto.tiers.filter_real(gun, filter)
	local type = isstring(gun) and gun or pluto.weapons.type(gun)

	if (not type) then
		return
	end

	local typelist = pluto.tiers.bytype[type]

	if (not typelist) then
		return
	end

	local newlist = {}

	for _, tier in pairs(typelist.list) do
		if (filter(tier)) then
			newlist[#newlist + 1] = tier
		end
	end

	return newlist
end

function pluto.tiers.filter(gun, filter)
	local type = isstring(gun) and gun or pluto.weapons.type(gun)

	if (not type) then
		return
	end

	local typelist = pluto.tiers.bytype[type]

	if (not typelist) then
		return
	end

	local shares = 0
	local newlist = {}

	for _, tier in pairs(typelist.list) do
		if (filter(tier)) then
			shares = shares + tier.Shares
			newlist[#newlist + 1] = tier
		end
	end

	local rand = math.random() * shares

	for _, tier in pairs(newlist) do
		rand = rand - tier.Shares
		if (rand < 0) then
			return tier
		end
	end
end

function pluto.tiers.random(gun)
	local type = pluto.weapons.type(gun)

	if (not type) then
		pluto.error("No type to pluto.tiers.random!")
	end

	local typelist = pluto.tiers.bytype[type]

	if (not typelist) then
		pluto.error("No typelist to pluto.tiers.random!")
	end

	local rand = math.random() * typelist.shares

	for _, tier in pairs(typelist.list) do
		rand = rand - tier.Shares
		if (rand < 0) then
			return tier
		end
	end

	error "Reached end of loop in pluto.tiers.random!" 
end
--Why here? Because weapons isnt shared.
function pluto.weapons.realtiername(name)
    if(string.find(name,"-") ~= nil) then
        local undone = string.Split(name,"-")
        return undone[2]
    end
    return name
end

function pluto.tiers.craft(tiers)
	for i, t in pairs(tiers) do
		if (not istable(tiers[i])) then
			tiers[i] = pluto.tiers.byname[tiers[i]]
		end
	end

	local t1, t2, t3 = tiers[1], tiers[2], tiers[3]

	if (t1 == t2 and t2 == t3) then
		return t1
	end

	local name = pluto.weapons.realtiername(t1.InternalName) .. "-" .. pluto.weapons.realtiername(t2.InternalName) .. "-" .. pluto.weapons.realtiername(t3.InternalName)

	if (pluto.tiers.crafted[name]) then
		return pluto.tiers.crafted[name]
	end

    local color

    local Clr1,Clr2,Clr3 = t1.Color,t2.Color,t3.Color

    if(Clr1 and Clr2 and Clr3) then
        color = pluto.tiers.craftedcolor(Clr1,Clr2,Clr3)
    end

	local tier = setmetatable({
		Name = "Crafted",
		InternalName = "crafted",
		Tiers = {
			pluto.weapons.realtiername(t1.InternalName),
			pluto.weapons.realtiername(t2.InternalName),
			pluto.weapons.realtiername(t3.InternalName),
		},
		Crafted = true,
        ["Color"] = color,
	}, pluto.tier_mt)

	pluto.tiers.crafted[name] = tier

	tier.SubDescription = {
		string.format("Crafted from %s, %s and %s shards", t1.Name, t2.Name, t3.Name)
	}

	if (t2.tags) then
		table.insert(tier.SubDescription, t2.SubDescription.tags)
		tier.tags = t2.tags
	end

	if (t2.guaranteed) then
		table.insert(tier.SubDescription, t2.SubDescription.guaranteed)
		tier.guaranteed = t2.guaranteed
		tier.guaranteeddraw = t2.guaranteeddraw
	end

	if (t3.rolltier) then
		table.insert(tier.SubDescription, t3.SubDescription.rolltier)
		tier.rolltier = t3.rolltier
		tier.rolltierdraw = t3.rolltierdraw
	end

	tier.affixes = t1.affixes or 0

	return tier
end

function pluto.tiers.craftedcolor(Clr1,Clr2,Clr3)
    local color
    local C1R,C1G,C1B = Clr1:Unpack()
    local C2R,C2G,C2B = Clr2:Unpack()
    local C3R,C3G,C3B = Clr3:Unpack()
    local newR = (C1R * 0.5) + ((C2R + C3R) * 0.25)
    local newG = (C2G * 0.5) + ((C1G + C3G) * 0.25)
    local newB = (C3B * 0.5) + ((C1B + C2B) * 0.25)
    color = Color(newR,newG,newB)
    return color
end

--Do not name something the same as another, even if different folder.
for _, name in pairs {
	"weapons/common",
	"weapons/confused",
	"weapons/easter_unique",
	"weapons/festive",
	"weapons/gamer",
	"weapons/inevitable",
	"weapons/junk",
	"weapons/legendary",
	"weapons/mystical",
	"weapons/otherworldly",
	"weapons/powerful",
	"weapons/promised",
	"weapons/shadowy",
	"weapons/stable",
	"weapons/tester",
	"weapons/uncommon",
	"weapons/unique",
	"weapons/unusual",
	"weapons/vintage",

	"grenades/unstable",
	"grenades/stabilized",
	"grenades/explosive",

    "consumables/generic",
    
} do
	AddCSLuaFile("pluto/tiers/" .. name .. ".lua")
	local item = include("pluto/tiers/" .. name .. ".lua")
	if (not item) then
		pwarnf("Tier %s didn't return a value", name)
		continue
	end
    local pathtable = string.Split(name,"/")
    name = pathtable[2]
    local fullname = table.concat(pathtable,"-")
	setmetatable(item, pluto.tier_mt)

	local prev = pluto.tiers.byname[name]
	if (prev) then
		pluto.message("INV", "Merging tier ", name)
		table.Empty(prev)
		table.Merge(prev, item)
		item = prev
	end

	item.InternalName = fullname

	pluto.tiers.byname[name] = item

	local type = item.Type or "Weapon"

	if (not pluto.tiers.bytype[type]) then
		pluto.tiers.bytype[type] = {
			list = {},
			shares = 0,
		}
	end

	local typelist = pluto.tiers.bytype[type]

	table.insert(typelist.list, item)
end

if (SERVER) then
	include "_sv_init.lua"
end