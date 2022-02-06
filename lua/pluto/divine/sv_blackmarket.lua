--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
local CURR = pluto.currency.byname.tp
local options = {
	-- NEVER REMOVE ITEMS, SET SHARES TO 0
	{
		Shares = 1,
		Price = 455,
		Item = setmetatable({
			Type = "Weapon",
			Mods = {},
			ClassName = "weapon_neszapper",
			Tier = pluto.tiers.byname.legendary,
		}, pluto.inv.item_mt)
	},
	{
		Shares = 1,
		Price = 475,
		Item = setmetatable({
			Type = "Weapon",
			Mods = {},
			ClassName = "weapon_raygun",
			Tier = pluto.tiers.byname.legendary,
		}, pluto.inv.item_mt)
	},
	{
		Shares = 1,
		Price = 520,
		Item = setmetatable({
			Type = "Weapon",
			Mods = {},
			ClassName = "weapon_ttt_deagle_gold",
			Tier = pluto.tiers.byname.unique,
		}, pluto.inv.item_mt)
	},
	{
		Shares = 1,
		Price = 500,
		Item = setmetatable({
			Type = "Weapon",
			Mods = {},
			ClassName = "tfa_cso_elvenranger",
			Tier = pluto.tiers.byname.legendary,
		}, pluto.inv.item_mt)
	},
	{
		Shares = 1,
		Price = 498,
		Item = setmetatable({
			Type = "Weapon",
			Mods = {},
			ClassName = "weapon_lightsaber_rainbow",
			Tier = pluto.tiers.byname.unique,
		}, pluto.inv.item_mt)
	},
	{
		Shares = 1,
		Price = 450,
		Item = setmetatable({
			Type = "Weapon",
			Mods = {},
			ClassName = "weapon_cbox",
			Tier = pluto.tiers.byname.unique,
		}, pluto.inv.item_mt)
	},
	{
		Shares = 1,
		Price = 350,
		Item = setmetatable({
			Type = "Weapon",
			Mods = {},
			ClassName = "weapon_lightsaber_rb",
			Tier = pluto.tiers.byname.unique,
		}, pluto.inv.item_mt)
	},
	{
		Shares = 1,
		Price = 335,
		Item = setmetatable({
			Type = "Weapon",
			Mods = {},
			ClassName = "tfa_cso_skull1",
			Tier = pluto.tiers.byname.legendary,
		}, pluto.inv.item_mt)
	},
	{
		Shares = 1,
		Price = 355,
		Item = setmetatable({
			Type = "Weapon",
			Mods = {},
			ClassName = "tfa_cso_skull5",
			Tier = pluto.tiers.byname.legendary,
		}, pluto.inv.item_mt)
	},
	{
		Shares = 1,
		Price = 315,
		Item = setmetatable({
			Type = "Weapon",
			Mods = {},
			ClassName = "tfa_cso_skull9",
			Tier = pluto.tiers.byname.unique,
		}, pluto.inv.item_mt)
	},
	{
		Shares = 1,
		Price = 435,
		Item = setmetatable({
			Type = "Weapon",
			Mods = {},
			ClassName = "tfa_cso_batista",
			Tier = pluto.tiers.byname.legendary,
		}, pluto.inv.item_mt)
	},
	{
		Shares = 1,
		Price = 415,
		Item = setmetatable({
			Type = "Weapon",
			Mods = {},
			ClassName = "tfa_cso_paladin",
			Tier = pluto.tiers.byname.legendary,
		}, pluto.inv.item_mt)
	},
}

pluto.divine = pluto.divine or {}
pluto.divine.blackmarket = pluto.divine.blackmarket or {}

local function init()
	pluto.db.transact(function(db)
		local offers = {}
		mysql_query(db, "LOCK TABLES pluto_blackmarket WRITE")
		mysql_query(db, "SET @date = date(convert_tz(now(),@@session.time_zone,'-1:00'))") -- updates at 9 pm EST
		local data = mysql_query(db, "SELECT idx, IF(@date = `date`, 1, 0) as is_active, what, sold FROM pluto_blackmarket")
		for _, data in ipairs(data) do
			if (data.is_active == 0) then
				data.what = pluto.inv.roll(options)
				print ("?", data.what)
				data.sold = 0
				data.new = true
				mysql_stmt_run(db, "UPDATE pluto_blackmarket SET `date` = @date, what = ?, sold = 0 WHERE idx = ?", data.what, data.idx)
			end

			if (data.sold == 0) then
				offers[data.idx] = data.what
			end
		end
		mysql_query(db, "UNLOCK TABLES")
		mysql_commit(db)

		pluto.divine.blackmarket.next = os.time() + mysql_query(db, "SELECT TIMESTAMPDIFF(SECOND, CURRENT_TIMESTAMP, TIMESTAMP(convert_tz(@date,'-1:00',@@session.time_zone)) + interval 1 day) as remaining;")[1].remaining

		local msg = discord.Message()
			:SetText("=== BLACKMARKET RESTOCK ===")
		local send = false
		for _, offer in ipairs(data) do
			if (offer.new) then
				local what = options[offer.what]
				if (what.Item) then
					msg:AddEmbed(
						what.Item:GetDiscordEmbed()
							:SetAuthor(what.Price .. " " .. CURR.Name)
							:SetTimestamp()
					)
					send = true
				end
			end
		end

		if (send) then
			msg:Send "stardust-shop"
		end

		pluto.divine.blackmarket.offers = offers
	end)
end

hook.Add("OnPlutoDatabaseInitialized", "pluto_blackmarket", init)

concommand.Add("pluto_send_blackmarket", function(p)
	pluto.inv.message(p)
		:write "blackmarket"
		:send()
end)

concommand.Add("pluto_blackmarket_buy_offer", function(p, cmd, args)
	local idx = tonumber(args[1])
	local offerid = pluto.divine.blackmarket.offers[idx]
	local what = options[offerid]
	if (not what) then
		p:ChatPrint "Error: Invalid item."
		return
	end

	if (what.Item.ClassName ~= args[2]) then
		p:ChatPrint "Error: Invalid item."
		return
	end

	local item = what.Item:Duplicate()
	item.CreationMethod = "BOUGHT"

	p:ChatPrint "Buying item..."

	pluto.db.transact(function(db)
		if (not pluto.inv.addcurrency(db, p, CURR.InternalName, -what.Price)) then
			p:ChatPrint("Error: You do not have enough ", CURR, " to buy that")
			mysql_rollback(db)
			return
		end
		local succ = mysql_stmt_run(db, "UPDATE pluto_blackmarket SET sold = sold + 1 WHERE idx = ? AND sold = 0", idx)
		if (not succ or succ.AFFECTED_ROWS ~= 1) then
			p:ChatPrint "Error: Item already sold"
			mysql_rollback(db)
			return
		end
		pluto.divine.blackmarket.offers[idx] = nil

		pluto.inv.savebufferitem(db, p, item)
		
		p:ChatPrint("You have bought ", item, " for " .. what.Price .. " ", CURR)

		-- TODO(Addi) Update Tab to remove bought item

		mysql_commit(db)
		hook.Run("PlutoCurrencySpent", p, CURR.InternalName, what.Price)
	end)
end)

concommand.Add("pluto_blackmarket_buy", function(p, cmd, args)
	local num = tonumber(args[1])

	p:ChatPrint "Buying item..."

	if (num == 1) then
		pluto.db.transact(function(db)
			if (not pluto.inv.addcurrency(db, p, CURR.InternalName, -195)) then
				p:ChatPrint("Error: You do not have enough ", CURR, " to buy that")
				mysql_rollback(db)
				return
			end
			pluto.inv.addcurrency(db, p, "potato", 1)
			p:ChatPrint("You bought a ", pluto.currency.byname.potato, " for 195 ", CURR)
			mysql_commit(db)
			hook.Run("PlutoCurrencySpent", p, CURR.InternalName, 195)
		end)
	elseif (num == 2) then
		pluto.db.transact(function(db)
			if (not pluto.inv.addcurrency(db, p, CURR.InternalName, -60)) then
				p:ChatPrint("Error: You do not have enough ", CURR, " to buy that")
				mysql_rollback(db)
				return
			end
			local item = pluto.inv.generatebuffershard(db, p, "BOUGHT", (table.Random(pluto.tiers.filter_real("Weapon", function(tier) return tier.affixes >= 5 end))).InternalName)
			p:ChatPrint("You bought a ", item, " for 60 ", CURR)
			mysql_commit(db)
			hook.Run("PlutoCurrencySpent", p, CURR.InternalName, 60)
		end)
	elseif (num == 3) then
		pluto.db.transact(function(db)
			local unlocked
			for emoji in RandomPairs(pluto.emoji.byname) do
				if (not pluto.emoji.unlocks[p][emoji]) then
					unlocked = emoji
					break
				end
			end

			if (not unlocked) then
				p:ChatPrint("Error: You already own all emojis")
				return
			end


			if (not pluto.inv.addcurrency(db, p, CURR.InternalName, -5)) then
				p:ChatPrint("Error: You do not have enough ", CURR, " to buy that.")
				mysql_rollback(db)
				return
			end

			pluto.emoji.unlock(db, p, unlocked)

			mysql_commit(db)
			hook.Run("PlutoCurrencySpent", p, CURR.InternalName, 5)
		end)

	else
		p:ChatPrint "Error: Invalid item"
	end
end)

function pluto.inv.writeblackmarket(cl)
	net.WriteUInt(math.max(0, pluto.divine.blackmarket.next - os.time()), 32)
	for id, offer in pairs(pluto.divine.blackmarket.offers) do
		local what = options[offer]
		net.WriteUInt(id, 8)
		net.WriteUInt(what.Price, 32)
		pluto.inv.writebaseitem(cl, what.Item)
	end
	net.WriteUInt(0, 8)
end