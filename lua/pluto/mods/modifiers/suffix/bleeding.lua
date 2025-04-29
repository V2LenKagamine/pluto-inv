--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
MOD.Type = "suffix"
MOD.Name = "Bleeding"
MOD.Color = Color(211, 45, 3)
MOD.Tags = {
	"damage", "bleed", "dot"
}

function MOD:IsNegative(roll)
	return false
end

function MOD:FormatModifier(index, roll)
	return string.format("%.01f%%", roll)
end

MOD.Description = "%s of Damage dealt is converted to Bleed; Bleed does more damage to running targets."

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
		state.bleedstacks = (wep:ScaleRollType("damage", rolls[1])/100) * dmg:GetDamage()
	end
end

function MOD:PostDamage(wep, rolls, target, dmg, state)
    if(not state) then return end
	if (state.bleedstacks) then
		dmg:SetDamage(dmg:GetDamage() - state.bleedstacks)
		self:DoStuff(target,dmg:GetAttacker(),state.bleedstacks)
	end
end
pluto.statuses = pluto.statuses or {}
pluto.statuses.bleed = pluto.statuses.bleed or {}
function MOD:DoStuff(target, atk, stacks)
    local status
    if(not isentity(target)) then return end
    for _, ent in pairs(target:GetChildren()) do
        if(ent.PrintName == "Pluto_Bleed") then
            status = ent
            break 
        end
    end
    if(not IsValid(status)) then
        status = ents.Create("pluto_status")
        status:SetParent(target)
        status.PrintName = "Pluto_Bleed"
        status.Data = {
            Dealer = atk,
            OnThink = pluto.statuses.bleed.DoThink,
            TicksLeft = stacks,--[[
            Hook_Input = {
                "PlayerButtonDown",
                pluto.statuses.bleed.Hook_Input,
            },]]
            ThinkDelay = .75,
        }
        status:Spawn()
    else
        status.Data.TicksLeft = status.Data.TicksLeft + stacks
    end
end
function pluto.statuses.bleed.DoThink(ent)

    local vic = ent:GetParent()

    local stax = ent.Data.TicksLeft
    local todeal
    if(stax >= 7.5) then
        todeal = 1.6
        ent.Data.TicksLeft = ent.Data.TicksLeft - 1
    else
        todeal = 0.8
    end
    if(vic:GetVelocity():LengthSqr() > vic:GetSlowWalkSpeed()^2) then
        todeal = todeal * 1.25
    end

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
--[[ Maybe do this?
if(SERVER)then
    util.AddNetworkString("ClearBleedDebuff")

    net.Receive("ClearBleedDebuff", function(msg,sndr) 
        local debuff = net.ReadEntity()
        local reported = net.ReadFloat()
        if(not IsValid(debuff)) then return end
        local stax = debuff.Data.TicksLeft
        local holddown = 0.5
        if(stax >= 15) then
            holddown = 3
        elseif(stax < 15 and stax >= 7.5) then
            holddown = 1.5
        end
        if(holddown <= debuff.SecsDown + (engine.TickInterval()*2)) then --Ok ill beleive that.
            debuff:Remove() --Not calling expire here because was expunged.
        end
    end)
end

function pluto.statuses.bleed.Hook_Input(ply,buttn)
    if(CLIENT) then
        local bleed
        for _,son in pairs(ply.GetChildren()) do
            if(son:GetOwner() == LocalPlayer) then
                bleed = son
                break 
            end
        end
        if(ply ~= bleed:GetOwner()) then return end
        if(IsFirstTimePredicted() and input.IsButtonDown(input.LookupBinding("+use"))) then
            bleed.SecsDown = (bleed.SecsDown or 1) / engine.TickInterval()
            local stax = bleed.Data.TicksLeft
            local holddown = 0.5
            if(stax >= 15) then
                holddown = 3
            elseif(stax < 15 and stax >= 7.5) then
                holddown = 1.5
            end
            if(holddown <= bleed.SecsDown) then
                net.Start("ClearBleedDebuff")
                net.WriteEntity(bleed)
                net.WriteFloat(SecsDown)
                net.Send()
            end
        end
    end
end
]]

return MOD