--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
local function defaulttierbias(mod)
	return math.random(1, #mod.Tiers)
end
local function defaultroll(mod, tier)
	local needed = #mod.Tiers[tier] / 2

	local retn = {}
	for i = 1, needed do
		retn[i] = math.random()
	end

	return retn
end

function pluto.mods.rollmod(mod, rolltier, roll)
	rolltier = rolltier or defaulttierbias
	roll = roll or defaultroll

	local tier = rolltier(mod)

	return {
		Roll = roll(mod, tier),
		Tier = tier,
		Mod = mod.InternalName
	}
end

--[[
	affixcount = 6
	prefixmax = 3
	suffixmax = 3

	-- optional
	guaranteed = {
		strength = 1, -- guarantee strength tier 1
		recoil = true, -- guarantee recoil any tier
	}

	-- optional
	tagbiases = {
		damage = 100, -- 100x as likely
		accuracy = 0, -- 0x as likely (don't role)
	}

	-- optional
	function rolltier(mod)
		return math.random(1, #mod.Tiers)
	end

	-- optional
	function roll(mod, tier)
		local needed = #mod.Tiers[tier] / 2

		local retn = {}
		for i = 1, needed do
			retn[i] = math.random()
		end

		return retn
	end
]]

function pluto.mods.bias(wpn, list, biases)
	biases = biases or {}

	local retn = {}

	for _, item in pairs(list) do
		if (item.Retired or wpn and item.CanRollOn and not item:CanRollOn(wpn)) then
			continue
		end

		local dontadd = false

		local bias = 1
		for name, amt in pairs(biases) do
			if (item.Tags[name]) then
				bias = bias * amt
			end
		end

		if (not dontadd) then
			retn[#retn + 1] = {
				item = item,
				roll = math.random() * bias
			}
		end
	end

	table.sort(retn, function(a, b)
		return b.roll < a.roll
	end)

	for k, v in pairs(retn) do
		retn[k] = v.item
	end

	return retn
end

function pluto.mods.generateaffixes(wpn, affixcount, prefixmax, suffixmax, guaranteed, tagbiases, rolltier, roll, notallowed)
	local typedmods = pluto.mods.byitem[pluto.weapons.type(wpn)]

	local retn = {
		suffix = {},
		prefix = {}
	}

	if (not typedmods) then
		return retn
	end

	local allowed = {
		prefix = prefixmax or math.max(affixcount - 3, 3),
		suffix = suffixmax or 3
	}

	notallowed = notallowed or {}

	if (guaranteed) then
		for modname, data in pairs(guaranteed) do
			local mod = typedmods.byname[modname]
			if (not mod) then
				pwarnf("Mod %s doesn't exist.\n%s", modname, debug.traceback())
				continue
			end

			if (not allowed[mod.Type] or allowed[mod.Type] <= 0 or affixcount <= 0) then
				pwarnf("Mod %s cannot be added due to restrictions.\n%s", modname, debug.traceback())
				continue
			end

			local tierroll = data == true and rolltier or function() return data end

			table.insert(retn[mod.Type], pluto.mods.rollmod(mod, tierroll, roll))
			affixcount = affixcount - 1

			allowed[mod.Type] = allowed[mod.Type] - 1

			notallowed[mod.InternalName] = true
		end
	end


	local potential = {
		suffix = pluto.mods.bias(wpn, typedmods.suffix, tagbiases),
		prefix = pluto.mods.bias(wpn, typedmods.prefix, tagbiases),
		current = {
			suffix = 1,
			prefix = 1,
		}
	}

	for i = #potential.suffix, 1, -1 do
		local mod = potential.suffix[i]
		if (notallowed[mod.InternalName]) then
			table.remove(potential.suffix, i)
		end
	end

	for i = #potential.prefix, 1, -1 do
		local mod = potential.prefix[i]
		if (notallowed[mod.InternalName]) then
			table.remove(potential.prefix, i)
		end
	end

	for i = 1, affixcount do
		local chosenaffix = math.random(1, 2) == 1 and "suffix" or "prefix"

		if (allowed[chosenaffix] <= 0 or potential.current[chosenaffix] > #potential[chosenaffix]) then
			chosenaffix = chosenaffix == "suffix" and "prefix" or "suffix"

			if (allowed[chosenaffix] <= 0 or potential.current[chosenaffix] > #potential[chosenaffix]) then
				break
			end
		end

		local mod = potential[chosenaffix][potential.current[chosenaffix]]
		potential.current[chosenaffix] = potential.current[chosenaffix] + 1
		allowed[chosenaffix] = allowed[chosenaffix] - 1

		table.insert(retn[mod.Type], pluto.mods.rollmod(mod, rolltier, roll))
	end


	return retn
end

function pluto.mods.getfor(gun, filter)
	local list = {}
	local typedmods = pluto.mods.byitem[pluto.weapons.type(gun)]

	for _, modlist in pairs(typedmods) do
		for _, mod in pairs(modlist) do
			if (wpn and item.CanRollOn and not item:CanRollOn(gun)) then
				continue
			end
		
			if (filter and not filter(mod)) then
				continue
			end

			table.insert(list, mod)
		end
	end

	return list
end


concommand.Add("pluto_add_mod", function(ply, cmd, args)
	if (not pluto.cancheat(ply)) then
		return
	end

	local item = pluto.itemids[tonumber(args[1])]

	if (not item) then
		ply:ChatPrint "Couldn't find itemid!"
		return
	end

	local mod = pluto.mods.byname[args[2]]

	if (not mod) then
		ply:ChatPrint "Couldn't find mod!"
		return
	end

	local owner = player.GetBySteamID64(item.Owner)

	if (not IsValid(owner)) then
		ply:ChatPrint "Owner isn't on!"
		return
	end

	pluto.weapons.addmod(item, args[2], args[3] and tonumber(args[3]) or nil)
	
	pluto.db.transact(function(db)
		pluto.weapons.update(db, item)
		mysql_commit(db)
	end)

	pluto.inv.message(owner)
		:write("item", item)
		:send()
end)


concommand.Add("pluto_remove_mods", function(ply, cmd, args)
	if (not pluto.cancheat(ply)) then
		return
	end

	local item = pluto.itemids[tonumber(args[1])]

	if (not item) then
		ply:ChatPrint "Couldn't find itemid!"
		return
	end

	local owner = player.GetBySteamID64(item.Owner)

	if (not IsValid(owner)) then
		ply:ChatPrint "Owner isn't on!"
		return
	end
	
	item.Mods = {
		prefix = {},
		suffix = {},
	}

	pluto.db.transact(function(db)
		pluto.weapons.update(db, item)
		mysql_commit(db)
	end)

	pluto.inv.message(owner)
		:write("item", item)
		:send()
end)