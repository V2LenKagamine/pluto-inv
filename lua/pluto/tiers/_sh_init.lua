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
		return
	end

	local typelist = pluto.tiers.bytype[type]

	if (not typelist) then
		return
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

	local name = t1.InternalName .. "-" .. t2.InternalName .. "-" .. t3.InternalName

	if (pluto.tiers.crafted[name]) then
		return pluto.tiers.crafted[name]
	end

	local tier = setmetatable({
		Name = "Crafted",
		InternalName = "crafted",
		Tiers = {
			t1.InternalName,
			t2.InternalName,
			t3.InternalName,
		},
		Crafted = true,
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

for _, name in pairs {
	"common",
	"confused",
	"easter_unique",
	"festive",
	"gamer",
	"inevitable",
	"junk",
	"legendary",
	"mystical",
	"otherworldly",
	"powerful",
	"promised",
	"shadowy",
	"stable",
	"tester",
	"uncommon",
	"unique",
	"unusual",
	"vintage",

	"unstable",
	"stabilized",
	"explosive",
	
} do
	AddCSLuaFile("pluto/tiers/" .. name .. ".lua")
	local item = include("pluto/tiers/" .. name .. ".lua")
	if (not item) then
		pwarnf("Tier %s didn't return a value", name)
		continue
	end

	setmetatable(item, pluto.tier_mt)

	local prev = pluto.tiers.byname[name]
	if (prev) then
		pluto.message("INV", "Merging tier ", name)
		table.Empty(prev)
		table.Merge(prev, item)
		item = prev
	end

	item.InternalName = name

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