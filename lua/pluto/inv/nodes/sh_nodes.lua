--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
pluto_disable_constellations = CreateConVar("pluto_disable_constellations", "0", { FCVAR_REPLICATED })

pluto.nodes = pluto.nodes or {
	byname = {},
	mt = {
		__index = {}
	}
}


function pluto.nodes.get(name)
	local node = pluto.nodes.byname[name]
	if (not node) then
		node = setmetatable({}, pluto.nodes.mt)
		pluto.nodes.byname[name] = node
	end

	return node
end

for _, fname in pairs {
	"stats/damage",
	"stats/distance",
	"stats/firerate",
	"stats/mag",
	"stats/recoil",
	"stats/reloading",

    "stats/damagetradefr",
	"stats/distancetraderc",
	"stats/fireratetradedmg",
	"stats/magtradereload",
	"stats/recoiltradedis",
	"stats/reloadingtrademag",

	"enigmatic/voice",
	"enigmatic/warn",
	"enigmatic/siren",
	"enigmatic/ground",

	"demon/possess",
	"demon/speed",
	"demon/heal",
	"demon/damage",

	"mortal/wound",
	"mortal/wound_s",

	"gold/enchanted",
	"gold/spawns",
	"gold/transform",

	"piercer/mini",
	"piercer/pierce",

	"silver/enchanted",
	"silver/spawns",
	"silver/share",
	"silver/transform",

    "starstruck/enchanted",
    "starstruck/spawns",
    "starstruck/starfall",

    "electrum/enchanted",
	"electrum/spawns",
	"electrum/share",

	"reserves/mythic",

    "unrelenting/unrelenting",

	"pusher/push",
} do
    if (SERVER) then
        AddCSLuaFile(realfile("pluto/inv/nodes/list/" .. fname .. ".lua"))
    end
    include(realfile("pluto/inv/nodes/list/" .. fname .. ".lua"))
end

local NODE = pluto.nodes.mt.__index

function NODE:GetName(node)
	return self.Name or node.node_name or "Unknown"
end

function NODE:GetDescription(node)
	local values = {
		node.node_val1,
		node.node_val2,
		node.node_val3,
	}
	return self.Description or "Unknown [" .. table.concat(values, ", ") .. "]"
end

function NODE:ModifyWeapon(node, wep)
	ErrorNoHaltWithStack("unimplemented ModifyWeapon: " .. self:GetName(node))
end

function NODE:GetExperienceCost(node)
	return 10000
end

