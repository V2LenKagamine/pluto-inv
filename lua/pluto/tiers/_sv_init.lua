--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
local share_count = {
	common = 50000, --.05
	confused = 1000, -- .001
	junk = 600000, -- .6
	otherworldly = 500, -- .0005
	shadowy = 750, -- 0.00075
	uncommon = 10000, -- 0.01
	vintage = 300000, -- .3
	powerful = 10000, -- .01
	stable = 7000, -- .007
	mystical = 800, -- .0008
    patient = 200, -- 0.0002

    unstable = 100,
    stabilized = 100,
    explosive = 100,

    generic = 100,

    regular = 100,
}
--Guns 980250w
--Grenades 300w
--Consumables 100w
--Miscs 100w

local perCount = {
    otherworldly = 0.75,
    confused = 1,
    shadowy = 2,
    patient = 2,
    mystical = 2,
    uncommon = 25,
    stable = 25,
	common = 25,
    powerful = 30,
	vintage = 70,
	junk = 100,
	
    unstable = 50,
    stabilized = 30,
    explosive = 20,

    generic = 100,

    regular = 100,
}

for _, typelist in pairs(pluto.tiers.bytype) do
	typelist.shares = 0
end

for name, tier in pairs(pluto.tiers.byname) do
	tier.Shares = share_count[name] or 0
    tier.Percentile = perCount[name] or 0

	local typelist = pluto.tiers.bytype[tier.Type or "Weapon"]

	typelist.shares = typelist.shares + tier.Shares
end