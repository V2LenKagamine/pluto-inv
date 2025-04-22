--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]

pluto.quests.rewardhandlers = {
	currency = {
		reward = function(self, db, data)
			mysql_cmysql()

            local cur = self.Currency and pluto.currency.byname[self.Currency] or pluto.currency.random()
            local amount = self.Amount or 1

			pluto.inv.addcurrency(db, data.Player, self.Currency, amount)
			data.Player:ChatPrint(white_text, "You have received ", cur, " × ", amount, white_text, " for completing ", data:GetQuestData().Color, data:GetQuestData().Name, white_text, ".")

			return true
		end,
        small = function(self)
            if (self.Small) then
                return self.Small
            end

            local cur = pluto.currency.byname[self.Currency]
            local amount = self.Amount or 1

            return (amount == 1 and "" or  amount .. " ") .. cur.Name .. (amount == 1 and "" or "s")
        end,
	},
	weapon = {
		reward = function(self, db, data)
			mysql_cmysql()

			local classname = self.ClassName or (self.Grenade and pluto.weapons.randomgrenade()) --[[or (self.Melee and pluto.weapons.randommelee())]] or pluto.weapons.randomgun()

			local tier = self.Tier or pluto.tiers.filter(baseclass.Get(classname), function(t)
				if (self.ModMin and t.affixes < self.ModMin) then
					return false
				end

				if (self.ModMax and t.affixes > self.ModMax) then
					return false
				end

				return true
			end).InternalName

			local new_item = pluto.weapons.generatetier(tier, classname)

			for _, mod in ipairs(self.Mods or {}) do
				pluto.weapons.addmod(new_item, mod)
			end

			if (self.RandomImplicit) then
				local implicits = {
					Diced = true,
					Handed = true,
					Dropletted = true,
					Hearted = true,
				}

				local mod = table.shuffle(pluto.mods.getfor(baseclass.Get(classname), function(m)
					return (implicits[m.Name] or false)
				end))[1]

				pluto.weapons.addmod(new_item, mod.InternalName)
			end

			new_item.CreationMethod = "QUEST"
			pluto.inv.savebufferitem(db, data.Player, new_item)
			data.Player:ChatPrint(white_text, "You have received ", startswithvowel(new_item.Tier.Name) and "an " or "a ", new_item, white_text, " for completing ", data:GetQuestData().Color, data:GetQuestData().Name, white_text, "!")

			return true
		end,
		small = function(self)
			if (self.Small) then
				return self.Small
			end

			local smalltext = ""

			if (self.Tier) then
				smalltext = pluto.tiers.byname[self.Tier].Name .. " "
			end

			if (self.ClassName) then
				smalltext = smalltext .. baseclass.Get(self.ClassName).PrintName
			elseif (self.Grenade) then
				smalltext = smalltext .. "grenade"
			else
				smalltext = smalltext .. "gun"
			end

			local append = {}
			if (self.RandomImplicit) then
				table.insert(append, " a random implicit")
			end
			if (self.ModMin and self.ModMax) then
				if (self.ModMin == self.ModMax) then
					table.insert(append, " " .. tostring(self.ModMin) .. " mods")
				else
					table.insert(append, " between " .. tostring(self.ModMin) .. " and " .. tostring(self.ModMax) .. " mods")
				end
			elseif (self.ModMin) then
				table.insert(append, " at least " .. tostring(self.ModMin) .. " mods")
			elseif (self.ModMax) then
				table.insert(append, " at most " .. tostring(self.ModMax) .. " mods")
			end
			for _, text in ipairs(append) do
				smalltext = smalltext .. (_ == 1 and " with" or " and") .. text
			end

			return smalltext
		end,
	},
	shard = {
		reward = function(self, db, data)
			mysql_cmysql()

			local tier = self.Tier or pluto.tiers.filter(baseclass.Get(pluto.weapons.randomgun()), function(t)
				if (self.ModMin and t.affixes < self.ModMin) then
					return false
				end

				if (self.ModMax and t.affixes > self.ModMax) then
					return false
				end

				return true
			end).InternalName

			pluto.inv.generatebuffershard(db, data.Player, "QUEST", tier)
			tier = pluto.tiers.byname[tier]

			data.Player:ChatPrint(white_text, "You have received ", startswithvowel(tier.Name) and "an " or "a ", tier.Color, tier.Name, " Tier Shard", white_text, " for completing ", data:GetQuestData().Color, data:GetQuestData().Name, white_text, "!")

			return true
		end,
		small = function(self)
            if (self.Small) then
                return self.Small
            end

			local smalltext = "shard"

			if (self.Tier) then
				smalltext = pluto.tiers.byname[self.Tier].Name .. " " .. smalltext
			end

			local append = {}
			if (self.ModMin and self.ModMax) then
				if (self.ModMin == self.ModMax) then
					table.insert(append, " " .. tostring(self.ModMin) .. " mods")
				else
					table.insert(append, " between " .. tostring(self.ModMin) .. " and " .. tostring(self.ModMax) .. " mods")
				end
			elseif (self.ModMin) then
				table.insert(append, " at least " .. tostring(self.ModMin) .. " mods")
			elseif (self.ModMax) then
				table.insert(append, " at most " .. tostring(self.ModMax) .. " mods")
			end
			for _, text in ipairs(append) do
				smalltext = smalltext .. (_ == 1 and " with" or " and") .. text
			end

			return smalltext
		end,
	},
    bonus_dust = {
		reward = function(self, db, data)
			mysql_cmysql()

            local bonus_ducks = pluto.quests.rewards.bonus_dust[data.Type]
            local amount = bonus_ducks.amount + math.floor(math.random(-bonus_ducks.variance,bonus_ducks.variance + 1))

			pluto.inv.addcurrency(db, data.Player, "stardust", amount)
			data.Player:ChatPrint(white_text, "You have received ", "stardust", " × ", amount, white_text, " as a bonus for completing ", data:GetQuestData().Color, data:GetQuestData().Name, white_text, ".")

			return true
		end,
        small = function(quest)
            local cur = pluto.currency.byname.stardust
            local bonus_ducks = pluto.quests.rewards.bonus_dust[quest.Type]
            local amount = bonus_ducks.amount + math.floor(math.random(-bonus_ducks.variance,bonus_ducks.variance + 1))

            return (amount == 1 and "" or  amount .. " ") .. cur.Name
        end,
	},
}

pluto.quests.rewards = {
    bonus_dust = { -- This should never be used
		unique = {
            amount = 1200,
            variance = 200
        },
        hourly = {
            amount = 25,
            variance = 5
        },
        daily = {
            amount = 75,
            variance = 10
        },
        weekly = {
            amount = 600,
            variance = 80
        },
	},
	unique = { -- This should never be used
		{
			Type = "unique",
			Shares = 1,
		},
	},
	hourly = {
		{
			Type = "currency",
			Currency = "tome",
			Amount = 2,
			Shares = 1,
		},
		{
			Type = "currency",
			Currency = "aciddrop",
			Amount = 5,
			Shares = 1,
		},
		{
			Type = "currency",
			Currency = "pdrop",
			Amount = 5,
			Shares = 1,
		},
        {
			Type = "currency",
			Currency = "tp",
			Amount = 2,
            Shares = 1,
        },
		{
			Type = "weapon",
            Grenade = true,
			ModMin = 2,
			ModMax = 3,
			Shares = 1,
		},
        {
			Type = "weapon",
			ModMin = 4,
			ModMax = 4,
			Shares = 1,
		},
		{
			Type = "weapon",
			Tier = "inevitable",
			Shares = 2,
		},
		{
			Type = "shard",
			ModMin = 4,
			ModMax = 4,
			Shares = 1,
		},
		{
			Type = "shard",
			Tier = "promised",
			Shares = 0.5,
		},
	},
	daily = {
		{
			Type = "currency",
			Currency = "tome",
			Amount = 10,
			Shares = 1,
		},
		{
			Type = "currency",
			Currency = "aciddrop",
			Amount = 25,
			Shares = 1,
		},
		{
			Type = "currency",
			Currency = "pdrop",
			Amount = 25,
			Shares = 1,
		},
		{
			Type = "currency",
			Currency = "heart",
			Amount = 3,
			Shares = 1,
		},
        {
			Type = "currency",
			Currency = "tp",
			Amount = 5,
			Shares = 1,
        },
        {
			Type = "weapon",
            Grenade = true,
			ModMin = 3,
			ModMax = 4,
			Shares = 1,
		},
		{
			Type = "weapon",
			ClassName = "weapon_cod4_ak47_silencer",
			Tier = "uncommon",
			Shares = 0.5,
		},
		{
			Type = "weapon",
			ClassName = "weapon_cod4_m4_silencer",
			Tier = "uncommon",
			Shares = 0.5,
		},
		{
			Type = "weapon",
			ClassName = "weapon_cod4_m14_silencer",
			Tier = "uncommon",
			Shares = 0.5,
		},
		{
			Type = "weapon",
			ClassName = "weapon_cod4_g3_silencer",
			Tier = "uncommon",
			Shares = 0.5,
		},
		{
			Type = "weapon",
			ClassName = "weapon_cod4_g36c_silencer",
			Tier = "uncommon",
			Shares = 0.5,
		},
		{
			Type = "weapon",
			RandomImplicit = true,
			ModMin = 4,
			MoxMax = 5,
			Shares = 0.5,
		},
		{
			Type = "weapon",
			Tier = "uncommon",
			Mods = {"dropletted", "handed", "diced", "hearted"},
			Small = "Dropletted, Handed, Diced, Hearted Uncommon gun",
			Shares = 0.5,
		},
		{
			Type = "weapon",
			Tier = "common",
			Mods = {"tomed",},
			Small = "Tomed Common gun",
			Shares = 2,
		},
		{
			Type = "shard",
			ModMin = 5,
			ModMax = 5,
			Shares = 1,
		},
	},
	weekly = {
		{
			Type = "currency",
			Currency = "tome",
			Amount = 50,
			Shares = 0.5,
		},
		{
			Type = "currency",
			Currency = "coin",
			Amount = 1,
			Shares = 0.5,
		},
		{
			Type = "currency",
			Currency = "quill",
			Amount = 2,
			Shares = 1,
		},
		{
			Type = "weapon",
			ModMin = 6,
			ModMax = 6,
			Shares = 1,
		},
        {
			Type = "weapon",
            Grenade = true,
			ModMin = 3,
			ModMax = 4,
			Shares = 1,
		},
        {
			Type = "currency",
			Currency = "tp",
			Amount = 75,
			Shares = 1,
		},
		{
			Type = "weapon",
			Tier = "mystical",
			Mods = {"dropletted", "handed", "diced", "hearted"},
			Small = "Dropletted, Handed, Diced, Hearted Mystical gun",
			Shares = 1,
		},
		{
			Type = "weapon",
			Tier = "promised",
			Shares = 1,
		},
		{
			Type = "shard",
			ModMin = 5,
			ModMax = 6,
			Shares = 1,
		},
	},
}


function pluto.quests.poolreward(pick, db, quest)
	mysql_cmysql()

	local QUEST = quest:GetQuestData()
	if (QUEST.Reward) then
		return QUEST.Reward(quest) == true and pluto.quests.rewardhandlers["bonus_dust"].reward(pick, db, quest) == true
	end
	return pluto.quests.rewardhandlers[pick.Type].reward(pick, db, quest) == true and pluto.quests.rewardhandlers["bonus_dust"].reward(pick, db, quest) == true
end

function pluto.quests.poolrewardtext(pick, quest)
	local QUEST = quest:GetQuestData()
	if (QUEST.GetRewardText) then
		return QUEST.GetRewardText(quest) .. "&" .. pluto.quests.rewardhandlers["bonus_dust"].small(quest)
	end
	return pluto.quests.rewardhandlers[pick.Type].small(pick) .. " & " ..  pluto.quests.rewardhandlers["bonus_dust"].small(quest)
end
