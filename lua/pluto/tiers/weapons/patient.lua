--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
return {
	Name = "Patient",
	affixes = 5,
    guaranteed = {
		leech = 1,
	},
	tags = {
		healing = 0,
        util = 0,
	},
	SubDescription = {
        guaranteed = "This weapon always rolls Leech I.",
		tags = "This weapon can only roll damaging suffixes.",
        why = "Go on, I'll wait.",
	},
	Color = Color(0, 101, 160),
}