--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
local crate_0 = {
	min = Color(203, 212, 36),
	max = Color(156, 39, 0)
}

local function COL(g)
	local min, max = crate_0.min, crate_0.max

	local nr, ng, nb = min.r, min.g, min.b
	local xr, xg, xb = max.r, max.g, max.b

	return Color(nr + (xr - nr) * g, ng + (xg - ng) * g, nb + (xb - nb) * g)
end

c "plague" {
	Name = "Plague Doctor",
	Model = "models/player/plague_doktor/player_plague_doktor.mdl",
	Hands = "models/player/plague_doktor/viewmodel.mdl",
	SubDescription = "I have no idea what's awaiting me, or what will happen when this all ends. For the moment I know this: there are sick people and they need curing.",
	Color = COL(0.8),
	GenerateBodygroups = function(item)
		return {
			Legs = rand(item.RowID or item.ID) % 2
		}
	end,
}

c "daedric" {
	Name = "Daedric",
	Model = "models/player/daedric.mdl",
	Hands = "models/player/daedric_hands.mdl",
	SubDescription = "I can only tell you tales of how to make Daedric armor. I have never seen it myself, nor do I know anyone that has. The stories say that it should always be worked on at night... ideally under a new or full moon, and never during an eclipse. A red harvest moon is best. Ebony is the principle material, but at the right moment a daedra heart must be thrown into the fire.",
	Color = COL(0.7),
}

c "doomguy" {
	Name = "DOOM Slayer",
	Model = "models/pechenko_121/doomslayer.mdl",
	Hands = "models/weapons/doomslayer_viewmodel.mdl",
	SubDescription = "**heavy metal music intensifies**",
	Color = rare,
}

c "sauron" {
	Name = "Sauron",
	Model = "models/auditor/lotr/sauron_alter2_pm.mdl",
	SubDescription = "Build me an army, worthy of Mordor.",
	Color = COL(0.2),
	GenerateBodygroups = function(item)
		return {
			Weapon = (rand(item.RowID or item.ID) % 2) * 4
		}
	end,
}

c "default" {
	Name = "Terrorist",
	Model = "models/player/phoenix.mdl"
}

c "wick2" {
	Name = "John Wick",
	Model = "models/wick_chapter2.mdl",
	Hands = "models/wick_chapter2/wick_chapter2_c_arms.mdl",
	SubDescription = "John wasn't exactly the boogeyman... he was the one you sent to kill the fucking boogeyman.",
	Color = COL(0.9),
}

c "lilith" {
	Name = "Lilith",
	Model = "models/kuma96/borderlands3/characters/lilith/lilith_pm.mdl",
	Hands = "models/kuma96/borderlands3/characters/lilith/c_arms_lilith.mdl",
	SubDescription = "Ever seen a siren in action? Here's your chance.",
	Color = COL(0.85),
	GenerateBodygroups = function(item)
		return {
			Belt = rand(item.RowID or item.ID) % 2
		}
	end,
	Gender = "Female",
}

c "odst" {
	Name = "ODST Armor",
	Model = "models/voxelzero/player/odst.mdl",
	SubDescription = "Drop, shock and rock.",
	Color = COL(0.4),
}

c "bigboss" {
	Name = "Big Boss",
	Model = "models/player/big_boss.mdl",
	Hands = "models/player/big_boss_hands.mdl",
	Color = COL(0.55),
	SubDescription = "Kept you waiting, huh?",
	GenerateBodygroups = function(item)
		local id = rand(item.RowID or item.ID or 0)

		local t = {}

		t.eyepatch = id % 2
		id = math.floor(id / 2)

		t.facepaint = id % 21
		id = math.floor(id / 21)

		t.camouflage = id % 8

		return t
	end
}

c "hevsuit" {
	Name = "HEV Mark V",
	Model = "models/player/sgg/hev_helmet.mdl",
	Hands = "models/player/sgg/arms/v_hev.mdl",
	Color = COL(0.2),
	SubDescription = "..."
}

c "jacket" {
	Name = "Jacket",
	Model = "models/splinks/hotline_miami/jacket/player_jacket.mdl",
	Hands = "models/splinks/hotline_miami/jacket/arms_jacket.mdl",
	Color = COL(0.38),
	SubDescription = "Please be advised, the following presentation is not intended for minors.",
	GenerateBodygroups = function(item)
		return {
			Mask = rand(item.RowID or item.ID) % 19
		}
	end,
}

//Christmas survivors

local function CHRISTMAS(g)
	return Color(0x33, 0x67, 0x39)
end

local xmas_rare = Color(255, 0, 0)

local metro_descs = {
	"Humans had always been better at killing than any other living thing.",
	"There's only one thing that can save a man from madness and that's uncertainty.",
	"The number of places in paradise is limited; only in hell is entry open to all.",
	"Never discuss the rights of the strong. You are too weak to do that.",
}
local function metro_desc(i) return metro_descs[((i + 1) % #metro_descs) + 1] end
local function metro() return Color(255,0,0) end

local generic_male = GenerateBodygroups {
	{
		"Gloves", 3
	},
	{
		"Headgear", 9
	},
	{
		"Legs", 6
	},
	{
		"Torso", 6
	},
}
local generic_female = GenerateBodygroups {
	{
		"Hands", 3
	},
	{
		"Headgear", 2
	},
	{
		"Body", 3
	},
}
local generic_female_hands = GenerateBodygroups {
	{
		"Hands", 3
	},
	{
		"Headgear", 9
	},
	{
		"Body", 3
	},
}

-- metro
c "metro_male_1" {
	Name = "Metro Male 1",
	Model = "models/half-dead/metroll/m1b1.mdl",
	Hands = "models/half-dead/metroll/c_arms_male1.mdl",
	SubDescription = metro_desc(2),
	Color = CHRISTMAS(0),
	GenerateBodygroups = generic_male,
}
c "metro_male_2" {
	Name = "Metro Male 2",
	Model = "models/half-dead/metroll/m2b1.mdl",
	Hands = "models/half-dead/metroll/c_arms_male1.mdl",
	SubDescription = metro_desc(1),
	Color = CHRISTMAS(0),
	GenerateBodygroups = generic_male,
}
c "metro_male_3" {
	Name = "Metro Male 3",
	Model = "models/half-dead/metroll/m4b1.mdl",
	Hands = "models/half-dead/metroll/c_arms_male1.mdl",
	SubDescription = metro_desc(9),
	Color = CHRISTMAS(0),
	GenerateBodygroups = generic_male,
}
c "metro_male_4" {
	Name = "Metro Male 4",
	Model = "models/half-dead/metroll/m5b1.mdl",
	Hands = "models/half-dead/metroll/c_arms_male1.mdl",
	SubDescription = metro_desc(8),
	Color = CHRISTMAS(0),
	GenerateBodygroups = generic_male,
}
c "metro_male_5" {
	Name = "Metro Male 5",
	Model = "models/half-dead/metroll/m6b1.mdl",
	Hands = "models/half-dead/metroll/c_arms_male1.mdl",
	SubDescription = metro_desc(6),
	Color = CHRISTMAS(0),
	GenerateBodygroups = generic_male,
}
c "metro_male_6" {
	Name = "Metro Male 6",
	Model = "models/half-dead/metroll/m7b1.mdl",
	Hands = "models/half-dead/metroll/c_arms_male1.mdl",
	SubDescription = metro_desc(5),
	Color = CHRISTMAS(0),
	GenerateBodygroups = generic_male,
}
c "metro_male_7" {
	Name = "Metro Male 7",
	Model = "models/half-dead/metroll/m8b1.mdl",
	Hands = "models/half-dead/metroll/c_arms_male1.mdl",
	SubDescription = metro_desc(15),
	Color = CHRISTMAS(0),
	GenerateBodygroups = generic_male,
}
c "metro_male_8" {
	Name = "Metro Male 8",
	Model = "models/half-dead/metroll/m9b1.mdl",
	Hands = "models/half-dead/metroll/c_arms_male1.mdl",
	SubDescription = metro_desc(14),
	Color = CHRISTMAS(0),
	GenerateBodygroups = generic_male,
}
c "metro_male_9" {
	Name = "Metro Male 9",
	Model = "models/half-dead/metroll/m1b1.mdl",
	Hands = "models/half-dead/metroll/c_arms_male1.mdl",
	SubDescription = metro_desc(12),
	Color = CHRISTMAS(0),
	GenerateBodygroups = generic_male,
}
c "metro1" {
	Name = "Metro Extra 1",
	Model = "models/half-dead/metroll/a1b1.mdl",
	Hands = "models/half-dead/metroll/c_arms_male1.mdl",
	SubDescription = metro_desc(3),
	Color = CHRISTMAS(0),
	GenerateBodygroups = generic_male,
}
c "metro2" {
	Name = "Metro Extra 2",
	Model = "models/half-dead/metroll/a2b1.mdl",
	Hands = "models/half-dead/metroll/c_arms_male1.mdl",
	SubDescription = metro_desc(18),
	Color = CHRISTMAS(0),
	GenerateBodygroups = generic_male,
}
c "metro3" {
	Name = "Metro Extra 3",
	Model = "models/half-dead/metroll/a3b1.mdl",
	Hands = "models/half-dead/metroll/c_arms_male1.mdl",
	SubDescription = metro_desc(11),
	Color = CHRISTMAS(0),
	GenerateBodygroups = generic_male,
}
c "metro4" {
	Name = "Metro Extra 4",
	Model = "models/half-dead/metroll/a4b1.mdl",
	Hands = "models/half-dead/metroll/c_arms_male1.mdl",
	SubDescription = metro_desc(17),
	Color = CHRISTMAS(0),
	GenerateBodygroups = generic_male,
}
c "metro5" {
	Name = "Metro Extra 5",
	Model = "models/half-dead/metroll/a5b1.mdl",
	Hands = "models/half-dead/metroll/c_arms_male1.mdl",
	SubDescription = metro_desc(19),
	Color = CHRISTMAS(0),
	GenerateBodygroups = generic_male,
}
c "metro6" {
	Name = "Metro Extra 6",
	Model = "models/half-dead/metroll/a6b1.mdl",
	Hands = "models/half-dead/metroll/c_arms_male1.mdl",
	SubDescription = metro_desc(4),
	Color = CHRISTMAS(0),
	GenerateBodygroups = generic_male,
}
c "metro_female_1" {
	Name = "Metro Female 1",
	Model = "models/half-dead/metroll/f1b1.mdl",
	Hands = "models/half-dead/metroll/c_arms_male1.mdl",
	SubDescription = metro_desc(20),
	Color = CHRISTMAS(0),
	GenerateBodygroups = generic_female,
	Gender = "Female",
}
c "metro_female_2" {
	Name = "Metro Female 2",
	Model = "models/half-dead/metroll/f2b1.mdl",
	Hands = "models/half-dead/metroll/c_arms_male1.mdl",
	SubDescription = metro_desc(13),
	Color = CHRISTMAS(0),
	GenerateBodygroups = generic_female_hands,
	Gender = "Female",
}
c "metro_female_3" {
	Name = "Metro Female 3",
	Model = "models/half-dead/metroll/f3b1.mdl",
	Hands = "models/half-dead/metroll/c_arms_male1.mdl",
	SubDescription = metro_desc(16),
	Color = CHRISTMAS(0),
	GenerateBodygroups = generic_female,
	Gender = "Female",
}
c "metro_female_4" {
	Name = "Metro Female 4",
	Model = "models/half-dead/metroll/f4b1.mdl",
	Hands = "models/half-dead/metroll/c_arms_male1.mdl",
	SubDescription = metro_desc(10),
	Color = CHRISTMAS(0),
	GenerateBodygroups = generic_male,
	Gender = "Female",
}
c "metro_female_5" {
	Name = "Metro Female 5",
	Model = "models/half-dead/metroll/f6b1.mdl",
	Hands = "models/half-dead/metroll/c_arms_male1.mdl",
	SubDescription = metro_desc(21),
	Color = CHRISTMAS(0),
	GenerateBodygroups = generic_female,
	Gender = "Female",
}
c "metro_female_6" {
	Name = "Metro Female 6",
	Model = "models/half-dead/metroll/f7b1.mdl",
	Hands = "models/half-dead/metroll/c_arms_male1.mdl",
	SubDescription = metro_desc(7),
	Color = CHRISTMAS(0),
	GenerateBodygroups = generic_female,
	Gender = "Female",
}



c "osrsbob" {
	Name = "Bob",
	Model = "models/player/runescape/player_bob.mdl",
	--Hands = "models/player/runescape/player_bob.mdl",
	Color = CHRISTMAS(0.5),
	SubDescription = "Frogslaughter at best.",
}

//Christmas2

c "ghilliewinter01" {
	Name = "Ghillie Winter",
	Model = "models/player/joheskiller/ghilliesuit_winter.mdl",
	Hands = "models/weapons/c_arms_cstrike.mdl",
	Color = ColorRand(),
	SubDescription = "Stay low and move slowly, we'll be impossible to spot in our ghillie suits."
}

c "snow1" {
	Name = "Snow Citizen",
	Model = "models/player/portal/Male_02_Snow.mdl",
	Hands = nil,
	Color = ColorRand(),
	SubDescription = "",
	GenerateBodygroups = function(item)
		local bg = BodyGroupRand({
			hats = {
				0, 1, 2, 3, 4
			},
			body = {
				0, 1, 2
			},
		}, item.RowID or item.ID)
		
		return bg
	end,
}
c "snow2" {
	Name = "Snow Citizen",
	Model = "models/player/portal/Male_04_Snow.mdl",
	Hands = nil,
	Color = ColorRand(),
	SubDescription = "",
	GenerateBodygroups = function(item)
		local bg = BodyGroupRand({
			hats = {
				0, 1, 2, 3, 4
			},
			body = {
				0, 1, 2
			},
		}, item.RowID or item.ID)
		
		return bg
	end,
}
c "snow3" {
	Name = "Snow Citizen",
	Model = "models/player/portal/Male_05_Snow.mdl",
	Hands = nil,
	Color = ColorRand(),
	SubDescription = "",
	GenerateBodygroups = function(item)
		local bg = BodyGroupRand({
			hats = {
				0, 1, 2, 3, 4
			},
			body = {
				0, 1, 2
			},
		}, item.RowID or item.ID)
		
		return bg
	end,
}
c "snow4" {
	Name = "Snow Citizen",
	Model = "models/player/portal/Male_06_Snow.mdl",
	Hands = nil,
	Color = ColorRand(),
	SubDescription = "",
	GenerateBodygroups = function(item)
		local bg = BodyGroupRand({
			hats = {
				0, 1, 2, 3, 4
			},
			body = {
				0, 1, 2
			},
		}, item.RowID or item.ID)
		
		return bg
	end,
}
c "snow5" {
	Name = "Snow Citizen",
	Model = "models/player/portal/Male_07_Snow.mdl",
	Hands = nil,
	Color = ColorRand(),
	SubDescription = "",
	GenerateBodygroups = function(item)
		local bg = BodyGroupRand({
			hats = {
				0, 1, 2, 3, 4
			},
			body = {
				0, 1, 2
			},
		}, item.RowID or item.ID)
		
		return bg
	end,
}
c "snow6" {
	Name = "Snow Citizen",
	Model = "models/player/portal/Male_08_Snow.mdl",
	Hands = nil,
	Color = ColorRand(),
	SubDescription = "",
	GenerateBodygroups = function(item)
		local bg = BodyGroupRand({
			hats = {
				0, 1, 2, 3, 4
			},
			body = {
				0, 1, 2
			},
		}, item.RowID or item.ID)
		
		return bg
	end,
}
c "snow7" {
	Name = "Snow Citizen",
	Model = "models/player/portal/Male_09_Snow.mdl",
	Hands = nil,
	Color = ColorRand(),
	SubDescription = "",
	GenerateBodygroups = function(item)
		local bg = BodyGroupRand({
			hats = {
				0, 1, 2, 3, 4
			},
			body = {
				0, 1, 2
			},
		}, item.RowID or item.ID)
		
		return bg
	end,
}

//easter

c "wild_rabbit" {
	Name = "Wild Rabbit",
	Model = "models/pipann/wild_rabbit.mdl",
	Color = ColorRand(),
	SubDescription = "",
	Fake = true,
}

c "dom_rabbit" {
	Name = "Wild Rabbit",
	Model = "models/pipann/domestic_rabbit.mdl",
	Color = ColorRand(),
	SubDescription = "",
	Fake = true,
}

c "chimp" {
	Name = "Chimp",
	Model = "models/player/chimp/chimp.mdl",
	Color = ColorRand(),
	SubDescription = "MONKE",
	Fake = true,
}

c "clank" {
	Name = "Clank",
	Model = "models/rc/clank_pm.mdl",
	Color = ColorRand(),
	SubDescription = "Where's Ratchet?",
	Fake = true,
}

c "hank" {
	Name = "Hank",
	Model = "models/hellinspector/koth/hank_pm.mdl",
	Color = ColorRand(),
	SubDescription = "",
	Fake = true,
}

c "male_child" {
	Name = "Male Child",
	Model = "models/player/child_worker_m1.mdl",
	Color = ColorRand(),
	SubDescription = "",
	Fake = true,
}

c "female_child" {
	Name = "Female Child",
	Model = "models/player/child_worker_f1.mdl",
	Color = ColorRand(),
	SubDescription = "",
	Gender = "Female",
	Fake = true,
}

//Halloween


c "husk" {
	Name = "Husk",
	Model = "models/player/husk/slow.mdl",
	Hands = nil,
	Color = ColorRand(),
	SubDescription = "You exist because we allow it."
}

c "hunk" {
	Name = "Hunk",
	Model = "models/player/lordvipes/rerc_hunk/hunk_cvp.mdl",
	Hands = "models/player/lordvipes/rerc_hunk/arms/hunkarms_cvp.mdl",
	Hands = nil,
	Color = ColorRand(),
	SubDescription = "Hunk."
}

//Orange Egg Survivors

local crate_2 = {
	min = Color(38, 13, 224),
	max = Color(199, 30, 55)
}

local function CRATE2_COL(frac)
	local min, max = crate_2.min, crate_2.max

	local nr, ng, nb = min.r, min.g, min.b
	local xr, xg, xb = max.r, max.g, max.b

	return Color(nr + (xr - nr) * frac, ng + (xg - ng) * frac, nb + (xb - nb) * frac)
end

c "violet_spart" {
	Name = "Violet Spartan",
	Model = "models/halo2/spartan_violet.mdl",
	Hands = "models/weapons/c_arms_masterchief_h2.mdl",
	Color = CRATE2_COL(0.1),
	SubDescription = "Stand out in the haze of combat."
}

c "gold_spart" {
	Name = "Gold Spartan",
	Model = "models/halo2/spartan_gold.mdl",
	Hands = "models/weapons/c_arms_masterchief_h2.mdl",
	Color = CRATE2_COL(0.1),
	SubDescription = "Deep pockets and thick armor."
}

c "pink_spart" {
	Name = "Pink Spartan",
	Model = "models/halo2/spartan_pink.mdl",
	Hands = "models/weapons/c_arms_masterchief_h2.mdl",
	Color = CRATE2_COL(0.1),
	SubDescription = "Tough guys wear pink."
}

c "green_spart" {
	Name = "Green Spartan",
	Model = "models/halo2/spartan_green.mdl",
	Hands = "models/weapons/c_arms_masterchief_h2.mdl",
	Color = CRATE2_COL(0.1),
	SubDescription = "Not quite, Chief."
}

c "orange_spart" {
	Name = "Orange Spartan",
	Model = "models/halo2/spartan_orange.mdl",
	Hands = "models/weapons/c_arms_masterchief_h2.mdl",
	Color = CRATE2_COL(0.1),
	SubDescription = "Are you sure it isn't tangerine?"
}

c "steel_spart" {
	Name = "Steel Spartan",
	Model = "models/halo2/spartan_steel.mdl",
	Hands = "models/weapons/c_arms_masterchief_h2.mdl",
	Color = CRATE2_COL(0.1),
	SubDescription = "Who needs armor paint?"
}

c "tan_spart" {
	Name = "Tan Spartan",
	Model = "models/halo2/spartan_tan.mdl",
	Hands = "models/weapons/c_arms_masterchief_h2.mdl",
	Color = CRATE2_COL(0.1),
	SubDescription = "Coarse and gets everywhere."
}

c "blue_spart" {
	Name = "Blue Spartan",
	Model = "models/halo2/spartan_blue.mdl",
	Hands = "models/weapons/c_arms_masterchief_h2.mdl",
	Color = CRATE2_COL(0.1),
	SubDescription = "I hate babies!"
}

c "master_chief" {
	Name = "Master Chief",
	Model = "models/halo2/spartan_mc.mdl",
	Hands = "models/weapons/c_arms_masterchief_h2.mdl",
	Color = CRATE2_COL(0.1),
	SubDescription = "I need a weapon."
}

c "sage_spart" {
	Name = "Sage Spartan",
	Model = "models/halo2/spartan_sage.mdl",
	Hands = "models/weapons/c_arms_masterchief_h2.mdl",
	Color = CRATE2_COL(0.1),
	SubDescription = "It takes a wise man to discover a wise man / The fool wonders, the wise man asks."
}

c "crimson_spart" {
	Name = "Crimson Spartan",
	Model = "models/halo2/spartan_crimson.mdl",
	Hands = "models/weapons/c_arms_masterchief_h2.mdl",
	Color = CRATE2_COL(0.1),
	SubDescription = "Crimson, just like your blood."
}

c "cobalt_spart" {
	Name = "Cobalt Spartan",
	Model = "models/halo2/spartan_cobalt.mdl",
	Hands = "models/weapons/c_arms_masterchief_h2.mdl",
	Color = CRATE2_COL(0.1),
	SubDescription = "Decent Powertools."
}

c "cyan_spart" {
	Name = "Cyan Spartan",
	Model = "models/halo2/spartan_cyan.mdl",
	Hands = "models/weapons/c_arms_masterchief_h2.mdl",
	Color = CRATE2_COL(0.1),
	SubDescription = "The bright color will confuse the enemy."
}

c "olive_spart" {
	Name = "Olive Spartan",
	Model = "models/halo2/spartan_olive.mdl",
	Hands = "models/weapons/c_arms_masterchief_h2.mdl",
	Color = CRATE2_COL(0.1),
	SubDescription = "Unlimited Breadsticks, or Bombshells?"
}

c "purple_spart" {
	Name = "Purple Spartan",
	Model = "models/halo2/spartan_purple.mdl",
	Hands = "models/weapons/c_arms_masterchief_h2.mdl",
	Color = CRATE2_COL(0.1),
	SubDescription = "It's not violet!"
}

c "red_spart" {
	Name = "Red Spartan",
	Model = "models/halo2/spartan_red.mdl",
	Hands = "models/weapons/c_arms_masterchief_h2.mdl",
	Color = CRATE2_COL(0.1),
	SubDescription = "Ah, damn it, I messed up my one-liner."
}

c "teal_spart" {
	Name = "Teal Spartan",
	Model = "models/halo2/spartan_teal.mdl",
	Hands = "models/weapons/c_arms_masterchief_h2.mdl",
	Color = CRATE2_COL(0.1),
	SubDescription = "It's not cyan."
}

c "white_spart" {
	Name = "White Spartan",
	Model = "models/halo2/spartan_white.mdl",
	Hands = "models/weapons/c_arms_masterchief_h2.mdl",
	Color = CRATE2_COL(0.1),
	SubDescription = "Cold weather never scared me."
}

c "brown_spart" {
	Name = "Brown Spartan",
	Model = "models/halo2/spartan_brown.mdl",
	Hands = "models/weapons/c_arms_masterchief_h2.mdl",
	Color = CRATE2_COL(0.1),
	SubDescription = "Good to wear for jumpscares."
}

c "captain" {
	Name = "Captain",
	Model = "models/player/red/captain.mdl",
	Color = CRATE2_COL(0.32),
	SubDescription = "The war left its scars on all of us."
}

c "sergeant" {
	Name = "Sergeant",
	Model = "models/player/green/sergeant.mdl",
	Color = CRATE2_COL(0.3),
	SubDescription = "Look around. We’re one and the same. Same heart, same blood. "
}

c "general" {
	Name = "General",
	Model = "models/player/black/general.mdl",
	Color = CRATE2_COL(0.29),
	SubDescription = "We’re just clones, sir. We’re meant to be expendable. "
}

c "commander" {
	Name = "Commander",
	Model = "models/player/yellow/commander.mdl",
	Color = CRATE2_COL(0.27),
	SubDescription = "You have to learn to make your own decisions."
}

c "clone" {
	Name = "Clone",
	Model = "models/player/swrcc/new clone.mdl",
	Color = CRATE2_COL(0.25),
	SubDescription = "Just like the simulations. "
}

c "lieutenant" {
	Name = "Lieutenant",
	Model = "models/player/blue/lieutenant.mdl",
	Color = CRATE2_COL(0.23),
	SubDescription = "Today we fight for more than the Republic. Today we fight for all our brothers back home."
}

c "bomb_squad" {
	Name = "Bomb Squad",
	Model = "models/player/orange/bomb squad.mdl",
	Color = CRATE2_COL(0.2),
	SubDescription = "Well looks like the bomb room."
}

c "spacesuit" {
	Name = "Spacesuit",
	Model = "models/player/pluto_spacesuit.mdl",
	Color = CRATE2_COL(1),
	SubDescription = "My god, it's full of stars..."
}

c "zer0" {
	Name = "Zer0",
	Model = "models/kuma96/borderlands3/characters/zero/zero_resized_pm.mdl",
	Hands = "models/kuma96/borderlands3/characters/zero/c_arms_zero.mdl",
	Color = CRATE2_COL(1),
	SubDescription = "Your eyes deceive you / An illusion fools you all / I move for the kill."
}

c "tachanka" {
	Name = "Tachanka",
	Model = "models/auditor/r6s/spetsnaz/tachanka/chr_spetsnaz_turret3.mdl",
	Hands = "models/auditor/r6s/spetsnaz/tachanka/chr_spetsnaz_turret3_arms.mdl",
	Color = CRATE2_COL(0.85),
	SubDescription = "Who?"
}

c "raincoat" {
	Name = "Raincoat",
	Model = "models/human/raincoat.mdl",
	--Hands = "models/human/c_hands.mdl", Hand don't work on this model
 	Color = CRATE2_COL(0.8),
	SubDescription = "The most dangerous enemy in the Otherworld."
}

c "psycho" {
	Name = "Psycho",
	Model = "models/kuma96/borderlands3/characters/psychomale/psychomale_pm.mdl",
	Hands = "models/kuma96/borderlands3/characters/psychomale/c_arms_psychomale.mdl",
	Color = CRATE2_COL(0.77),
	SubDescription = "YOU'RE GOING TO BE MY NEW MEAT BICYCLE!!"
}

c "tron_anon" {
	Name = "Tron Anon",
	Model = "models/player/anon/anon.mdl",
	Hands = "models/weapons/arms/anon_arms.mdl",
	Color = CRATE2_COL(0.26),
	SubDescription = "Where's my bike?"
}

//Random


c "spy" {
	Name = "Spy",
	Model = "models/player/spyplayer/spy.mdl",
	Hands = "models/player/spyplayer/spy_hands.mdl",
	Color = Color(219, 11, 181),
	SubDescription = "Well, off to visit your mother!"
}

-- needs hitbox fixer
c "ror2_commando" {
	Name = "Risk Of Rain 2 - Commando",
	Model = "models/player/RiskOfRain2/Survivors/Commando/Commando_pm.mdl",
	Hands = "models/player/RiskOfRain2/Survivors/Commando/Commando_hands.mdl",
	Color = ColorRand(),
	SubDescription = "... and his music was electric."
}