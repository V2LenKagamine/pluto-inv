--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
local NODE = pluto.nodes.get "electrum_enchant"

NODE.Name = "Enchanted: Electrum"
NODE.Description = "Your weapon is fused from Gold and Silver."
NODE.Experience = 3500

function NODE:ModifyWeapon(node, wep)
	wep.ElectrumEnchant = true
end