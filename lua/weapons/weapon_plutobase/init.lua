--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
include "shared.lua"
AddCSLuaFile "shared.lua"

util.AddNetworkString "pluto_wpn_db"
DEFINE_BASECLASS "weapon_tttbase_old"

local function _hook(name, self, fn)
	hook.Add(name, self, function(...)
		self[fn or name](...)
	end)
end

function SWEP:GetPlutoPrintName()
	local p = self.PlutoGun
	if (p) then
		return p:GetPrintName()
	end
end

function SWEP:Initialize()
	BaseClass.Initialize(self)

	self:PlutoInitialize()

	local item = pluto.NextWeaponSpawn
	pluto.NextWeaponSpawn = nil

	if (item == false) then
		return
	end


	if (not item and pluto.tiers.bytype[pluto.weapons.type(self)]) then
		local tier = pluto.tiers.filter(self, function(t)
			if (t.affixes < 4) then
				return false
			end

			return true
		end)
		item = pluto.weapons.generatetier(tier, self)
		item.Type = "Weapon"
		self.FloorWeapon = true
	end
	if (item) then
		self:SetInventoryItem(item)
	end
	self.PlutoData = self.PlutoData or {}

	_hook("PlayerInitialSpawn", self, "SendData")
	_hook("DoPlayerDeath", self, "PlutoDoPlayerDeath")
end

function SWEP:PlutoDoPlayerDeath(ply, atk, dmg)
	if (not IsValid(self:GetOwner()) or dmg:GetAttacker() ~= self:GetOwner()) then
		return
	end

	if (self.PlutoGun and self.PlutoGun.Owner == self:GetOwner():SteamID64()) then
		if (atk:GetRoleTeam() ~= ply:GetRoleTeam()) then -- add experience to weapon
			pluto.inv.addexperience(self.PlutoGun.RowID, (atk:GetRole() == "Innocent" and 150 or 75) + math.random(0, 25))
		end
	end

	if (self.RunModFunctionSequence) then
		self:RunModFunctionSequence("Kill", nil, self:GetOwner(), ply)
	end
end

function SWEP:RunModFunctionSingle(funcname, ...)
	local gun = self.PlutoGun
	if (not gun) then
		return
	end
	for type, list in pairs(gun.Mods) do
		for _, item in ipairs(list) do
			local mod = pluto.mods.byname[item.Mod]
			if (mod[funcname]) then
				local rolls = pluto.mods.getrolls(mod, item.Tier, item.Roll)
				mod[funcname](mod, self, rolls, ...)
			end
		end
	end
end

function SWEP:RunModFunctionSequence(funcname, state, ...)
	local args = {n = select("#", ...) + 1, ...}
	args[args.n] = state or {}

	hook.Run("PlutoPre" .. funcname, self, unpack(args, 1, args.n))
	self:RunModFunctionSingle("Pre" .. funcname, unpack(args, 1, args.n))
	self:RunModFunctionSingle("On" .. funcname, unpack(args, 1, args.n))
	self:RunModFunctionSingle("Post" .. funcname, unpack(args, 1, args.n))

	if (self:GetTable()[funcname]) then
		self[funcname](self, state, ...)
	end
end

function SWEP:FireBulletsCallback(tr, dmginfo)
	BaseClass.FireBulletsCallback(self, tr, dmginfo)

	self:RunModFunctionSequence("Shoot", nil, tr, dmginfo)
end

function SWEP:SendData(ply)
	local gun = self.PlutoGun
	if (not gun) then
		return
	end
    if(gun.Mods) then
        for type, list in pairs(gun.Mods) do
            for _, item in ipairs(list) do
                local mod = pluto.mods.byname[item.Mod]
                local rolls = pluto.mods.getrolls(mod, item.Tier, item.Roll)
                table.insert(self.PlutoGun, {
                    Mod = mod,
                    Rolls = rolls
                })
            end
        end
    end

	local modifiers = {
		implicit = {},
		prefix   = {},
		suffix   = {},
	}

	for _, ply in pairs(ply and {ply} or player.GetAll()) do
		net.Start "pluto_wpn_db"
			net.WriteInt(self:GetPlutoID(), 32)
			if (gun.RowID) then
				net.WriteBool(true)
				pluto.inv.writeitem(ply, gun)
			else
				net.WriteBool(false)
				pluto.inv.writebaseitem(ply, gun)
			end
		net.Send(ply)
	end
end

function SWEP:SetInventoryItem(gun)
	self.PlutoGun = gun

	self:SendData()
	
	pluto.wpn_db[self:GetPlutoID()] = gun

	self:ReceivePlutoData()

	timer.Simple(0, function()
		if (not IsValid(self)) then
			return
		end

		if (pluto_disable_constellations:GetBool()) then
			return
		end

		if (gun.constellations) then
			pluto.nodes.applyactive(self, gun.constellations)
		end
	end)
end

hook.Add("EntityTakeDamage", "pluto_dmg_mods", function(targ, dmg)
	if (dmg:GetDamage() <= 0 or bit.band(dmg:GetDamageType(), DMG_BULLET) ~= DMG_BULLET) then
		return
	end

	if (not targ:IsNextBot() and not hook.Run("PlayerShouldTakeDamage", targ, dmg:GetAttacker())) then
		return
	end

    if (targ:IsNextBot() and not targ:Alive()) then
        return
    end
    
	local self = dmg:GetInflictor()
	if (not IsValid(self) or not self.RunModFunctionSequence) then
		return
	end
	self:RunModFunctionSequence("Damage", nil, targ, dmg)
end)
