--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
local GROUP = pluto.nodes.groups.get("magazine", 2)

GROUP.Type = "primary"

GROUP.Guaranteed = {
    "magtradereload",
}

GROUP.SmallNodes = {
	mag = {
        Shares = 2,
        Max = 2,
    },
	recoil = 1,
	reloading = 1,
}