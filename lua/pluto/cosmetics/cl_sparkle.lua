--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
local function init()
	CreateMaterial("pluto_glow", "SpriteCard", {
		["$basetexture"] = "sprites/animglow02",
		["$additive"] = "1",
		["$vertexcolor"] = "1",
		["$vertexalpha"] = "1",
	})

	CreateMaterial("pluto_heart", "SpriteCard", {
		["$additive"] = "1",
		["$vertexcolor"] = "1",
		["$vertexalpha"] = "1",
	}):SetTexture("$basetexture", Material "pluto/currencies/heart.png":GetTexture "$basetexture")

	hook.Remove("HUDPaint", "pluto_sparkles")
end

hook.Add("HUDPaint", "pluto_sparkles", init)

game.AddParticles "particles/pluto_sparklies.pcf"
game.AddParticles "particles/pluto_heart.pcf"

pluto.sparklelist = pluto.sparklelist or setmetatable({}, {__mode = "k"})
pluto.sparklemap = pluto.sparklemap or setmetatable({}, {__mode = "k"})

function pluto.sparkle(what, particle, turnon)--[[
	pluto.sparklelist[what] = turnon or nil
	local system = pluto.sparklemap[what]
	if (IsValid(system) and not turnon) then
		system:StopEmissionAndDestroyImmediately()
	elseif (not IsValid(system) and turnon and IsValid(what)) then
		pluto.sparklemap[what] = CreateParticleSystem(what, particle, PATTACH_ABSORIGIN_FOLLOW, 0)
	end]]
end

timer.Create("pluto_sparkle_update", 0.5, 0, function()
	for what in pairs(pluto.sparklelist) do
		if (not IsValid(what)) then
			continue
		end

		local system = pluto.sparklemap[what]
		local shoulddraw = not what:GetNoDraw() and not what:IsPlayer() or not (what:IsDormant() or not what:Alive() or what == LocalPlayer() and not what:ShouldDrawLocalPlayer())

		if (shoulddraw and not IsValid(system)) then
			pluto.sparkle(what, true)
			system = pluto.sparklemap[what]
		end
		
		if (not IsValid(system)) then
			continue
		end

		system:SetShouldDraw(shoulddraw)
	end
end)