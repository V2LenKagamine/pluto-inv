if SERVER then return end
matproxy.Add({
    name = "HemlokAMMO",
    init = function( self, mat, values )
        self.ResultTo = values.resultvar
        self.Prefix = values.prefixstring
    end,
    bind = function( self, mat, ent )
            local Place = self.ResultTo
            local texture
            if (IsValid(LocalPlayer():GetActiveWeapon())) then
                local wep = LocalPlayer():GetActiveWeapon()
                if(wep:GetClass() ~= "weapon_hemlok" and wep:GetClass() ~= "weapon_hemlok_normal") then return end
                local KnowYourPlace = string.sub(string.reverse(wep:Clip1()), Place, Place)
                local digits = string.format( tonumber(KnowYourPlace) or 0 )
                    
                texture = self.Prefix .. digits
            end

            if texture then
                mat:SetTexture( "$basetexture", texture )
            end
        end
    })