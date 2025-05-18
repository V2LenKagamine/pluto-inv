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
    otherworldly = 0.25,
    confused = 0.3,
    shadowy = 0.5,
    patient = 0.5,
    mystical = 0.5,
    uncommon = 7.5,
    stable = 7.5,
	common = 7.5,
    powerful = 10,
	vintage = 40,
	junk = 100,
	
    unstable = 100,
    stabilized = 20,
    explosive = 10,

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