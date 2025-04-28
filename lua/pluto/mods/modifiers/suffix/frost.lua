--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
MOD.Type = "suffix"
MOD.Name = "Frost"
MOD.Color = Color(0, 162, 255)
MOD.Tags = {
	"damage", "hinder",
}

function MOD:IsNegative(roll)
	return false
end


function MOD:FormatModifier(index, roll)
	return string.format("%.01f%%", roll)
end

MOD.Description = "%s of Damage dealt is converted to Frost."

MOD.Tiers = {
	{ 25, 35 },
	{ 15, 25 },
	{ 5, 15 },
}

function MOD:ModifyWeapon(wep, rolls)
	wep:ScaleRollType("damage", rolls[1], true)
end

function MOD:OnDamage(wep, rolls, target, dmg, state)
	if (not IsValid(target) or not isentity(target)) then return end
    if(target:IsPlayer() and dmg:GetDamage() > 0) then
		state.froststacks = (wep:ScaleRollType("damage", rolls[1])/100) * dmg:GetDamage()
	end
end

function MOD:PostDamage(wep, rolls, target, dmg, state)
    if(not state) then return end
	if (state.froststacks) then
		dmg:SetDamage(dmg:GetDamage() - state.froststacks)
		self:DoStuff(target,dmg:GetAttacker(),state.froststacks)
	end
end
pluto.statuses = pluto.statuses or {}
pluto.statuses.frost = pluto.statuses.frost or {}
function MOD:DoStuff(target, atk, stacks)
    local status
    if(not isentity(target)) then return end
    for _, ent in pairs(target:GetChildren()) do
        if(ent.PrintName == "Pluto_Frost") then
            status = ent
            break
        end
    end
    local comptime = CurTime() + ((target:Ping() or 0) * 4 / 1000)
    if(not IsValid(status)) then
        status = ents.Create("pluto_status")
        status:SetParent(target)
        status.PrintName = "Pluto_Frost"
        status.Data = {
            Dealer = atk,
            OnThink = pluto.statuses.frost.DoThink,
            TicksLeft = stacks,
            ThinkDelay = 1,
            Hook_Speed = {
                "TTTUpdatePlayerSpeed",
                pluto.statuses.frost.HookSpeed,
            },
        }
        status:Spawn()
        target:SetFrostStarted(comptime)
    else
        status.Data.TicksLeft = status.Data.TicksLeft + stacks
    end
    local frostLvl = 1 + math.floor(status.Data.TicksLeft / 6)
    target:SetFrostUntil(comptime + (status.Data.TicksLeft * status.Data.ThinkDelay))
    target:SetFrostLvl(frostLvl)
end

function pluto.statuses.frost.DoThink(ent)
    if(not ent) then return end
    local vic = ent:GetParent()

    local stax = ent.Data.TicksLeft
    local todeal = 1.1
    local frostLvl = 1 + math.floor(stax / 6)

    todeal = todeal * frostLvl
    vic:SetFrostLvl(frostLvl)
    local dinfo = DamageInfo()
    if(IsValid(ent.Data.Dealer)) then
        dinfo:SetAttacker(ent.Data.Dealer)
    else
        dinfo:SetAttacker(game.GetWorld())
    end
    dinfo:SetDamageType(DMG_DIRECT + DMG_BULLET)
    dinfo:SetDamagePosition(vic:GetPos())
    dinfo:SetDamage(todeal)
    vic:TakeDamageInfo(dinfo)
end

hook.Add("TTTGetHiddenPlayerVariables", "pluto_frost", function(vars)
	table.insert(vars, {
		Name = "FrostUntil",
		Type = "Float",
		Default = -math.huge,
		Enums = {}
	})
	table.insert(vars, {
		Name = "FrostStarted",
		Type = "Float",
		Default = -math.huge,
		Enums = {}
	})
    table.insert(vars, {
		Name = "FrostLvl",
		Type = "Float",
		Default = -math.huge,
		Enums = {}
	})
end)

local frost_scalar = 
{
    [1] = 0.125,
    [2] = 0.2,
    [3] = 0.325,
    [4] = 0.4,
    [5] = 0.475,
    [6] = 0.6,
    [7] = 0.75,
}

function pluto.statuses.frost.HookSpeed(plr,data)
    if(not plr) then return end
    local sloweduntil = plr:GetFrostUntil()

	if (sloweduntil > CurTime() and plr:GetFrostStarted() < CurTime()) then
		data.FinalMultiplier = data.FinalMultiplier * (1 - (frost_scalar[plr:GetFrostLvl()] or 1))
	end
end


return MOD