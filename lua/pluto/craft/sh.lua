--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
pluto.craft = pluto.craft or {}
pluto.craft.max_shares = 3000

function pluto.craft.itemworth(item)
	if (not item) then
		return {}
	end

	if (item.Tier and item.Tier.CraftChance) then
		return {
			[item.ClassName] = pluto.craft.max_shares * item.Tier.CraftChance
		}
	end

	if (item.Type == "Weapon") then
		local tier = item.Tier.Shares / pluto.tiers.bytype.Weapon.shares
		local junk = pluto.tiers.byname.junk.Shares / pluto.tiers.bytype.Weapon.shares
		return {
			[item.ClassName] = junk / tier
		}
	end
	return {}
end

function pluto.craft.totalpercent(total)
	return math.min(0.95, total / pluto.craft.max_shares)
end

function pluto.craft.valid(items)
	local i1, i2, i3 = items[1], items[2], items[3]

	if (not i1 or i1.Type ~= "Shard") then
		return 1
	end

	if (not i2 or i2.Type ~= "Shard") then
		return 2
	end

	if (not i3 or i3.Type ~= "Shard") then
		return 3
	end

	for i = 4, 7 do
		local item = items[i]
		if (item and item.Type ~= "Weapon") then
			return i
		end
	end

	return
end