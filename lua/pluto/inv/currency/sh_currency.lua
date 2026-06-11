--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
pluto.currency = pluto.currency or {}
pluto.currency.byname = pluto.currency.byname or {}

local list = {
	{
		InternalName = "droplet",
		Name = "Sapphire Droplet",
		Icon = "pluto/currencies/droplet.png",
		Description = "Removes all modifiers and rolls new ones",
		SubDescription = "Some kind of crystal.",
		Color = Color(24, 125, 216),
		Crafted = {
			Chance = 1 / 4,
			Mod = "dropletted",
            ChanceDeminish = 10,
		},
		StardustRatio = 2,

		Category = "Modify",
		AllowMass = true,
        Amount = {
            Min = 1,
            Max = 5,
            Chance = 50,
        },
	},
	{
		InternalName = "aciddrop",
		Name = "Jade Droplet",
		Icon = "pluto/currencies/green_droplet.png",
		Description = "Rerolls prefix modifiers on an item",
		SubDescription = "Some kind of crystal made of a strange jade.",
		Color = Color(11, 84, 51),
		StardustRatio = 75,

		Category = "Modify",
		AllowMass = true,
        Amount = {
            Min = 1,
            Max = 3,
            Chance = 25,
        },
	},
	{
		InternalName = "pdrop",
		Name = "Amethyst Droplet",
		Icon = "pluto/currencies/purple_droplet.png",
		Description = "Rerolls suffix modifiers on an item",
		SubDescription = "Some kind of crystal imbued with a strange energy.",
		Color = Color(117, 28, 178),
		StardustRatio = 100,

		Category = "Modify",
		AllowMass = true,
        Amount = {
            Min = 1,
            Max = 3,
            Chance = 25,
        },
	},
	{
		InternalName = "hand",
		Name = "Golden Monkey Paw",
		Icon = "pluto/currencies/goldenhand.png",
		Description = "Remove random mod,+1 tier of another",
		SubDescription = "Some kind primates' paw, coated in gold.",
		Color = Color(255, 208, 86),
		Crafted = {
			Chance = 1 / 4,
			Mod = "handed",
            ChanceDeminish = 5,
		},
		StardustRatio = 5,

		Category = "Modify",
        Amount = {
            Min = 1,
            Max = 3,
            Chance = 20,
        },
	},
	{
		InternalName = "dice",
		Name = "Fate's Die",
		Icon = "pluto/currencies/dice.png",
		Description = "Randomizes all the rolls on modifiers",
		SubDescription = "A die made of unknown material, coated in gold.",
		Color = Color(255, 208, 86),
		Crafted = {
			Chance = 1 / 3,
			Mod = "diced",
            ChanceDeminish = 15
		},
		StardustRatio = 4,

		Category = "Modify",
        Amount = {
            Min = 3,
            Max = 6,
            Chance = 40,
        },
	},
	{
		InternalName = "tome",
		Name = "Forbidden Tome",
		Icon = "pluto/currencies/tome.png",
		Description = "Corrupts an item unpredictably",
		SubDescription = "A book containing secrets not meant for most.",
		Color = Color(142, 94, 166),
		Crafted = {
			Chance = 1 / 5,
			Mod = "tomed",
            ChanceDeminish = 2.5 
		},
		StardustRatio = 90,

		Category = "Modify",
        Amount = {
            Min = 1,
            Max = 2,
            Chance = 33,
        },
	},
	{
		InternalName = "endround",
		Name = "Weapons Crate",
		Icon = "pluto/currencies/crate0.png",
		Description = "Contains a random base weapon!",
		SubDescription = "An inconspicuous crate, probably holds a weapon.",
		NoTarget = true,
		Color = Color(133, 92, 58),
		ClientsideUse = function()
			if (IsValid(pluto.opener)) then
				pluto.opener:Remove()
			end

			pluto.opener = vgui.Create "tttrw_base"

			pluto.opener:AddTab("Open Box", vgui.Create "pluto_box_open" :SetCurrency "endround")

			pluto.opener:SetSize(640, 400)
			pluto.opener:Center()
			pluto.opener:MakePopup()
		end,

		Category = "Unbox",
	},
	{
		InternalName = "crate0",
		Name = "Model Egg",
		Icon = "pluto/currencies/crate0_new.png",
		Description = "Contains a model of times past",
		SubDescription = "You hear whispers from inside...",
		NoTarget = true,
		Color = Color(71, 170, 222),
		ClientsideUse = function()
			if (IsValid(pluto.opener)) then
				pluto.opener:Remove()
			end

			pluto.opener = vgui.Create "tttrw_base"

			pluto.opener:AddTab("Open Box", vgui.Create "pluto_box_open" :SetCurrency "crate0")

			pluto.opener:SetSize(640, 400)
			pluto.opener:Center()
			pluto.opener:MakePopup()
		end,
        RareDesc = true,
		Contents = {
            model_metro_male_1 = { Chance = 40 },
            model_metro_male_2 = { Chance = 40 },
            model_metro_male_3 = { Chance = 40 },
            model_metro_male_4 = { Chance = 40 },
            model_metro_male_5 = { Chance = 40 },
            model_metro_male_6 = { Chance = 40 },
            model_metro_male_7 = { Chance = 40 },
            model_metro_male_8 = { Chance = 40 },
            model_metro_male_9 = { Chance = 40 },
            model_metro1 = { Chance = 40 },
            model_metro2 = { Chance = 40 },
            model_metro3 = { Chance = 40 },
            model_metro4 = { Chance = 40 },
            model_metro5 = { Chance = 40 },
            model_metro6 = { Chance = 40 },
            model_metro_female_1 = { Chance = 40 },
            model_metro_female_2 = { Chance = 40 },
            model_metro_female_3 = { Chance = 40 },
            model_metro_female_4 = { Chance = 40 },
            model_metro_female_5 = { Chance = 40 },
            model_metro_female_6 = { Chance = 40 },
            model_ghilliewinter01 = { Chance = 30 },
            model_snow1 = { Chance = 30 },
            model_snow2 = { Chance = 30 },
            model_snow3 = { Chance = 30 },
            model_snow4 = { Chance = 30 },
            model_snow5 = { Chance = 30 },
            model_snow6 = { Chance = 30 },
            model_snow7 = { Chance = 30 },
            model_husk = { Chance = 30 },
            model_hunk = { Chance = 30 },
            model_violet_spart = { Chance = 20 },
            model_gold_spart = { Chance = 20 },
            model_pink_spart = { Chance = 20 },
            model_green_spart = { Chance = 20 },
            model_orange_spart = { Chance = 20 },
            model_steel_spart = { Chance = 20 },
            model_tan_spart = { Chance = 20 },
            model_blue_spart = { Chance = 20 },
            model_sage_spart = { Chance = 20 },
            model_crimson_spart = { Chance = 20 },
            model_cobalt_spart = { Chance = 20 },
            model_cyan_spart = { Chance = 20 },
            model_olive_spart = { Chance = 20 },
            model_purple_spart = { Chance = 20 },
            model_red_spart = { Chance = 20 },
            model_teal_spart = { Chance = 20 },
            model_white_spart = { Chance = 20 },
            model_brown_spart = { Chance = 20 },
            model_plague = { Chance = 10 },
            model_daedric = { Chance = 10 },
            model_wick2 = { Chance = 10 },
            model_odst = { Chance = 10 },
            model_captain = { Chance = 10 },
            model_sergeant = { Chance = 10 },
            model_general = { Chance = 10 },
            model_commander = { Chance = 10 },
            model_clone = { Chance = 10 },
            model_lieutenant = { Chance = 10 },
            model_bomb_squad = { Chance = 10 },
            model_bigboss = { Chance = 10 },
            model_hevsuit = { Chance = 10 },
            model_doomguy = { Chance = 10 },
            model_jacket = { Chance = 10 },
            model_tachanka = { Chance = 10 },
            model_raincoat = { Chance = 10 },
            model_tron_anon = { Chance = 10 },
            model_sauron = { Chance = 10 },
            model_lilith = { Chance = 2.5 },
            model_zer0 = { Chance = 2.5 },
            model_psycho = { Chance = 2.5 },
            model_ror2_commando = { Chance = 0.1, Rare = true },
            model_spy = { Chance = 0.1, Rare = true },
            model_spacesuit = { Chance = 0.1, Rare = true },
            model_master_chief = { Chance = 0.1, Rare = true },
            model_osrsbob = { Chance = 0.1, Rare = true },
		},

		Category = "Unbox",
	},
	{
		InternalName = "heart",
		Name = "Ruby Heart",
		Icon = "pluto/currencies/heart.png",
		Description = "Adds a random modifier.",
		SubDescription = "A heart shaped ruby, teeming with strange energy.",
		Color = Color(204, 43, 75),
		Crafted = {
			Chance = 1 / 2,
			Mod = "hearted",
            ChanceDeminish = 2,
		},
		StardustRatio = 250,

		Category = "Modify",
	},
	{
		InternalName = "coin",
		Name = "Golden Coin",
		Icon = "pluto/currencies/coin.png",
		Description = "Adds a storage tab.",
		SubDescription = "A solid gold coin!",
		Color = Color(254, 233, 105),
		NoTarget = true,
		Crafted = {
			Chance = 1/2,
			Mod = "new_coined",
            ChanceDeminish = 5,
		},
		StardustRatio = 6000,
	},
	{
		InternalName = "mirror",
		Name = "Enchanted Mirror",
		Icon = "pluto/currencies/mirrormagic.png",
		Description = "Creates a mirror image of an item which is unmodifiable.",
		SubDescription = "A strange mirror, you could almost reach inside...",
		Color = Color(177, 173, 205),

		Category = "Modify",
	},
	{
		InternalName = "quill",
		Name = "Glass Quill",
		Icon = "pluto/currencies/quill.png",
		Description = "Set an item's nickname",
		SubDescription = "A quill of glass, commonly used for those who desire to write history.",
		Color = Color(23, 127, 105),
		StardustRatio = 9000,
		ClientsideUse = function(item)
			if (item.Nickname) then
				chat.AddText(white_text, "You must remove that item's name before naming it again!")
				return
			end

			if (IsValid(pluto.opener)) then
				pluto.opener:Remove()
			end

			pluto.opener = vgui.Create "tttrw_base"

			local cat = vgui.Create "ttt_settings_category"
			local text = cat:AddTextEntry("What will this item's new name be?", true)
			local seent = cat:AddTextEntry("This will be seen as")
			local accept = cat:AddLabelButton "Rename!"
			cat:InvalidateLayout(true)
			cat:SizeToContents()

			function text:OnChange()
				seent:SetText('"' .. string.formatsafe(self:GetText(), item:GetDefaultName()) .. '"')
			end

			function text:AllowInput(c)
				if (self:GetText():len() + c:len() > 32) then
					return true
				end
			end

			function accept:DoClick()
				if (IsValid(pluto.opener)) then
					pluto.opener:Remove()
				end

				pluto.inv.message()
					:write("rename", item.ID, text:GetText())
					:send()
			end


			pluto.opener:AddTab("Rename!", cat)

			pluto.opener:SetSize(640, 400)
			pluto.opener:Center()
			pluto.opener:MakePopup()
		end,

		Category = "Modify",
	},
	{
		InternalName = "tp",
		Name = "Refinium Vial",
		GroundData = {
			Icon = "pluto/currencies/refined_ingot.png",
			Amount = 25,
		},
		Icon = "pluto/currencies/plutonicvial.png",
		Description = "Valuable Black Market Currency",
		SubDescription = "A vial of... Something. Someone must want this, right?",
		Color = Color(150, 50, 213),
	},
	--[[{
		InternalName = "eye",
		Name = "Eye",
		Icon = "pluto/currencies/eye.png",
		Description = "Spawns a Void boss",
		SubDescription = "I see the void envelop you, friend... embrace me.",
		Color = Color(107, 25, 14),
	},--]]
	{
		InternalName = "stardust",
		Name = "Stardust",
		Icon = "pluto/currencies/stardust.png",
		Description = "Currency for the Star-Exchange",
		SubDescription = "Hot, yet cold. Twinkles strangely.",
		Color = Color(254, 233, 105),
		NoTarget = true,
		ClientsideUse = function()
		end,
        Crafted = {
			Chance = 1 / 100,
			Mod = "starseeker",
            ChanceDeminish = 2,
		},
	},
	{
		InternalName = "ticket",
		Shares = 0,
		Name = "Round Ticket",
		Icon = "pluto/currencies/ticket.png",
		Description = "Exchanged to activate special rounds",
		SubDescription = "What will be your fate, I wonder?",
		Color = Color(153, 0, 0),
		NoTarget = true,
		ClientsideUse = function()
			if IsValid(pluto.ui.pnl) then
				pluto.ui.pnl:ChangeToTab("Events")
			end
		end,
	},
	{
		InternalName = "_shootingstar",
		Name = "Shooting Star",
		Icon = "pluto/currencies/stardust.png",
		Color = Color(254, 233, 105),
		Fake = true,
		SkipNotify = true,
        Amount = {
            Min = 5,
            Max = 10,
            Chance = 50,
        },
	},
	{
		InternalName = "_lightsaber",
		Name = "FAKE: Lightsaber",
		Icon = "lightsaber/lightsaber_killicon.png",
		Color = color_white,
		Fake = true,
		SkipNotify = true
	},
	{
		InternalName = "_banna",
		Name = "Banna",
		Icon = "pluto/currencies/banna.png",
		Color = Color(204, 180, 0),
		Fake = true,
		SkipNotify = true
	},
	{
		InternalName = "_toy_blue",
		Name = "Blue Toy",
		Icon = "pluto/currencies/toy_blue.png",
		Color = Color(0, 0, 255),
		Fake = true,
		SkipNotify = true
	},
	{
		InternalName = "_toy_green",
		Name = "Green Toy",
		Icon = "pluto/currencies/toy_green.png",
		Color = Color(0, 255, 0),
		Fake = true,
		SkipNotify = true
	},
	{
		InternalName = "_toy_red",
		Name = "Red Toy",
		Icon = "pluto/currencies/toy_red.png",
		Color = Color(255, 0, 0),
		Fake = true,
		SkipNotify = true
	},
	{
		InternalName = "_toy_yellow",
		Name = "Yellow Toy",
		Icon = "pluto/currencies/toy_yellow.png",
		Color = Color(255, 255, 0),
		Fake = true,
		SkipNotify = true
	},
	{
		InternalName = "_chancedice",
		Name = "Chance Dice",
		Icon = "pluto/currencies/chancedice.png",
		Color = Color(255, 175, 75),
		Fake = true,
		SkipNotify = true
	},
	{
		Shares = 0,
		InternalName = "_emojibag",
		Name = "Emoji Grab-Bag",
		Icon = "pluto/emoji/b1.png",
		Color = Color(192, 191, 190),
		SkipNotify = true,
		Fake = true,
		NoTarget = true,
		Category = "Unbox",
	},
	{
		Shares = 0,
		InternalName = "_quill",
		Name = "Quill",
		Icon = "pluto/currencies/gold_quill.png",
		Color = Color(255, 213, 0),
		SkipNotify = true,
		Fake = true,
	},
    //Pluto attempt 2 begins here
    {
		InternalName = "crate_cons1",
		Name = "Supplies Crate : E1",
		Icon = "pluto/currencies/cratecon.png",
		Description = "A crate, containing supportive items.",
		SubDescription = "The crude spray-paint seems to imply it's contents are probably not weapons.",
		NoTarget = true,
		Color = Color(133, 92, 58),
		ClientsideUse = function()
			if (IsValid(pluto.opener)) then
				pluto.opener:Remove()
			end

			pluto.opener = vgui.Create "tttrw_base"

			pluto.opener:AddTab("Open Box", vgui.Create("pluto_box_open"):SetCurrency("crate_cons1"))

			pluto.opener:SetSize(640, 400)
			pluto.opener:Center()
			pluto.opener:MakePopup()
		end,
        RareDesc = true,
		Contents = {
			consumable_pluto_adren = {
				Tier = "generic",
				Chance = 10,
			},
            consumable_pluto_antidot = {
				Tier = "generic",
				Chance = 10,
			},
            consumable_pluto_htmk = {
				Tier = "generic",
				Chance = 10,
			},
            consumable_pluto_nano_bandage = {
				Tier = "generic",
				Chance = 10,
			},
            consumable_pluto_rage = {
				Tier = "generic",
				Chance = 10,
			},
            consumable_pluto_regenerator = {
				Tier = "generic",
				Chance = 10,
			},
            consumable_pluto_sight = {
				Tier = "generic",
				Chance = 10,
			},
            consumable_pluto_slregenerator = {
				Tier = "generic",
				Chance = 10,
			},
            consumable_pluto_stak = {
				Tier = "generic",
				Chance = 10,
			},
            consumable_pluto_tmk = {
				Tier = "generic",
				Chance = 10,
			},
            consumable_pluto_tsk = {
				Tier = "generic",
				Chance = 10,
			},
            consumable_ttt_buildawall = {
				Rare = true,
				Tier = "generic",
				Chance = 2,
			},
		},
		Category = "Unbox",
	},
    {
		InternalName = "crate_nade1",
		Name = "Grenade Crate : E1",
		Icon = "pluto/currencies/cratenade.png",
		Description = "A crate, containing throwable weapons.",
		SubDescription = "FRAG OUT!",
		NoTarget = true,
		Color = Color(133, 92, 58),
		ClientsideUse = function()
			if (IsValid(pluto.opener)) then
				pluto.opener:Remove()
			end

			pluto.opener = vgui.Create "tttrw_base"

			pluto.opener:AddTab("Open Box", vgui.Create("pluto_box_open"):SetCurrency("crate_nade1"))

			pluto.opener:SetSize(640, 400)
			pluto.opener:Center()
			pluto.opener:MakePopup()
		end,
        RareDesc = true,
		Category = "Unbox",
        Contents = {
			weapon_ttt_barrel_grenade = {
				Chance = 12.5,
			},
            weapon_ttt_big_boy = {
				Chance = 12.5,
			},
            weapon_ttt_cherry_bombs = {
				Chance = 12.5,
			},
            weapon_ttt_rolling_thunder = {
				Chance = 12.5,
			},
            weapon_pluto_thermite = {
				Chance = 12.5,
			},
            weapon_ttt_molotov = {
				Chance = 12.5,
			},
            weapon_ttt_smoke_grenade = {
				Chance = 12.5,
			},
            weapon_ttt_sticky_grenade = {
				Chance = 12.5,
			},
            tfa_cso_pumpkin = {
                Rare = true,
                Tier = "unique",
                Chance = 2,
            },
		},
	},
    {
		InternalName = "crate_toy1",
		Name = "Toy Crate : E1",
		Icon = "pluto/currencies/cratetoy.png",
		Description = "A crate, containing fun, but useless, curiosities.",
		SubDescription = ":smiel:",
		NoTarget = true,
		Color = Color(133, 92, 58),
		ClientsideUse = function()
			if (IsValid(pluto.opener)) then
				pluto.opener:Remove()
			end

			pluto.opener = vgui.Create "tttrw_base"

			pluto.opener:AddTab("Open Box", vgui.Create("pluto_box_open"):SetCurrency("crate_toy1"))

			pluto.opener:SetSize(640, 400)
			pluto.opener:Center()
			pluto.opener:MakePopup()
		end,
		Category = "Unbox",
        RareDesc = true,
        DefaultTier = "regular",
        Contents = {
			miscitem_fumo_cirno = {
				Chance = 12.5,
			},
            miscitem_fumo_flandre = {
				Chance = 12.5,
			},
            miscitem_fumo_junko = {
				Chance = 12.5,
			},
            miscitem_fumo_keiki = {
				Chance = 12.5,
			},
            miscitem_fumo_koishi = {
				Chance = 12.5,
			},
            miscitem_fumo_marisa = {
				Chance = 12.5,
			},
            miscitem_fumo_mokou = {
				Chance = 12.5,
			},
            miscitem_fumo_momiji = {
				Chance = 12.5,
			},
            miscitem_fumo_okuu = {
				Chance = 12.5,
			},
            miscitem_fumo_reimu = {
				Chance = 12.5,
			},
            miscitem_fumo_remi = {
				Chance = 12.5,
			},
            miscitem_fumo_sakuya = {
				Chance = 12.5,
			},
            miscitem_fumo_sanae = {
				Chance = 12.5,
			},
            miscitem_fumo_shion = {
				Chance = 12.5,
			},
            miscitem_fumo_suwako = {
				Chance = 12.5,
			},
            miscitem_fumo_tsukasa = {
				Chance = 12.5,
			},
            miscitem_fumo_youmu = {
				Chance = 12.5,
			},
            miscitem_fumo_yuuka = {
				Chance = 12.5,
			},
            miscitem_fumo_yuyuko = {
				Chance = 12.5,
			},
            miscitem_noisemaker = {
                Rare = true,
				Chance = 2.5,
			},
            miscitem_cat = {
                Rare = true,
                Chance = 1,
            },
		},
	},
}

hook.Add("Think", "pluto_currency_think", function()
	for _, cur in pairs(pluto.currency.byname) do
		if (cur.Think) then
			cur:Think()
		end
	end
end)

pluto.currency.list = {}
for _, mod in ipairs(list) do
	local old = pluto.currency.byname[mod.InternalName]
	if (old) then
		mod, old = old, mod
		table.Merge(mod, old)
	end

	table.insert(pluto.currency.list, mod)
end

pluto.currency_mt = pluto.currency_mt or {}
local CUR = pluto.currency_mt.__index or {}
pluto.currency_mt.__index = CUR
function pluto.currency_mt:__tostring()
	return self:GetPrintName()
end

CUR.Type = "Currency"

function CUR:GetMaterial()
	if (not self.Material) then
		self.Material = Material(self.Icon, "noclamp")
	end

	return self.Material
end

function CUR:AllowedUse(wpn)
	if (wpn and wpn.Locked) then
		return false
	end


	local type = wpn and wpn.Type or "None"
	if (isstring(self.Types)) then
		return self.Types == type
	end

	if (istable(self.Types) and table.HasValue(self.Types, type)) then
		return true
	end

	return false
end

function CUR:Use(ply, item)
	assert(SERVER)

	if (self:Run(item)) then
		return self:Save(ply, item)
	end

	return Promise(function(res, rej) return res() end)
end

function CUR:Save(ply, item, used)
	assert(SERVER)

	ply = pluto.db.steamid64(ply)
	return Promise(function(res, rej)
		item.LastUpdate = (item.LastUpdate or 0) + 1

		pluto.db.transact(function(db)
			pluto.weapons.update(db, item)
			if (pluto.inv.addcurrency(db, ply, self.InternalName, used and -used or -1)) then
				mysql_commit(db)
				res(item)
			else
				mysql_rollback(db)
				rej()
			end
		end)
	end)
end

function CUR:GetColor()
	if (self.Think) then
		self:Think()
	end

	return self.Color
end

function CUR:GetPrintName()
	return self.Name
end

function pluto.iscurrency(t)
	return debug.getmetatable(t) == pluto.currency_mt
end

pluto.currency_mt.__colorprint = function(self)
	return {self.Color, self.Name}
end

for _, item in pairs(pluto.currency.list) do
	if (SERVER) then
		resource.AddFile("materials/" .. item.Icon)
	end
	setmetatable(item, pluto.currency_mt)
	pluto.currency.byname[item.InternalName] = item
end

if (not CLIENT) then
	return
end

local PANEL = {}
function PANEL:SetCurrency(cur)
	self.Image:SetImage(pluto.currency.byname[cur].Icon)

	self.Currency = cur

	return self
end

function PANEL:Init()
	local main = self
	self:SetTall(310)
	self:Dock(TOP)
	self.Image = self:Add "DImage"

	function self.Image:PerformLayout(w, h)
		self:SetSize(self:GetParent():GetTall() - 20, self:GetParent():GetTall() - 20)
		self:Center()
	end

	self.Image.Start = RealTime()
	self.Image.Ends = RealTime() + (3 / GetConVar("pluto_open_speed"):GetFloat())

	local s = self
	function self.Image:Think()
		local x, y = self:GetParent():GetWide() / 2 - self:GetWide() / 2, self:GetParent():GetTall() / 2 - self:GetTall() / 2

		local pct = math.min(1, (RealTime() - self.Start) / (self.Ends - self.Start))

		self:SetPos(x + (math.random() - 0.5) * 40 * pct, y + (math.random() - 0.5) * 40 * pct)

		if (pct == 1 and not self.Sent) then
			self.Sent = true
			pluto.inv.message()
				:write("currencyuse", s.Currency)
				:send()
		end
	end

	hook.Add("CrateOpenResponse", self, function(self, id)
		for _, item in pairs(pluto.buffer) do
			if (item.ID == id) then
				self.Image:Remove()

				if (item.Type == "Model") then
					self.Image = self:Add "PlutoPlayerModel"

					self.Image:SetPlutoModel(item.Model)
				elseif (item.Type == "Weapon") then
					self.Image = self:Add "pluto_item"

					self.Image:SetItem(item)

					function self:GetScissor() return false end
				end
				
				sound.PlayFile("sound/garrysmod/balloon_pop_cute.wav", "mono", function(s)
					if (IsValid(s)) then
						s:Play()
					end
				end)
				function self.Image:PerformLayout(w, h)
					self:SetSize(self:GetParent():GetTall() - 20, self:GetParent():GetTall() - 20)
					self:Center()
				end
			end
		end
	end)
end

vgui.Register("pluto_box_open", PANEL, "EditablePanel")

function pluto.inv.writerename(itemid, name)
	net.WriteUInt(itemid, 32)
	net.WriteString(name)
end

function pluto.inv.writeunname(itemid)
	net.WriteUInt(itemid, 32)
end
