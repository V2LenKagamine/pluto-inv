--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
MOD.Type = "suffix"
MOD.Name = "Igniting"
MOD.Tags = {
	"damage", "fire", "dot"
}

MOD.Color = Color(211, 111, 3)

function MOD:IsNegative(roll)
	return false
end

function MOD:FormatModifier(index, roll)
	return string.format("%.01f%%", roll)
end

MOD.Description = "%s of Damage dealt is converted to Flame; Missed shots may ignite terrain; Flame does more damage and lasts longer the more stacks the target has."

MOD.Tiers = {
	{ 25, 35 },
	{ 15, 25 },
	{ 5, 15 },
}

function MOD:ModifyWeapon(wep, rolls)
	wep:ScaleRollType("damage", rolls[1], true)
end

function MOD:OnShoot(wep, rolls, trce, dmg, state)
    if(CLIENT) then return end
    if(trce.Entity) then
        if(trce.Entity:IsWorld()) then
            if(math.Rand(0,100) < wep:ScaleRollType("damage",rolls[1])) then
                CreateVFire(trce.Entity,trce.HitPos,vector_origin,dmg:GetDamage()*1.5,dmg:GetAttacker())
            end
        end
    end
end

function MOD:OnDamage(wep, rolls, target, dmg, state)
	if (not IsValid(target) or not isentity(target)) then return end
    if(target:IsPlayer() and dmg:GetDamage() > 0) then
		state.firestacks = (wep:ScaleRollType("damage", rolls[1])/100) * dmg:GetDamage()
	end
end

function MOD:PostDamage(wep, rolls, target, dmg, state)
    if(not state) then return end
	if (state.firestacks) then
		dmg:SetDamage(dmg:GetDamage() - state.firestacks)
		self:DoStuff(target,dmg:GetAttacker(),state.firestacks)
	end
end
pluto.statuses = pluto.statuses or {}
pluto.statuses.fire = pluto.statuses.fire or {}
function MOD:DoStuff(target, atk, stacks)
    local status
    if(not isentity(target)) then return end
    for _, ent in pairs(target:GetChildren()) do
        if(ent.PrintName == "Pluto_Fire") then
            status = ent
            break
        end
    end
    if(not IsValid(status)) then
        status = ents.Create("pluto_status")
        status:SetParent(target)
        status.PrintName = "Pluto_Fire"
        status.Data = {
            Dealer = atk,
            OnThink = pluto.statuses.fire.DoThink,
            TicksLeft = stacks,
            ThinkDelay = 0.2,
            OnExpire = pluto.statuses.fire.OnExpire,
        }
        status:Spawn()
    else
        status.Data.TicksLeft = status.Data.TicksLeft + stacks
    end
end


function pluto.statuses.fire.DoThink(ent)
    if(not ent) then return end
    local vic = ent:GetParent()
    local visFire = ent.VFireP
    if(vic and not IsValid(visFire)) then
        visFire = CreateVFire(vic,vic:GetPos(),vector_origin,100,ent.Data.Dealer)
        visFire.vFireDamageData = {dmgMul = 0, dmgType = DMG_BURN}
        visFire:Spawn()
        ent.VFireP = visFire
    end

    local stax = ent.Data.TicksLeft
    local todeal = 0.1
    if(stax >= 12) then
        todeal = 0.46
        ent.Data.TicksLeft = ent.Data.TicksLeft + 0.5
    elseif(stax < 12 and stax >= 6) then
        todeal = 0.22
        ent.Data.TicksLeft = ent.Data.TicksLeft + 0.25
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

function pluto.statuses.fire.OnExpire(ent)
    local visfire = ent.VFireP
    if(IsValid(visfire)) then
        ent:GetParent():Extinguish()
    end
end

return MOD