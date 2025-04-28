--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
MOD.Type = "suffix"
MOD.Name = "Lightning"
MOD.Color = Color(0, 162, 255)
MOD.Tags = {
	"damage", "hinder",
}

function MOD:IsNegative(roll)
	return roll < 0
end


function MOD:FormatModifier(index, roll)
	return string.format("%.01f%%", roll)
end

MOD.Description = "%s of Damage dealt is converted to Shock; Shock deals burst damage on expire, or bonus damage after reaching a Stack Treshhold"

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
		state.shockstacks = (wep:ScaleRollType("damage", rolls[1])/100) * dmg:GetDamage()
	end
end

function MOD:PostDamage(wep, rolls, target, dmg, state)
    if(not state) then return end
	if (state.shockstacks) then
		dmg:SetDamage(dmg:GetDamage() - state.shockstacks)
		self:DoStuff(target,dmg:GetAttacker(),state.shockstacks)
	end
end
pluto.statuses = pluto.statuses or {}
pluto.statuses.shock = pluto.statuses.shock or {}
function MOD:DoStuff(target, atk, stacks)
    local status
    if(not isentity(target)) then return end
    for _, ent in pairs(target:GetChildren()) do
        if(ent.PrintName == "Pluto_Shock") then
            status = ent
            break
        end
    end
    if(not IsValid(status)) then
        status = ents.Create("pluto_status")
        status:SetParent(target)
        status.PrintName = "Pluto_Shock"
        status.Data = {
            Dealer = atk,
            OnThink = pluto.statuses.shock.DoThink,
            TicksLeft = 6,
            ThinkDelay = 0.5,
            OnExpire = pluto.statuses.shock.DoShock,
            Stax = stacks,
        }
        status:Spawn()
    else
        status.Data.Stax = status.Data.Stax + stacks
        status.Data.TicksLeft = 10
    end
end

function pluto.statuses.shock.DoThink(ent)
    if(not ent) then return end

    if (ent.Data.Stax >= 20) then
        pluto.statuses.shock.DoShock(ent,true)
    end
end

function pluto.statuses.shock.DoShock(ent,forced)
    if(not ent) then return end
    local vic = ent:GetParent()

    local todeal = ent.Data.Stax * 0.66
    if(forced) then
        todeal = ent.Data.Stax * .88
    end
    ent.Data.Stax = 0
    local dinfo = DamageInfo()
    if(IsValid(ent.Data.Dealer)) then
        dinfo:SetAttacker(ent.Data.Dealer)
    else
        dinfo:SetAttacker(game.GetWorld())
    end
    dinfo:SetDamageType(DMG_DIRECT + DMG_BULLET)
    dinfo:SetDamagePosition(vic:GetPos())
    dinfo:SetDamage(todeal)
    if(dinfo:GetDamage() > 0) then
        vic:TakeDamageInfo(dinfo)
    end
end

return MOD