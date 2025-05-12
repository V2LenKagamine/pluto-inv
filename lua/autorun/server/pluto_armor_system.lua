hook.Add("HandlePlayerArmorReduction", "pluto_armor_hook", function(ply,dinfo)
    if (ply:Armor() <=0 || bit.band(dinfo:GetDamageType(), DMG_FALL + DMG_DROWN + DMG_POISON + DMG_RADIATION) ~= 0)then return end
    local dmg = dinfo:GetDamage()
    local armr = ply:Armor()

    if(armr >= dmg) then
        dinfo:SetDamage(0)
        ply:SetArmor(armr - dmg)
    else
        dinfo:SetDamage(dmg - armr)
        ply:SetArmor(0)
    end
end)