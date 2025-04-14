if CLIENT then
    matproxy.Add( {
        name = "HemlokAMMO",
        init = function( self, mat, values )
            self.ResultTo = values.resultvar
            self.Prefix = values.prefixstring
        end,
        bind = function( self, mat, ent )
                local Place = self.ResultTo
                local texture

                if LocalPlayer():GetActiveWeapon() then
                    local OurWeapon = LocalPlayer():GetActiveWeapon()
                    if OurWeapon.Gun == "cyberian_hemlok" then
                        local KnowYourPlace = string.sub(string.reverse(OurWeapon:Clip1()), Place, Place)
                        local digits = string.format( tonumber(KnowYourPlace) or 0 )
                        
                        texture = self.Prefix .. digits
                    end
                end

                if texture then
                    mat:SetTexture( "$basetexture", texture )
                end
        end
    } )