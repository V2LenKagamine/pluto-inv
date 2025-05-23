--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
local pluto_weapon_droprate = CreateConVar("pluto_weapon_droprate", "0.5", nil, nil, 0, 1)
local pluto_equip_droprate = CreateConVar("pluto_equipcrate_droprate", "0.01", nil, nil, 0, 1)
local pluto_toys_droprate = CreateConVar("pluto_toycrate_droprate","0.0025",nil, nil, 0, 1)

pluto.afk = pluto.afk or {}

hook.Add("PlayerInitialSpawn", "pluto_afk", function(ply)
	pluto.afk[ply] = {}
end)

hook.Add("TTTBeginRound", "pluto_afk", function()
	for _, ply in pairs(round.GetStartingPlayers()) do
		pluto.afk[ply.Player] = {}
	end
end)

hook.Add("PlayerButtonDown", "pluto_afk", function(ply, btn)
	pluto.afk[ply][btn] = true
end)

local function name(x)
	if (not IsValid(x)) then
		return "INVALID ENTITY"
	elseif (x:IsPlayer()) then
		return x:Nick()
	elseif (IsValid(x)) then
		return x.GetPrintName and x:GetPrintName() or x.PrintName or x:GetClass()
	end
	return "idk"
end

local types = {
	"were crushed into paste",
	"were shot to swiss cheese",
	"were cleaved in-twain",
	"were cooked to well-done",
	"were made roadkill",
	"fell a little too far",
	"were sent home in a soup can",
	"took too many blows to the head",
	"cut a live wire",
	"were electrocuted to death",
	"were sliced in half by lasers",
	nil, --prevent-physics force
	nil, --nevergib
	nil, --alwaysgib
	"ran out of air",
	"were turned to stone",
	"had your neurons stop firing",
	"were turned a sickly-poison-green",
	"made the geiger counter break",
	nil, --Drown-recover
	"were melted",
	"were thoroughly cooked",
	nil, --No ragdoll
	"were blasted by gravity",
	"were turned into green goo",
	"had a large hole put through you",
	"were disassembled on an atomic level",
	"were blasted into oblivion",
	nil, -- direct damage, dont use.
	"were filled with buckshot",
	"were taken out from the next zip code",
	"were utterly obliterated by missles",
}

local function damagedesc(n)
	for i = 1, 31 do
		if (bit.band(n, 2 ^ (i - 1)) ~= 0 and types[i]) then
			return "You " .. types[i]
		end
	end

	return "You had your lifeforce taken forcibly"
end

hook.Add("DoPlayerDeath", "pluto_info", function(vic, atk, dmg)
	local wep = dmg:GetInflictor()
	local atk = dmg:GetAttacker()

	local text = {white_text, damagedesc(dmg:GetDamageType())}

	if (IsValid(atk)) then
		if (atk == vic) then
			text = {white_text, "You have ", atk:GetRoleData().Color, "suicided", white_text, "."}
		elseif (atk:IsPlayer()) then
			local next_text = {
				" by ", atk:GetRoleData().Color, atk:Nick(), white_text, " who was a", (atk:GetRole():match "^[aeiouAEIOU]" and "n" or ""), " ", atk:GetRoleData().Color, atk:GetRole(), white_text, "."
			}

			for i, v in ipairs(next_text) do
				text[#text + 1] = v
			end

			if (IsValid(wep) and wep:IsWeapon()) then
				if (wep.PlutoGun) then
					for i, v in ipairs {" They used their ", wep.PlutoGun} do
						text[#text + 1] = v
					end
				else
					for i, v in ipairs {" They used their ", name(wep)} do
						text[#text + 1] = v
					end
				end
			end
		elseif (game.GetWorld() == atk) then
			text[#text + 1] = " by the world"
		elseif (atk:IsWeapon()) then
			text[#text + 1] = " by " .. atk:GetPrintName()
		elseif (atk.PrintName) then
			text[#text + 1] = " by " .. atk.PrintName
		else
			text[#text + 1] = " by " .. atk:GetClass()
		end
	end

	local filtered = {}
	for _, v in ipairs(text) do
		if (isstring(v)) then
			filtered[#filtered + 1] = v
		end
	end

	print(table.concat(filtered))
	vic:ChatPrint(color_black, "- ", unpack(text))
end)

hook.Add("TTTEndRound", "pluto_endround", function()
	timer.Remove "pluto_afkcheck"

	for _, obj in pairs(round.GetStartingPlayers()) do
		local ply = obj.Player
		if (not IsValid(ply)) then
			continue
		end

		if (table.Count(pluto.afk[ply]) <= 5) then
			ply.WasAFK = true
			pluto.warn("INV", ply, " was afk this round.")
			continue
		end
		ply.WasAFK = false
        
		if (not IsValid(ply)) then
			continue
		end
        pluto.inv.endrounddrops(ply)
	end
end)

function pluto.inv.endrounddrops(ply)
    local dropnum = math.random()
    if(dropnum < pluto_weapon_droprate:GetFloat()) then
		pluto.db.instance(function(db)
			pluto.inv.addcurrency(db, ply, "endround", 1)
			ply:ChatPrint(white_text, "You obtained ", pluto.currency.byname.endround, " × 1.")
		end)
    end
    dropnum = math.random()
    if(dropnum < pluto_equip_droprate:GetFloat()) then
        pluto.db.instance(function(db)
			pluto.inv.addcurrency(db, ply, "crate_nade1", 1)
			ply:ChatPrint(white_text, "You obtained ", pluto.currency.byname.crate_nade1, " × 1.")
		end)
    end
    dropnum = math.random()
    if(dropnum < pluto_equip_droprate:GetFloat()) then
        pluto.db.instance(function(db)
			pluto.inv.addcurrency(db, ply, "crate_cons1", 1)
			ply:ChatPrint(white_text, "You obtained ", pluto.currency.byname.crate_cons1, " × 1.")
		end)
    end
    dropnum = math.random()
    if(dropnum < pluto_toys_droprate:GetFloat()) then
        pluto.db.instance(function(db)
			pluto.inv.addcurrency(db, ply, "crate_toy1", 1)
			ply:ChatPrint(white_text, "You obtained ", pluto.currency.byname.crate_toy1, " × 1.")
		end)
    end
end


local pluto_loaded = {}
--[[ --Todo: Make this work, need to pass plr in somehow from loadout.lua
hook.Add("PlutoLoadoutChanged", "pluto_reequip",function(slot,_,plr)
    local event = pluto.rounds.getcurrent()
    if(event) then return end
    if(ttt.GetRoundState() == ttt.ROUNDSTATE_ACTIVE or ttt.GetRoundState() == ttt.ROUNDSTATE_ENDED) then return end
	local wepid = tonumber(ply:GetInfo("pluto_loadout_slot" .. slot, nil))
	local wep = pluto.itemids[wepid]
	if (wep and wep.Owner == ply:SteamID64()) then
        for wpnslot,has in ipairs(plr:GetWeapons()) do
            print(wpnslot)
            if(wpnslot == wep:GetSlot()) then
                plr:StripWeapon(has:GetClass())
                break
            end
        end
		pluto.NextWeaponSpawn = wep
		ply:Give(wep.ClassName)
	end
    return true
end)
]]

hook.Add("TTTPlayerGiveWeapons", "pluto_loadout", function(ply)
	local event = pluto.rounds.getcurrent()
	
	if (event) then
		if (event.Loadout) then
			event:Loadout(ply)
		end

		return true
	end

	for i = 1, 6 do
		local wepid = tonumber(ply:GetInfo("pluto_loadout_slot" .. i, nil))
		local wep = pluto.itemids[wepid]
		if (wep and wep.Owner == ply:SteamID64()) then
			pluto.NextWeaponSpawn = wep
			ply:Give(wep.ClassName)
		end
	end

	pluto_loaded[ply:SteamID64()] = true
	return true
end)

hook.Add("TTTRoundStart", "pluto_loadout_fallback", function(plys)
	for _, ply in ipairs(plys) do
		if (not ply:Alive()) then
			continue
		end

		hook.Run("PlayerSetModel", ply)

		if (not pluto_loaded[ply:SteamID64()]) then
			ply:StripWeapons()
			ply:StripAmmo()
			hook.Run("PlayerLoadout", ply)
		end
	end
end)